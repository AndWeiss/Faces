//---------------------------
void Get_sound_numbers(){
  //----------------------------
   newWindow = FFT.HANN;
   fft.window( newWindow );
   fft.forward( in.mix ); //fourier-Transformation
   // initialization
   beatmittel = 0; 
   beatneu    = 0;
   for (int i = 0; i<f_means.length; i++){
     f_means_old[i] = f_means[i];
     f_means[i]     = 0;
     f_maxs[i]      = 0;
     max_freq[i]    = 1;
   }
   //loop through all frequencies in fft.getBand 
   //and all the direct sound signals
   //------------------------------------------------------------------------------------------
   // loop through the low frequencies 
   for (int n=0; n<limits.length-1; n++){
     Get_means(n,limits[n],limits[n+1]);
   }
   // calculate f_diff
   f_diff = f_means_old[0] - f_means[0];
}

void Get_means(int index,int l0, int l1){
    for(int i=l0; i<l1 ;i++){
      float tempmag = fft.getBand(i);
      if (log_on){
         tempmag = log(tempmag+1);
      }
      f_means[index] = f_means[index] + tempmag ;
      //if (log(fft.getBand(max_freq[index]+1) ) <  tempmag ){
      if (f_maxs[index]  <  tempmag ){  
        max_freq[index] = i;
        f_maxs[index]   = fft.getBand(i) ; 
        if(log_on){
          f_maxs[index]   = log(f_maxs[index]+1) ; 
        }
      }
   }
   //f_maxs[index] =   factors[index]*log(fft.getBand(max_freq[index])+1) ; 
   f_maxs[index]  *= factors[index];
   f_means[index] *= factors[index];
}
