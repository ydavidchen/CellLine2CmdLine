# Example script: Determine MDAMB468 MLPA status
# Script author: David Chen
# Notes:
# -- The training set were assembled based on the manufacturer's guidelines online

library(pamr);
library(pheatmap);
library(ggplot2);
library(reshape2);

## Customize/update the following as needed:
TRAIN_DATA_PATH <- "./MLPA-training-set-assembled/trainSet_analyzed.txt"; 
EXP_RES_PATH <- "./data/110117_MDAMB468_CN_matrix.txt";
EXPORT_FILE_PATH <- "./MDAMB468_MLPA_scores.csv";
PLOT_THEME <- theme_classic() +
  theme(axis.text=element_text(size=15, angle=45, hjust=1, face="bold"), 
        axis.title=element_text(size=15)); 

#---------------------------------(Optional) Visualization of PCR amplification status---------------------------------

#################################################################################################################
## Load the Training Set: **DO NOT EDIT!**
trainSet <- read.table(TRAIN_DATA_PATH, header=TRUE, sep="\t");
rownames(trainSet) <- trainSet$X; #assign probe names
dim(trainSet)[2]
#################################################################################################################

## Load the Test Set:
data <- read.csv(EXP_RES_PATH, sep="\t", header=TRUE);
print(dim(data)[2] - 2); #number of samples
stopifnot( all(!is.na(data[-1, -c(1,2)])) ); #checkpoint: ensure no missing values
rownames(data) <- data$X;
data <- as.matrix(data[-1, -c(1,2)]);
mode(data) <- "numeric";
data[is.na(data)] <- 0;
colnames(data) <- gsub("X", "", colnames(data), ignore.case=F)

## Generate sample annotation matrix based on col.names:
heat_annot <- data.frame(
  row.names = colnames(data),
  sample_type = rep(NA, times=ncol(data))
); 
heat_annot$sample_type[grepl("MDAMB468", rownames(heat_annot))] <- "TNBC cells";
heat_annot$sample_type[! grepl("MDAMB468", rownames(heat_annot))] <- "Controls";
View(heat_annot)

## Plot heat map for samples:
## If your screen size is too small, you can export as A4 pdf, landscape
pheatmap(
  data,
  annotation_col = heat_annot, 
  fontsize = 7.5, #default = 10
  border_color = NA,
  main = "Relative copy number of 48 BRCA1ness-MLPA probes for MDA-MB-468"
)

#---------------------------------Classification by PAMR Classifier---------------------------------

#################################################################################################################
## Load the Training Set **DO NOT EDIT!**:
pamrB1excel <- pamr.from.excel(TRAIN_DATA_PATH, 52, sample.labels=TRUE, batch.labels=FALSE);
## Read in  48 genes
## Read in  50 samples
## Read in  50 sample labels
pamr_b1_vs_spor.train <- pamr.train(pamrB1excel); #training-set object
#################################################################################################################

## Load the Test Set, i.e. your results
pamrB1exceltest <- pamr.from.excel(EXP_RES_PATH, ncols=ncol(data)+2, sample.labels=T, batch.labels=F);
pamrB1exceltest$x[is.na(pamrB1exceltest$x)] <- 0;
test_predict <- pamr.predict(pamr_b1_vs_spor.train, pamrB1exceltest$x, threshold=0);

table(pamrB1exceltest$y, test_predict); #preview
test_predict <- pamr.predict(pamr_b1_vs_spor.train, pamrB1exceltest$x, threshold=0, type="posterior");
print(test_predict); 

## Assemble into R data.frame:
output <- data.frame(
  row.names = pamrB1exceltest$samplelabels, 
  test_predict
);
mode(output$BRCA1_Like) <- "numeric";
mode(output$Sporadic_Like) <- "numeric";

## Export:
write.csv(output, file=EXPORT_FILE_PATH, row.names=TRUE, quote=FALSE); 

#---------------------------------Data visualization using ggplot2---------------------------------
BRCAness_MLPA <- data.frame(
  Sample = rownames(output),
  BRCA1_Like = output$BRCA1_Like
);
BRCAness_MLPA$Sample <- gsub(".1", "", BRCAness_MLPA$Sample, fixed=TRUE);
BRCAness_MLPA$Sample <- gsub(".2", "", BRCAness_MLPA$Sample, fixed=TRUE);
BRCAness_MLPA$Sample <- gsub(".3", "", BRCAness_MLPA$Sample, fixed=TRUE);

summaryStats <- data.frame(
  sample.mean = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=mean)[ , 1], 
  mean = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=mean)[ , 2],
  sample.sd = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=sd)[ , 1], #serves as checkpoint
  sd = aggregate(BRCAness_MLPA$BRCA1_Like ~ BRCAness_MLPA$Sample, FUN=sd)[ , 2]
);
stopifnot( all(summaryStats$sample.mean == summaryStats$sample.sd) );
rownames(summaryStats) <- summaryStats$sample.mean;
summaryStats$sample.mean <- summaryStats$sample.sd <- NULL; 

ggplot(summaryStats, aes(x=rownames(summaryStats), y=mean)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=0.2, position=position_dodge(0.9)) +
  geom_hline(yintercept=0.50, color="red", linetype="dashed") + 
  labs(x="Sample ID", y="BRCA-like score (posterior probability)", title="MDAMB468 BRCAness-MLPA") +
  scale_x_discrete(expand=c(0, 0)) + #strip white space
  scale_y_continuous(breaks=seq(0,1,0.2), expand=c(0, 0), limits=c(0, 1.13)) + #set limit, tick-mark breaks, & strip white space
  annotate("text", x=2, y=0.55, label="Above 0.50: BRCA-like", colour="red") + 
  annotate("text", x=2,   y=0.3, label="Normal controls", colour="black") + 
  geom_segment(aes(x=0.6, xend=3.5, y=0.25, yend=0.25)) +
  PLOT_THEME
