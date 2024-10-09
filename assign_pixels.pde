// unused function - can be used for direct scaling of the picture by 2 in each dimension
void assign_pixels(float[] rec){
  for (int i = 0; i < Nr; i++) {
      for (int j = 0; j < Nc; j++) {
        int c    = color(rec[i * Nc + j] + f_means[2]*random(-255,255));
        // the original pixel
        int ind = i*Nc4 + 2*j ;
        img.pixels[ind          ] = c;
        // the right neibour pixel
        img.pixels[ind + 1      ] = c;
        // the lower neibour pixel
        img.pixels[ind + Nc2    ] = c;
        // the lower right neibour pixel
        img.pixels[ind + Nc2 + 1] = c; 
      }
  }
}
