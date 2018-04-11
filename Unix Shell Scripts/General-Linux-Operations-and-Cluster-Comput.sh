############################################################################
# General Discovery Usage
# By: David Chen
# Notes:
# 1. For Windows OS, Cygwin is one of the apps that resembles Mac Terminal
# 2. All identifiable information have been removed.
############################################################################

#--------------------------LOGIN--------------------------
ssh -Y USER_NAME@CLUSTER.INSTITUTION.EDU #may differ between Mac & Windows

ls #list all files
pwd #get the current folder
mkdir CLUSTER-PATH
cd .. #parent dir

#--------------------------CHECK FILE PERMISSIONS--------------------------
## Check current permission status:
ls -dl <dir> #check permission for 1 directory
ls -al #check permission of all files in a directory

## Give the owner permission to read r, write w, and execute x:
chmod u=rwx <file or dir>

## Deny permission for group g and others o to read r, write w, or execute x:
chmod go-rwx file <file or dir>

## Give everyone permission to execute:
chmod a+x <file or dir>

## For more info, check out:
man chmod

##--------------------------UPLOAD FILES TO CLUSTER--------------------------
## In your **local** environment (not cluster!!!), transfer files to cluster:
## You can open a new tab in MacOS terminal by Ctrl + T
## After running the commands below, you'll be prompted for password.
## Alternatively, you can use third-party software (e.g. Cyberduck) for file transfer
scp <LOCAL-PATH-TO-YOUR-SCRIPT/clusterComput.pbs> <USER_NAME@CLUSTER.INSTITUTION.EDU:~/CLUSTER-PATH>
scp <LOCAL-PATH-TO-YOUR-SCRIPT/YOUR_SCRIPT.R> <USER_NAME@CLUSTER.INSTITUTION.EDU:~/CLUSTER-PATH>
scp <LOCAL-PATH-TO-YOUR-SCRIPT/YOUR_SCRIPT.R> <USER_NAME@CLUSTER.INSTITUTION.EDU:~/CLUSTER-PATH>

## Back to cluster:
cd /CLUSTER-PATH
ls
more clusterComput.pbs #check
more YOUR_SCRIPT.R #check
## If you need to make changes:
nano YOUR_SCRIPT.R
nano clusterComput.pbs
# gedit YOUR_SCRIPT.R #alternative text editor

##--------------------------SUBMIT JOBS TO QUEUE--------------------------
## It may be wise to test your job interactively first:
tnodeload #check node
ssh NODE-NAME
cd /CLUSTER-PATH
Rscript YOUR_SCRIPT.R
exit

## When everything seems working, submit your job in the queue
cd /CLUSTER-PATH
ls #make sure relevant files are present
qshow
qsub clusterComput.pbs
myjobs
