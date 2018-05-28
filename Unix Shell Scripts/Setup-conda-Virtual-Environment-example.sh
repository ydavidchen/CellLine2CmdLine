#!/bin/bash
# file: condaEnvironmentSetup.sh

## BEFORE SETUP
[ydchen@discovery ~]$ df /ihome/ydchen #check disk quota
[ydchen@discovery ~]$ tnodeload #check
[ydchen@discovery ~]$ ssh x01 #select node

[ydchen@x01 ~]$ module avail
[ydchen@x01 ~]$ module load python/3.6-Miniconda
[ydchen@x01 ~]$ conda search "^python$" #list of all available, with default indicated
[ydchen@x01 ~]$ conda create --name DeepLearning3 python=3.6.1
# Proceed ([y]/n)? y ...

[ydchen@x01 ~]$ source activate DeepLearning3

## Part 2: Install python packages
(DeepLearning3) [ydchen@x01 ~]$ conda install -c anaconda mkl #also installs numpy, scikit-learn, scipy
(DeepLearning3) [ydchen@x01 ~]$ conda install mkl-service #also required
(DeepLearning3) [ydchen@x01 ~]$ conda install pandas
(DeepLearning3) [ydchen@x01 ~]$ conda install -c conda-forge keras

## AFTER SETUP
## Part 3: Use the conda virtual environment
# [ydchen@x01 ~]$ module load python/3.6-Miniconda
# [ydchen@x01 ~]$ source activate DeepLearning3
# (DeepLearning3) [ydchen@x01 ~]$ python3
# ...
# (DeepLearning3) [ydchen@x01 ~]$ source deactivate DeepLearning3 #deactivate after use
# [ydchen@x01 ~]$

## Part 4: Permanently delete the environment
# conda env remove --name DeepLearning3
# Proceed ([y]/n)? y
