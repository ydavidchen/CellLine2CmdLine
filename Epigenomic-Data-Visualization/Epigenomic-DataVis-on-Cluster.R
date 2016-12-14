##############################################################################################
# Cluster Usage: Generate R object for data visualization by genomation
# Script author: David Chen (github.com/ydavidchen)
# Notes:
# 1a. On a test node loaded with , directy copy and paste the following code, 
# 1b. Alternatively, you can load via `Rscript` terminal command.
# 2. Part 1 of the script is to be run locally. Resulting objects are to be uploaded onto Cluster
##############################################################################################

#-------------------------------------Part 1: Data Download-------------------------------------
# # source("https://bioconductor.org/biocLite.R")
# # biocLite(c("rtracklayer", "GenomicRanges"))
# library(rtracklayer) #installed on Discovery default module
# library(GenomicRanges) #installed on Discovery default module
# 
# ## Speed up computation by using multiple cores:
# # install.packages("doParallel")
# library(doParallel)
# registerDoParallel(detectCores() - 1)
# 
# ## Download & import RRBS methylation data set as GRanges object:
# CD3_rrbs_path <- "http://egg2.wustl.edu/roadmap/data/byDataType/dnamethylation/RRBS/FractionalMethylation_bigwig/E033_RRBS_FractionalMethylation.bigwig"
# CD3_rrbs <- import.bw(CD3_rrbs_path)
# CD3_rrbs
# 
# ## Download & import histone .broadPeak data as GRanges object (standard approach):
# CD3_H3K27ac_path <- "http://egg2.wustl.edu/roadmap/data/byFileType/peaks/consolidated/broadPeak/E034-H3K27ac.broadPeak.gz"
# 
# ## Select columns (if your data file to read is narrowPeak, add `peak = "integer"` to the vector):
# extraCols <- c(singnalValue="numeric", pValue="numeric", qValue="numeric")
# CD3_broadPeak <- import(CD3_H3K27ac_path, format="BED", extraCols=extraCols)
# CD3_broadPeak
# 
# CD3_rrbs <- CD3_rrbs[seqnames(CD3_rrbs) == "chrX"]
# CD3_broadPeak <- CD3_broadPeak[seqnames(CD3_broadPeak) == "chrX"]
# 
# CD3_rrbs@elementMetadata$CommonCol <- CD3_rrbs@elementMetadata$score #common column
# CD3_rrbs@elementMetadata$score <- NULL
# CD3_rrbs #preview
# 
# CD3_broadPeak@elementMetadata$CommonCol <- CD3_broadPeak@elementMetadata$singnalValue #common column
# CD3_broadPeak@elementMetadata$singnalValue <- NULL
# CD3_broadPeak@elementMetadata$name <- NULL
# CD3_broadPeak@elementMetadata$score <- NULL
# CD3_broadPeak@elementMetadata$pValue <- NULL
# CD3_broadPeak@elementMetadata$qValue <-NULL
# CD3_broadPeak #preview
# 
# # source("https://bioconductor.org/biocLite.R") #installed temporarily on Discovery by DC
# # biocLite("TxDb.Hsapiens.UCSC.hg19.knownGene")
# library(TxDb.Hsapiens.UCSC.hg19.knownGene) #annotation package
# myPromoters <- promoters(TxDb.Hsapiens.UCSC.hg19.knownGene, upstream=500, downstream=500) #adjust as necessary
# 
# save(list=ls(), file="~/Downloads/my-R-objects-for-genomation.RData")
## Upload the object onto discovery. You may use a third-party software, or the command 
## scp "/Downloads/my-R-objects-for-genomation.RData" USER_NAME@YOUR_INSTITUTION_ADRESS:CLUSTER_PATH

#-------------------------------------Part 2: Cluster Generation of genomation Plotting Objects-------------------------------------
## The actual part of data vis is computationally intensive.
## Cluster computing may give you more memory usage...and off-line computation.
## Place your R object and this R script in the same Cluster directory
## Rscript Epigenomic-DataVis-on-Cluster.R

# source("https://bioconductor.org/biocLite.R")
# biocLite("genomation")
library(genomation)
library(GenomicRanges)
load("my-R-objects-for-genomation.RData")

## Define colors:
# install.packages("RColorBrewer")
library(RColorBrewer)
myCols <- brewer.pal(9, "Set1")

mySMlist <- ScoreMatrixList(
  targets = list(RRBS=CD3_rrbs, H3K27ac=CD3_broadPeak), 
  windows = myPromoters,
  strand.aware = TRUE, 
  weight.col = "CommonCol",
  is.noCovNA = TRUE #REQUIRED for data without complete coverage, like methylation
)

## Heat matrix for RRBS data:
heatMatrix(mySMlist[[1]], xcoords=c(-500, 500), xlab="Distance to transcription start (bp)", main = "chrX 5mC methylation by RRBS in CD3")

## Genomic Curve for H3K27ac data:
plotMeta(mySMlist[[2]], line.col=myCols[2], xcoords=c(-500, 500), xlab="Distance to transcription start (bp)", main="chrX H3K27ac by ChIP-seq in CD3")

## Save output for download:

save(list=c(myPromoters, mySMlist), file="my_genomation_workspace.RData")
