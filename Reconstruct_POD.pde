//---------------------------
float[] Reconstruct_pod(float[] a,int startMode ,int endMode,float mean,float[] u_tilde){
    // A are the POD-coefficients
    // phi are the modes
    // Nmodes is the number of modes that will be used to reconstruct the original data
    // umean is the mean data
    //if len(A.shape) == 1:
    //    A = A.reshape(1,A.shape[0])
    // if number of modes is not given take 
    // all the modes given in phi and A
    for(int k = startMode; k< endMode; k++){
        //u_tilde = Mat.sum( u_tilde, Mat.multiply(phi[k], a[k])); 
        u_tilde = Mat.sum( u_tilde, Mat.multiply(phi[k], f_means[0]*a[k] + f_means[1]*random(-0.1,0.1) )); 
    }
    //
    return  Mat.sum(u_tilde,mean) ;

 
}
