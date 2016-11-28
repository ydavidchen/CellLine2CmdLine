##########################################
# Visualization of QIAGEN PyroMark 
##########################################
## BEFORE LOADING INTO R, DO THE FOLLOWING ##
# 1) Export your data as a .TXT file
# 2) On a Windows or Mac OS, paste the .TXT file into a 
# 3) Use the "Text to Column" feature to split the pasted column into multiple columns.

setwd("YOUR DIRECTORY HERE") ## replace w/ your working directory
getwd() ## check
GENE <- read.csv("YOUR_FILE.csv", skip=2) ##pyromark output has 2 empty lines before the header

## SUMMARY TABLE ##
GENE.mean <- aggregate(GENE$Methylat~GENE$Sample,FUN = mean)
GENE.sd <- aggregate(GENE$Methylat~GENE$Sample,FUN = sd)
GENE.summary <- merge(GENE.mean, GENE.sd, by='GENE$Sample')
colnames(GENE.summary) <- c("ID", "mean", "sd")

# Determine which samples' SDs are greater than x% of their means:
THADASummary$percent_deviation <- NA ##initialize
for(i in 1:nrow(THADASummary)){
  THADASummary$percent_deviation[i] <- round(THADASummary$sd[i] / THADASummary$mean[i], 2)
}
x <- 0.05 ##set your own threshold
THADASummary$ID[THADASummary$percent_deviation >= x]

## PLOT WITH ERROR BAR ##
library(ggplot2)
ggplot(data = GENE.summary, aes(x = as.factor(ID), y = mean)) +
  ##data:
  geom_bar(stat = "identity") +
  
  ##error bars & labels for nonzero values only only:
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = 0.2, position = position_dodge(0.9)) + 
  
  ## title & axis labels:
  labs(x='',y='% methylation',title='YOUR TITLE HERE') +
  
  ## add text above bars:
  geom_text(data=THADASummary,aes(label=round(mean,2)), vjust=-2.5) + ##vjust: farther AWAY from the error bar
  
  ## configure theme layer:
  theme(axis.text=element_text(size=12), axis.title=element_text(size=15,face="bold")) +  
  theme_bw()

