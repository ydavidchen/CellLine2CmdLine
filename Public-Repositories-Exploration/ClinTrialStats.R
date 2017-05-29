######################################################
# Descriptive Statistics of Clinical Trials
# Data can be downloaded from clinicaltrials.gov
######################################################

library(ggplot2)
library(gridExtra)
library(stringr)

# trial <- read.csv("~/repos/Bench2Bioinfo/Public-Repositories-Exploration/ClinTrialStats_temodar.csv", row.names = NULL)
# trial <- read.csv("~/repos/Bench2Bioinfo/Public-Repositories-Exploration/ClinTrialStats_cisplatin.csv", row.names=NULL)
trial <- read.csv("~/repos/Bench2Bioinfo/Public-Repositories-Exploration/ClinTrialStats_cyclophosphamide.csv", row.names=NULL)

sum(is.na(trial$Start.Date)) #check
trial$Start_Year <- str_sub(trial$Start.Date, -4, -1)

## Simple baplot:
barplot(
  table(trial$Start_Year), las=2, border=F,
  xlab = "Year",
  ylab = "Number of trials",
  main = "Number of Trials with keyword"
)

## ggplot2: Year
year.mat <- as.data.frame(table(trial$Start_Year), stringsAsFactors=F)
p1 <- ggplot(year.mat, aes(x=factor(Var1), y=Freq)) + 
  geom_bar(stat="identity") +
  theme_bw() + 
  labs(title="Number of trials with keyword 'cyclophosphamide'", x="") + 
  scale_y_continuous(expand=c(0,0), limits=c(0,250)) +
  theme(axis.text.x=element_text(size=10, angle=45, hjust=1, face="bold"), axis.title=element_text(size=10))

## Phases
phase.mat <- as.data.frame(table(trial$Phases), stringsAsFactors=F)
phase.mat$Var1[phase.mat$Var1==""] <- "(unlabeled)"
p2 <- ggplot(phase.mat, aes(x=factor(Var1), y=Freq)) + 
  geom_bar(stat="identity") +
  labs(x="", title="Distribution of type of trials since 1976, cyclophosphamide") + 
  scale_y_continuous(expand=c(0,0), limits=c(0,2000)) +
  theme_bw() + 
  theme(axis.text.x=element_text(size=10, angle=45, hjust=1, face="bold"), axis.title=element_text(size=10))

grid.arrange(p1, p2, ncol=1)
