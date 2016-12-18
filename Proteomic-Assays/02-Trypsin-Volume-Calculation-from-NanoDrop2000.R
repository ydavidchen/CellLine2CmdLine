###########################################################################
# Computing Trpsin Volume for Protein Digestion for Mass Spectrometry 
# Script Author: David Chen
# Date: 12/14/2016
# Notes:
# 1. This script shows a spefic example.
# 2. NanoDrop data was exported as .tsv file
###########################################################################

## Save your NanoDrop reading as a .tsv file. 

## Check your instrument files:
setwd("repos/Lab-Instrument-Data/DavidChen/") #Update with your directory
list.files() #check files

## Process the data.frame:
ProteinConc121416 <- read.table("121416concentrations-DC.tsv", sep="\t")
ProteinConc121416$V1 <- NULL
ProteinConc121416$V3 <- NULL
colnames(ProteinConc121416) <- c("Sample", "Time", "Conc", "Unit", "A562(abs)")
rownames(ProteinConc121416) <- ProteinConc121416$Sample

## Add a column that represents the dilution, based on the sample name entered:
ProteinConc121416$Dilution <- NA
for(i in 1:nrow(ProteinConc121416)){
  if(grepl("1.2", ProteinConc121416$Sample[i]) == TRUE) ProteinConc121416$Dilution[i] <- "1:2"
  if(grepl("1.5", ProteinConc121416$Sample[i]) == TRUE) ProteinConc121416$Dilution[i] <- "1:5"
}

## Scale 1:2 dilutions by factor of 2; 
## Scale 1:5 dilutions by factor of 5: 
ProteinConc121416$ScaledConc <- NA
for(i in 1:nrow(ProteinConc121416)){
  if(ProteinConc121416$Dilution[i] == "1:2") ProteinConc121416$ScaledConc[i] <- ProteinConc121416$Conc[i] * 2
  if(ProteinConc121416$Dilution[i] == "1:5") ProteinConc121416$ScaledConc[i] <- ProteinConc121416$Conc[i] * 5
}

## Average all cell lines:
hela <- ProteinConc121416[grep("hela", ProteinConc121416$Sample, ignore.case = T), ]
lc <- ProteinConc121416[grep("lc1", ProteinConc121416$Sample, ignore.case = T), ]
mcf <- ProteinConc121416[grep("mcf", ProteinConc121416$Sample, ignore.case = T), ]
cal <- ProteinConc121416[grep("cal", ProteinConc121416$Sample, ignore.case = T), ]

## Compute mean, and scale: 
## Hela & LC1 cell lysates were prepared in 1X volume. Multiple by 1.
## MCF7 and Cal50 cell lysates were prepared in 0.4X volume. Multiply by 0.4
myData <- data.frame(
  hela_mean = mean(hela$ScaledConc) * 1,
  lc_mean = mean(lc$ScaledConc) * 1,
  mcf_mean = mean(mcf$ScaledConc) * 0.4,
  cal_mean=mean(cal$ScaledConc) * 0.4
)

## Volumes of trpsin to add:
myData / 100 * 2.5 *1000
