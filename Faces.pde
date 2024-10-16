import processing.javafx.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import papaya.*;
import ddf.minim.ugens.*;
import ddf.minim.spi.*; // for AudioStream
import processing.pdf.*; //for pdf export

// for the sound processing -----------------------
Minim minim;
//AudioPlayer player;
FFT fft ;
AudioOutput out;
AudioInput in;
WindowFunction newWindow = FFT.NONE;
int buffer = 1024;
float[] f_means     = {0., 0. , 0.} ;
float[] f_means_old = new float[3];
int[] max_freq      = new int[3];
float[] f_maxs      = new float[3];
float f_diff        = 0 ;
int limits[] = new int[4];


float beatmittel = 0.0;
float beatneu = 0.0;
// end variables for sound processing -----------------------

// factors that can be controlled by the keyboard -----------
//float[] factors    = {0.13, 0.264 , 0.05} ;
//float newfacelimit = 2;
float[] factors    = {0.031896718, 0.06477489 , 0.0122679705} ;
float newfacelimit = 0.49071875;
// factor that scale all other factors
float superfac     = 1 ; // is assigned when button is pushed
boolean log_on = false;

// global variables -------------------------------------------------
Table table;
float[][] A; 
float[][] phi;
float[] umean; 
int Nr = 402; // number of rows
int Nc = 250; // number of columns 
int Nc4 = 4*Nc;
int Nc2 = 2*Nc;
int Nfaces ;
float[][][] matrix ;
float[] u_tilde;
PImage img;
int face_id = 0;
float randfuk = 1;
int Nmodes ;
int im_position_x, im_position_y, new_imsize_x, new_imsize_y;
//--------------------------------------------------------------------
void keyPressed() {
  if (key == 'x') {
    // low frequency factor +
    factors[0] *= 1.1;
  }
  else if(key == 'y'){
   // low frequency factor -
   factors[0] *= 0.9;
  }
  else if (key == 's') {
    // mid frequency factor +
    factors[1] *= 1.1;
  }
  else if (key == 'a') {
    // mid frequency factor -
    factors[1] *= 0.9;
  }
  else if (key == 'w') {
    // high frequency factor +
    factors[2] *= 1.1;
  }
  else if (key == 'q') {
    // high frequency factor -
    factors[2] *= 0.9;
  }  
  else if (key == 'l') {
    // threshold (limit) for new faces +
    newfacelimit *= 1.1;
  }  
  else if (key == 'k') {
    // threshold (limit) for new faces -
    newfacelimit *= 0.9;
  }  
    else if (key == 'f') {
    // overall scaling of all factors +
    superfac = 1.1;
    factors = Mat.multiply(factors,superfac);
    newfacelimit *= superfac;
  }  
  else if (key == 'd') {
    // overall scaling of the factors -
    superfac = 0.9;
    factors = Mat.multiply(factors,superfac);
    newfacelimit *= superfac;
  }  
  else if (key == 'p') {
    // turns on / off the logarithmic evaluation of the fft
    log_on = !log_on;
  }
  println(key);
  println("factors");
  println(factors);
  println("newfacelimit");
  println(newfacelimit);
  //println("superfac");
  //println(superfac);
  println("log_on");
  println(log_on);
}

