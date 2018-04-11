#######################################################################################
# Visualization of QIAGEN PyroMark Analysis Results: ZNF217 as example
# Script author: David Chen
# Date: 07/28/2017
# Notes:
#######################################################################################

#--------------------------------Clean up the parsed instrument data--------------------------------
## Load pyrosequencing CpG results:
GENE <- read.csv("ZNF217_parsed_data.csv", skip=2, stringsAsFactors=FALSE) #note: PyroMark output has 2 empty lines before the header

## Select columns that correspond to your CpG of interest:
## Here, use columns corresponding to Pos1 as an example
GENE <- GENE[ , 1:10]

## Update the sample name that was mis-spelled:
GENE$Sample.ID[GENE$Sample.ID=="Unmetyl. Conv."] <- "Unmethyl. Conv."
GENE$Sample.ID[GENE$Sample.ID=="Methl. Conv."]   <- "Methy. Conv."
GENE$Sample.ID[GENE$Sample.ID=="Methyl. Conv."]  <- "Methy. Conv."

#--------------------------------Calculate summary statistics--------------------------------
## Pass the function `mean` and `sd` to the data frame:
?aggregate #read the descriptions
GENE.mean <- aggregate(GENE$Methylation.... ~ GENE$Sample.ID, FUN=mean)
colnames(GENE.mean) <- c("ID", "mean") #update column name

GENE.sd   <- aggregate(GENE$Methylation.... ~ GENE$Sample.ID, FUN=sd)
colnames(GENE.sd ) <- c("ID", "sd") #update column name

?merge #useful function
GENE.summary <- merge(GENE.mean, GENE.sd, by="ID") #merge by the "ID" column

## Determine which samples' SDs are greater than x % of their averages:
GENE.summary$percent_deviation <- NA #initialize a column
for(i in 1:nrow(GENE.summary)){
  GENE.summary$percent_deviation[i] <- round(GENE.summary$sd[i] / GENE.summary$mean[i], 2)
}
x <- 0.05 #set your own threshold
print( GENE.summary$ID[GENE.summary$percent_deviation >= x] )

#--------------------------------Data visualization with error bars--------------------------------
library(ggplot2)
title <- "ZNF217 pyrosequencing" #update as necessary

## You can learn more about the "layered" ggplot2 grammar online or a book in lab
ggplot(data=GENE.summary, aes(x=ID, y=mean)) +
  ## Mean methylation as bar height:
  geom_bar(stat="identity") +
  
  ## Error bars & labels for nonzero values only only:
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=0.2, position=position_dodge(0.9)) + 
  
  ## Axis labels & text:
  labs(x="", y="% methylation", title=title) +
  
  ## Add text above bars:
  geom_text(data=GENE.summary,aes(label=round(mean,2)), vjust=-2.5) + ##vjust: text/number farther AWAY from the error bar
  
  ## Configure theme layer:
  theme(axis.text=element_text(size=12), axis.title=element_text(size=15,face="bold")) +  
  
  ## Use a background with less ink:
  theme_classic()