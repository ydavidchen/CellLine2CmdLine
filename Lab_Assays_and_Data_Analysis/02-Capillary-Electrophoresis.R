########################################################################
# PCR Product Fragmentation by Capillary Electrophoresis: Visualization
# Author & Maintainer: ydavidchen
# Date: 11/14/2016
########################################################################
# Load packages & dependencies:
library(seqinr)

#####################
## LOAD DATA FILES
#####################
myPath <- "" #fill in path to directory where .fsa files are stored
setwd(myPath)

# Check file names:
list.files()

#######################
## PLOT SPECTRA
#######################
trial <- list() ##initialize an empty list

# Feed the output spectra into a single PDF:
pdf("~/Downloads/capillary_electrophor.pdf") ##update file path/name/type as needed
## Other file types also available, for example:
## png("~/Downloads/capillary_electrophor.png")

for(i in 1:length(list.files(myPath))){
  fileName <- list.files(myPath)[i]
  trial[[fileName]] <- read.abif(fileName)
  plotabif(trial[[fileName]], main=fileName,col="blue")
}
dev.off()
