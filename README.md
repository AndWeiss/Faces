# Faces

Creates audio reactive visuals of painted faces that are reconstructed from a POD.

It is programmed with processing version 3+ [https://processing.org/download/](https://processing.org/download/]).
Additionally the papaya library for matrix manipulation must be installed (manually, if it is not included in the processing tools menu) 
[http://adilapapaya.com/papayastatistics/](http://adilapapaya.com/papayastatistics/).
Additionally the minim library is mandatory.

A demonstration can be seen in [Youtube](https://youtu.be/9tYNO9L3Fw8?si=2eiku81FeP4XBE5N)

The faces are digitaly painted by hand on a smartphone using a self implemented Processing tool.
The amount of roughly 300 paintings have been previously decomposed with Proper Orthogonal Decomposition (POD) 
using an implementation in Python. The resulting decomposed data is stored in the files 
Mean.txt, Modes.txt and Parameters.txt . These files are in the moment excluded from the repository as they are 
too large for Github. 

The Program is reconstructing and displaying the images, with using the sound input as a kind of disturbance to 
the reconstruction algorithm. 

### Sound processing:

A FFT is performed on the sound input (standard recording device), mean and maximum values for the magnitude of high, mid and low 
frequencies are calculated, see *get_sound_numbers.pde*

### Reconstruction manipulation

The mean low frequency parameter is multiplied to the POD-parameter values, the mean mid frequency value is multiplied 
to a random number that adds up to the POD-parameters. The mean value of high frequency amplitudes control the magnitude of random
pixel color (brightness) added to the reconstructed black and white values of the individual pixels. The ratio of max and mean magnitude
of the mean frequency band is controlling the number of modes that are used for the reconstruction. If a threshold value of the diifference in 
mean low freaquency magnitude is exceeded a new base parameter set is chosen. 
 

### The following parameters can be adjusted by using the following keys, see also *keyPressed.pde*:

   'x': low frequency factor (increase)
  
   'y': low frequency factor (decrease)
  
   's': mid frequency factor (increase)
  
   'a': mid frequency factor (decrease)
  
   'w': high frequency factor (increase)
  
   'q': high frequency factor (decrease)
	
   'l': threshold (limit) for new faces (increase)
	
   'k': threshold (limit) for new faces (decrease)
	
   'f': overall scaling of all factors (increase)
	
   'd': overall scaling of the factors (decrease)
	
   'p': turns on / off the logarithmic evaluation of the fft (is off by default)

## to do: 

enable colored images
