############################################################################
# Download data from Genomic Data Commons (GDC) to cluster or local
############################################################################

## Log into cluster:
ssh -Y <your credential here>

## Upload gdc-client file to cluster (your home directory)
## Then:
cd ~ #home directory
ls #the GDC Client Transfer Tool should be present
## gdc-client

if [ ! -f ~/gdc-client]
then
  echo "File does not exist!"
fi

if [! -d ~/storage_path]:
then
  mkdir mkdir storage_path
else
  echo "Directory already exists! No need to create it."

mkdir storage_path
## Upload gdc_manifest_20170624_200523.txt to this directory

~/gdc-client download -m ~/storage_path/gdc_manifest_20170624_200523.txt
## Download will start
