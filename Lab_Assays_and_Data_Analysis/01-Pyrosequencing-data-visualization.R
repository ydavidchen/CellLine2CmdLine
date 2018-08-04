#######################################################################################
# Visualization of QIAGEN PyroMark Analysis Results
# Script author: David Chen
# Date: 08/02/2016

## BEFORE LOADING DATA INTO R, DO THE FOLLOWING ##
# 1) Export your data as a .TXT file
# 2) On a Windows or Mac OS, paste the .TXT file into a spreadsheet
# 3) Use the "Text to Column" feature to split the pasted column into multiple columns.
#######################################################################################

## Load pyrosequencing CpG results:
my_dir <- "YOUR DIRECTORY HERE"
setwd(my_dir) #replace w/ your working directory
GENE <- read.csv("YOUR_FILE.csv", skip=2) #note: PyroMark output has 2 empty lines before the header

## Calculate summary statistics:
GENE.mean <- aggregate(GENE$Methylat ~ GENE$Sample, FUN=mean)
GENE.sd   <- aggregate(GENE$Methylat ~ GENE$Sample, FUN=sd)
GENE.summary <- merge(GENE.mean, GENE.sd, by='GENE$Sample') #join 2 data.frames
colnames(GENE.summary) <- c("ID", "mean", "sd") #update column names

# Determine which samples' SDs are greater than x % of their averages:
GENE.summary$percent_deviation <- NA ##initialize
for(i in 1:nrow(GENE.summary)){
  GENE.summary$percent_deviation[i] <- round(GENE.summary$sd[i] / GENE.summary$mean[i], 2)
}
x <- 0.05 #set your own threshold
print( GENE.summary$ID[GENE.summary$percent_deviation >= x] )

## Visulize mean methylation with error bars:
library(ggplot2)
ggplot(data=GENE.summary, aes(x=as.factor(ID), y=mean)) +
  ## Mean methylation as bar height:
  geom_bar(stat="identity") +
  
  ## Error bars & labels for nonzero values only only:
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=0.2, position=position_dodge(0.9)) + 
  
  ## title & axis labels:
  labs(x="", y="% methylation", title="YOUR TITLE HERE") +
  
  ## add text above bars:
  geom_text(data=GENE.summary,aes(label=round(mean,2)), vjust=-2.5) + ##vjust: farther AWAY from the error bar

  ## theme
  theme_bw() +
  
  ## configure theme layer:
  theme(axis.text=element_text(size=12), axis.title=element_text(size=15,face="bold"))
