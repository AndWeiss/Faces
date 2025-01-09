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
