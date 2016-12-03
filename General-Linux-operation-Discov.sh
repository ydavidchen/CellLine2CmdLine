#################################################
# General Script for Discovery Use
# Contributors: T. Zhao (auth.); D. Chen (ed.)
# Notes:
# 1. This script is for Mac OS terminal.
#################################################

## LOGIN ##
# If you haven't had a Research Computing account,
# you should apply through the institution.
# Depending on your operating system, you m
ssh -Y USER_NAME@discovery.dartmouth.edu

cd /YOUR_DIRECTORY #change the folder directory

ls #list all files

pwd #get the current folder

mkdir Data
cd Data/
rm NO-LONGER-NEEDED-DIR  #remove the file

cd .. #go to parent directory
mkdir Scripts
cd Scripts/

## SUBMIT JOBS TO DISCOVERY ##
cp for_discovery.R /YOUR_DIRECTORY/Scripts/ #Copy file to the target folder

cd ..
mkdir Figures/ #new folders for figures
cd Scripts/
qshow #check status of Discovery cluster
qsub for_discovery.R #submit your job

## USING R ON DISCOVERY ##
cd .. #return to your project directory
R

## VIEW CODE USING DEFAULT EDITOR ##
cd /DIRECTORY-OF-INTEREST
nano YOUR_SCRIPT.R #view the code use ctrl+x for quit