// ------------------------------------------------
void setup() 
{
  //size(1900, 1000,P2D); //FX2D  or P2D
  //size(1000,1000,P2D); 
  fullScreen(P2D,SPAN);
  //translate(width/2,height/2);
  //fullScreen(FX2D); //, SPAN);
  noFill();
  stroke(255);
  background(0);
  // the new size of the image for displaying
  new_imsize_x = int(Nc*2.5);
  new_imsize_y = int(Nr*2.5);
  // calculate the position to make the image appear in the center
  int mywidth = 1920;
  int myheight = 1080;
  im_position_x = int(mywidth/2  - new_imsize_x/2);
  im_position_y = int(myheight/2 - new_imsize_y/2);
  //the limits of the frequency separation
  limits[0] =  1 ;          // start frequency
  limits[1] =  buffer/200 ; //low frequencies
  limits[2] =  buffer/6 ;   //mid frequencies
  limits[3] =  buffer/2 ;   //high frequencies (end frequency)
  println(limits);
 // Create an empty image with width 2*Nc and height 2*Nr
  //img = createImage(2*Nc,2*Nr, ALPHA); 
  img = createImage(Nc,Nr, ALPHA); 
  img.loadPixels(); // Load the pixel data of the image
  
  //table = loadTable("Parameters.txt","csv");
  //println(table.getRowCount());
  //println(table.getColumnCount());
  //A = new float[table.getRowCount()][table.getColumnCount()];
  //int i = 0;
  //for(TableRow row : table.rows()){
  //  for(int j = 0; j< table.getColumnCount(); j++){
  //    A[i][j] = row.getFloat(j);
  //    println(A[i][j]);
  //  }
  //  i++;
  //}
  A = ReadFile("./POD_data_BW/Parameters.txt"," ");

  phi = Mat.transpose(ReadFile("./POD_data_BW/Modes.txt"," "));

  umean = Mat.transpose(ReadFile("./POD_data_BW/Mean.txt"," "))[0];
  
  println("lenght phi ");
  println(phi.length);
  println(phi[0].length);
  
  println("lenght A = number of faces ");
  println(A.length);
  println(A[0].length);
  Nfaces = A.length;
  u_tilde = Mat.constant(0.0,phi[0].length);
  
  // reshape to 
  //matrix = new float[Nfaces][Nr][Nc];
  //for (int k = 0; k < Nfaces; k++) {
  //  for (int i = 0; i < Nr; i++) {
  //    for (int j = 0; j < Nc; j++) {
  //      matrix[k][i][j] = phi[k][i * Nc + j];
  //    }
  //  }
  //}
  //println("matrixlength");
  //println(matrix.length);
  //println(matrix[0].length);
  //println(matrix[0][0].length);
  
  ////loadPixels();
  //for (int i = 0; i < Nr; i++) {
  //  for (int j = 0; j < Nc; j++) {
  //    //int colorValue = color(phi[i][int(random(0,290))] ); // Convert to grayscale
  //    int c    = color(matrix[0][i][j]);
  //    // the original pixel
  //    img.pixels[i*Nc*4 + 2*j      ]    = c;
  //    // the right neibour pixel
  //    img.pixels[i*Nc*4 + 2*j + 1  ]    = c;
  //    // the lower neibour pixel
  //    img.pixels[i*Nc*4 + 2*j + 2*Nc ]    = c;
  //    // the lower right neibour pixel
  //    img.pixels[i*Nc*4 + 2*j + 2*Nc + 1] = c; 

  //  }
  //}
  //img.updatePixels();
  ////img.resize(1000,804);
  //image(img,0,0);
  
  
  // for the sound processing -----------------------
  minim = new Minim(this);                                               
  // construct a LiveInput by giving it an InputStream from minim.                                                  
  in = minim.getLineIn(); //new LiveInput( inputStream );
  //
  fft = new FFT( buffer, in.sampleRate() );
  println(in.sampleRate()); 
}

/*
void keyPressed() {
 if(key == 'i'){
   a +=10;
 }
}
*/


void draw() {
  // draw an image from pixels
  background(0);
  // get the sound numbers ----------------------
  Get_sound_numbers();
  // and print them 
  //println("----------------------------------");
  //println(f_means);
  //println(f_maxs);
  //println(max_freq);
  //println("----------------------------------");
  // reconstruction of the picture
  if (f_diff > newfacelimit){
    println("newface Id");
    println(f_diff);
    // choose a new face randomly
    face_id = int(random(0,Nfaces));
  }
  Nmodes = min(5 + int(f_maxs[1]/f_means[1]*Nfaces),Nfaces);
  // println(Nmodes);
  // float[] rec = Reconstruct_pod(A[face_id],0,int(random(0,292)),umean[face_id],u_tilde);
  float[] rec = Reconstruct_pod(A[face_id],0,Nmodes,umean[face_id],u_tilde);
  for(int i = 0; i < rec.length;i++){
    // set the pixel color from the matrix  
    img.pixels[i] = color(rec[i] + f_means[2]*random(-255,255));
  }
  img.updatePixels();
  // img.resize(1000,500);
  // show the picture
  //image(img,  im_position_x ,im_position_y);  
  // parameters c,d for size to display
  image(img,  im_position_x ,im_position_y, new_imsize_x, new_imsize_y);  
}
   
  void mouseWheel(MouseEvent event) {
    float e = event.getCount();   
    println("mouse Wheel");
    println(e);
    randfuk += e;
    println("randfuk");
    println(randfuk);
  }  

   
   
  void mousePressed() {
    face_id +=1;
    noLoop();
    
  }
  void mouseReleased() {
    loop();
  }
