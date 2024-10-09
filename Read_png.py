# -*- coding: utf-8 -*-
"""
Created on Tue Apr 18 12:42:43 2023

@author: weisse02
"""

import imageio.v3 as iio
import glob
import numpy as np

import matplotlib.pyplot as plt
import matplotlib.image as img
import sys


def do_POD(u,clip = 0):
    Nt = u.shape[0]
    #S = reshape(permute(S, [3 2 1]), Nt, [ ]); % Reshape data into a matrix S with Nt rows
    umean = np.mean(u,0)
    U = u - umean  # Subtract the temporal mean from each row
    # Create covariance matrix
    C = (U.T @ U)/(Nt-1)
    # Solve eigenvalue problem
    lam , phi = np.linalg.eig(C) # lam are the eigenvalues lambda and phi the corrp. eigenvectors
    # Sort eigenvalues and eigenvectors
    ilam = np.argsort(-lam,axis=-1)
    lamb = np.take_along_axis(lam,ilam,axis=-1)
    phi = phi[:,ilam] # PHI(:, ilam); # These are the spatial modes
    # Calculate time coefficients
    A = U @ phi
    if clip > 0:
        A = A[:,0:clip]
        phi = phi[:,0:clip]
    return A, phi, umean, lamb 


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
    return  u_tilde + umean.reshape(u_tilde.shape[0],1)



def rgb2gray(rgb):
    gray = 0.2989 * rgb[:,:,0] + 0.5870 * rgb[:,:,1] + 0.1140 * rgb[:,:,2]
    
    # different parameters are possible for conversion to grayscale
    # for convertion to grayscale:
    #(i[0]*0.299+i[1]*0.587+i[2]*0.114) ### Rec. 609-7 weights
    #(i[0]*0.2125+i[1]*0.7174+i[2]*0.0721) ### Rec. 709-6 weights
    return np.uint8(gray)


all_paths = glob.glob("./Handy Drawings/*.png")
Npics = len(all_paths)
cut = 128 
im0 = iio.imread(all_paths[0])
im0 = im0[cut:]
im0 = im0[0::3,0::3]
all_pics = np.zeros([Npics,*im0.shape[0:2]],dtype = 'uint8')
for i, im_path in enumerate(all_paths):
     im = iio.imread(im_path)
     im = im[cut:]
     im = im[0::3,0::3]
     im = rgb2gray(im)
     all_pics[i] = im
     print(i)
     # do whatever with the image here
     break 


Nr, Nc = im.shape

plt.imshow(im,cmap='gray', vmin = 0, vmax = 255)
plt.show()
all_pics = all_pics.reshape(Npics,-1)
# Transpose for faster computation
all_pics = all_pics.T
# --- do the POD -----
A, phi, umean, lamb = do_POD(all_pics)
#phi = phi.T
# number of pixels length of vector
N0 = all_pics.shape[0]
#
u_tilde = do_reconstruct(phi[-2:],A,Nmodes=200,umean = umean[-2:]) 
#u_tilde = u_tilde.T 
u_tilde = u_tilde.reshape(u_tilde.shape[0],Nr,Nc)
u_tilde = np.uint8(u_tilde)

for i in range(1,6):
    u_tilde = do_reconstruct(phi[-1],A,Nmodes=57*i,umean = umean[-1]) 
    u_tilde = u_tilde.reshape(u_tilde.shape[0],Nr,Nc)
    u_tilde = np.uint8(u_tilde)
    plt.figure()
    plt.imshow(u_tilde[0],cmap='gray',vmin=0,vmax=255)
    plt.title(str(int(57*i)))
#np.savez("allpicsPOD_snaps.npz",A = A, phi=phi,umean = umean,lam=lam)

# data  = np.load("allpicsPOD_snaps.npz")
# A     = data["A"]
# phi   = np.uint8(data["phi"])
# umean = data["umean"]
#all_pics_tilde = do_reconstruct(A, phi,umean=umean)

# save the data
# np.savetxt("Parameters.txt", phi)
# np.savetxt("Modes.txt", A)
# np.savetxt("Mean.txt", umean)
