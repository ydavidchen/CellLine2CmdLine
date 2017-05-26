######################################################
# Descriptive Statistics of Clinical Trials
# Data can be downloaded from clinicaltrials.gov
######################################################

library(ggplot2)
library(gridExtra)
library(stringr)

temodar <- read.csv("~/repos/Bench2Bioinfo/Public-Repositories-Exploration/ClinTrialStats_temodar.csv", row.names = NULL)
sum(is.na(temodar$Start.Date)) #check
temodar$Start_Year <- str_sub(temodar$Start.Date, -4, -1)
barplot(
  table(temodar$Start_Year), las=2, border=F,
  xlab = "Year",
  ylab = "Number of trials",
  main = "Number of Trials with keyword 'Temodar'"
)
## Year
year.mat <- as.data.frame(table(temodar$Start_Year), stringsAsFactors=F)
p1 <- ggplot(year.mat, aes(x=Var1, y=Freq)) + 
  geom_bar(stat="identity") +
  theme_bw() + 
  labs(title="Number of trials with keyword 'Temodar'", x="") + 
  scale_y_continuous(expand=c(0,0), limits=c(0,80)) +
  theme(axis.text.x=element_text(size=10, angle=45, hjust=1, face="bold"), axis.title=element_text(size=10))

## Phases
phase.mat <- as.data.frame(table(temodar$Phases), stringsAsFactors=F)
phase.mat$Var1[phase.mat$Var1==""] <- "(unlabeled)"
p2 <- ggplot(phase.mat, aes(x=Var1, y=Freq)) + 
  geom_bar(stat="identity") +
  labs(x="", title="Distribution of type of trials since 1997") + 
  scale_y_continuous(expand=c(0,0), limits=c(0,400)) +
  theme_bw() + 
  theme(axis.text.x=element_text(size=10, angle=45, hjust=1, face="bold"), axis.title=element_text(size=10))

grid.arrange(p1, p2, ncol=1)
