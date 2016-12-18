####################################################################
# Quick Visualization of ELISA by Heat Map
# David Chen
# Date Created: 02/16/2016
# Date Modified: 12/18/2016
# Notes:
# 1. This is an executable example.
# 2. Real data instrument file from 600-nm is included.
# 3. Precise sample names and treatment information are not included.
####################################################################

## Load raw instrument data (.txt) from SoftMaxPro illuminescent plate reader:
myELISA <- read.csv("01-example-ELISA-instrument-data.txt", sep="\t", skip=3, header=FALSE)
View(myELISA) #check

## Clean up your ELISA data.frame
## There may be variations in 
myELISA <- myELISA[-c(1,2,11:nrow(myELISA)), -c(1,2,15:ncol(myELISA))]
myELISA <- as.matrix(myELISA)
mode(myELISA) <- "numeric"
rownames(myELISA) <- paste0("Sample_", LETTERS[1:nrow(myELISA)])
colnames(myELISA) <- paste0("Dose_", letters[1:ncol(myELISA)])

## Other heatmap packages can be used
## For example, heatmap3, pheatmap
library(gplots)
heatmap.2(myELISA, col=greenred(128), 
          dendrogram=NULL, tracecol=NA, 
          Rowv=FALSE, Colv = FALSE, 
          margins = c(7.5,7.5),
          key.title = NA, key.ylab="", key.xlab="Fluorescence",
          main='ELISA', xlab='Increasing dose in nM')

## The resulting heat map should have the same order as your ELISA plate.