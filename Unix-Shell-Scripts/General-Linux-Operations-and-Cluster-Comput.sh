############################################################################
# General Script for Computer Cluster Use
# Contributors: T. Zhao (auth.); D. Chen (ed.)
# Notes:
# 1. This script is for Mac OS Terminal.
# 2. For Windows OS, Cygwin is one of the apps that resembles Mac Terminal
# 3. All identifiable information have been removed.
############################################################################

## LOGIN ##
# If you haven't had a Research Computing account,
# you should apply through the institution.
ssh -Y USER_NAME@CLUSTER.INSTITUTION.EDU #may differ between Mac & Windows

cd /YOUR_DIRECTORY #change the folder directory
ls #list all files
pwd #get the current folder

mkdir Data
cd Data/
rm NO-LONGER-NEEDED-DIR  #remove the file

cd .. #go to parent directory
mkdir Scripts
cd Scripts/

## SUBMIT JOBS TO CLUSTER ##
cp for_cluster.R /YOUR_DIRECTORY/Scripts/ #Copy file to the target folder

cd ..
mkdir Figures/ #new folders for figures
cd Scripts/
qshow #check status of the computer cluster
qsub for_cluster.R #submit your job

## USING R ON COMPUTER CLUSTER ##
cd .. #return to your project directory
R

## VIEW CODE USING DEFAULT EDITOR ##
cd /DIRECTORY-OF-INTEREST
nano YOUR_SCRIPT.R #view the code use ctrl+x for quit
