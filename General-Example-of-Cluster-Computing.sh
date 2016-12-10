#######################################################################
# A Genera Example of Cluster Computing: On Test Nodes
# Script author: David Chen
# Date: 12/06/2016
# Note:
# 1. This is a general script
# 2. All identifiable information have been replaced with words in CAPS.
# 2. The R script to run is named "rExample.R".
# 3. TEST_NODE is a test node.
#######################################################################

#----------------------------Log into computer cluster ---------------------------------------
## Login to your cluster account via command line.
## Login via Cyberduck (or similar software) for easy file transfer.
## (Optional) Check the box "store in keychain" will keep you logged in.
## Upload R script into the /bin sub-directory by dragging into Cyberduck (or similar software).
## Upload a folder of data set in the directory above /bin.

#----------------------------Preparations of cluster workspace---------------------------------------
## Make a folder with the same name as your user name (for easy identification):
cd
mkdir USER_NAME

## Set permissions of your files:
chmod u+rx USER_NAME/
ls -la #view permissions

## (Use as needed) To edit your R script (e.g. update paths):
cd
gedit bin/rExample.R #Script in gedit text editor will open

#------------------------Getting ready to run cluster job interactively---------------------
## User a protected file transfer tool to conveniently upload your data.
## "myDataFolder" here is a directory where my data files are stored.

[USER_NAME@CLUSTER myDataFolder]$ tnodeload
## Node   			Users   Load  Memory   Scratch   Speed     Max              Chip Set
## TEST_NODE1      2    1.99   62.2G     779G    3.0GHz   2.4GHz   AMD Opteron(tm) Processor 4284
## TEST_NODE2      0    0.12   64.1G     779G    3.0GHz   2.4GHz   AMD Opteron(tm) Processor 4284
## TEST_NODE3      1    0.16   63.9G     778G    3.0GHz   2.4GHz   AMD Opteron(tm) Processor 4284

[USER_NAME@CLUSTER myDataFolder] ssh TEST_NODE #switch to test node

#------------------------------Loading & setting Modules------------------------------------
# Loading & Setting default modules
[USER_NAME@TEST_NODE ~]$ m list
## Currently Loaded Modulefiles:
##  1) modules                3) java/1.7               5) null
##  2) R/3.2.5                4) intel-compilers/13.0

## R/3.2.5 isn't the current version. Permanently switch to R/3.3.1
[USER_NAME@TEST_NODE ~]$ m list # tells what you have loaded
[USER_NAME@TEST_NODE ~]$ m rm R # IMPORTANT: unload the module first
[USER_NAME@TEST_NODE ~]$ m add R/3.3.1 # added to your configuration file, as the default
## `m add` actually edits the .bashrc script

# .bashrc
###########################################
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

m add R/3.3.1
m add python/3.5
m add matlab/r2016a
m add tophat/2.1.0
m add bowtie/2.2.7
m swap java/1.7 java/1.8
###########################################

[USER_NAME@TEST_NODE ~]$ m list
## Currently Loaded Modulefiles:
##  1) modules                4) intel-compilers/13.0   7) tophat/2.1.0
##  2) R/3.3.1                5) null                   8) bowtie/2.2.7
##  3) java/1.8               6) matlab/r2016a

#------------------------------Interactively run jobs------------------------------------
[USER_NAME@TEST_NODE ~]$ Rscript bin/rExample.R
## If you run this and the network goes down or you shutdown terminal, you job get killed!

## To exit while job is running: Use `screen` (robust approach) or `nohup` (quick & dirty)
[USER_NAME@TEST_NODE ~]$ time Rscript bin/rExample.R ## & not needed; tells you how much time it took on a test node
[USER_NAME@TEST_NODE ~]$ nohup Rscript bin/rExample.R & # Preface w/ `nohup` and end w/ `&`
[USER_NAME@TEST_NODE ~]$ nohup time Rscript bin/rExample.R  #Even fancier operation
