# -*- coding: utf-8 -*-
"""
Created on Tue Oct  8 11:20:19 2024

@author: Ichyc
"""

import imageio.v3 as iio
import glob
import numpy as np

import matplotlib.pyplot as plt
import matplotlib.image as img
import sys

#import cv2

#simple image scaling to (nR x nC) size
def scale(im, nR, nC):
  nR0 = len(im)     # source number of rows 
  nC0 = len(im[0])  # source number of columns 
  return [[ im[int(nR0 * r / nR)][int(nC0 * c / nC)]  
             for c in range(nC)] for r in range(nR)]


def do_reconstruct(A,phi,Nmodes=0,umean = 0):
    # A are the POD-coefficients
    # phi are the modes
    # Nmodes is the number of modes that will be used to reconstruct the original data
    # umean is the mean data
    if len(A.shape) == 1:
        A = A.reshape(1,A.shape[0])
    u_tilde = np.zeros((A.shape[0],phi.shape[0]))
    # if number of modes is not given take 
    # all the modes given in phi and A
    if Nmodes == 0: 
        Nmodes = phi.shape[1]
    for k in range(0,Nmodes):
        u_tilde =  u_tilde + np.tensordot(A[:,k],phi[:,k], axes = 0)
    #
    # if umean == 0:
    #     return  u_tilde
    # else:
    return  u_tilde + umean.reshape(u_tilde.shape[0],1)


def rgb2gray(rgb):
    gray = 0.2989 * rgb[:,:,0] + 0.5870 * rgb[:,:,1] + 0.1140 * rgb[:,:,2]
    
    # different parameters are possible for conversion to grayscale
    # for convertion to grayscale:
    #(i[0]*0.299+i[1]*0.587+i[2]*0.114) ### Rec. 609-7 weights
    #(i[0]*0.2125+i[1]*0.7174+i[2]*0.0721) ### Rec. 709-6 weights
    return np.uint8(gray)

phi = np.genfromtxt("POD_data_BW/Modes.txt",delimiter=' ')


all_paths = glob.glob("./Face_Fotos/*.JPG")
Npics = len(all_paths)
cut = 128 
im0 = iio.imread(all_paths[0]) 
im0 = im0[:,cut:]
# make the picture smaller
im0 = im0[0::3,0::3]
all_pics = np.zeros([Npics,*im0.shape[::-1][1:]],dtype = 'uint8')
for i, im_path in enumerate(all_paths):
     im = iio.imread(im_path)
     im = im[:,cut:]
     im = im[0::3,0::3]
     im = rgb2gray(im)
     all_pics[i] = im.T
     print(i)
     # do whatever with the image here
     # break 

new_scale = [402, 250]
all_pics_new = np.zeros([Npics,*new_scale],dtype = 'uint8')
for i,imi in enumerate(all_pics):
    all_pics_new[i] = scale(imi, new_scale[0],new_scale[1])
    

all_pics_array = all_pics_new.reshape(Npics,-1)

umean = np.mean(all_pics_array,axis=-1)

all_pics_array = all_pics_array - umean.reshape(len(umean),1)

Aneu =  all_pics_array @ phi

u_tilde = do_reconstruct(Aneu, phi,umean = umean)

u_tilde = u_tilde.reshape(u_tilde.shape[0],*new_scale)

u_tilde = np.uint8(u_tilde)

for i in range(3):
    plt.figure()
    plt.imshow(u_tilde[i],cmap='gray', vmin = 0, vmax = 255)
    plt.show()
