##############################################################################
# Multiplex Ligation-dependent Probe Amplification (MLPA)
# Script author: David Chen
# Date: 06/29/2017
# Notes:
# 1. In this example, experiment is done in technical triplicate.
# 2. Place analyzed training set in the same working directory as your data.
##############################################################################

setwd("YOUR_WORKING_DIRECTORY")

#---------------------------------Visualization of PCR amplification---------------------------------
library(pheatmap)

## Load the Training Set: **DO NOT EDIT!**
trainSet <- read.table("trainSet_analyzed.txt", header=T, sep="\t")
rownames(trainSet) <- trainSet$X; #assign probe names
dim(trainSet)[2]

## Load the Test Set: **Update**
data <- read.csv("MLPA_CN_Matrix.txt", sep="\t", header=TRUE)
dim(data)[2]-2 #number of samples
which(is.na(data[-1, -c(1,2)])) #ensure no missing values
rownames(data) <- data$X
data <- as.matrix(data[-1, -c(1,2)])
mode(data) <- "numeric"
colnames(data) <- gsub("X", "", colnames(data), ignore.case=F)

## Plot heat map for samples:
## If your screen size is too small, you can export as A4 pdf, landscape
pheatmap(
  data,
  annotation_col = heat_annot, 
  fontsize = 7.5, #default = 10
  border_color = NA,
  main = "Regional copy number profile used for BRCA1ness classification"
)

#---------------------------------Classification by Pamr model---------------------------------
library(pamr)

## Load the Training Set **DO NOT EDIT!**:
pamrB1excel <- pamr.from.excel("trainSet_analyzed.txt", 52, sample.labels=TRUE, batch.labels= FALSE)
pamr_b1_vs_spor.train <- pamr.train(pamrB1excel) #training-set object

## Load the Test Set **Update with your data set**:
pamrB1exceltest <- pamr.from.excel("062917_CN_Matrix.txt", ncols=ncol(data)+2, sample.labels=T, batch.labels=F)

## Execute Pamr classifier:
test_predict <- pamr.predict(pamr_b1_vs_spor.train, pamrB1exceltest$x, threshold=0, type="posterior")
test_predict
output <- data.frame(
  row.names = pamrB1exceltest$samplelabels, 
  test_predict
)
mode(output$BRCA1_Like) <- "numeric"
mode(output$Sporadic_Like) <- "numeric"

#------------------------------------Data visualization------------------------------------
## Clean up & compute summary data first
BRCAness_MLPA <- data.frame(
  Sample = rownames(output),
  BRCA1_Like = output$BRCA1_Like
);

summaryStats <- data.frame(
  sample.mean = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=mean)[ , 1], 
  mean        = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=mean)[ , 2],
  sample.sd   = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=sd)[ , 1], #serves as checkpoint
  sd          = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=sd)[ , 2]
)
stopifnot( all(summaryStats$sample.mean == summaryStats$sample.sd) ) #checkpoint
rownames(summaryStats) <- summaryStats$sample.mean
summaryStats$sample.mean <- summaryStats$sample.sd <- NULL

## Barplot
## Again, exporting as A4 PDF is recommended
library(ggplot2)
ggplot(summaryStats, aes(x=rownames(summaryStats), y=mean)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=0.2, position=position_dodge(0.9)) +
  geom_hline(yintercept=0.50, color="red", linetype="dashed") + 
  labs(x="Sample ID", y="BRCA1-like score (posterior probability)") +
  scale_x_discrete(expand=c(0,0)) +
  scale_y_continuous(breaks=seq(0,1,0.2), expand=c(0,0), limits=c(0,1)) +
  theme_classic() +
  theme(axis.text.x=element_text(size=10, angle=45, hjust=1, face="bold"), axis.title=element_text(size=10)) + 
  annotate("text", x=2, y=0.55, label="Above 0.50: BRCA-like", colour="red")

#---------------------------------Export as spreadsheets---------------------------------
library(WriteXLS)
WriteXLS(
  x = list(summaryStats, output, as.data.frame(data)),
  row.names = TRUE,
  ExcelFileName = "BRCAness_MLPA_samples.xls",
  SheetNames = c("Summary", "Triplicate_Results", "Raw_Scores")
)