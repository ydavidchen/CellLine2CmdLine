## Comparison of pyrosequencing data vs. array 450k data

rm(list=ls())

#---------------------------------------Load & clean up pyrosequencing data---------------------------------------
my_dir <- "YOUR_DIRECTORY_HERE"
setwd(my_dir)

GENE <- read.csv("YOUR_FILE", skip=2, stringsAsFactors=F)
GENE <- GENE[ , 1:10] #the 1st CpG is of interest

## Correct typo / inconsistency in Sample ID:

## Pass the function `mean` and `sd` to the data frame:
GENE.mean <- aggregate(GENE$Methylation.... ~ GENE$Sample.ID, FUN=mean)
colnames(GENE.mean) <- c("ID", "mean") #update column name

GENE.sd   <- aggregate(GENE$Methylation.... ~ GENE$Sample.ID, FUN=sd)
colnames(GENE.sd ) <- c("ID", "sd") #update column name

GENE.summary <- merge(GENE.mean, GENE.sd, by="ID") #merge by the "ID" column

## Data visualization with error bars: 
library(ggplot2)
my_title <- "ENTER A TITLE"
ggplot(data=GENE.summary, aes(x=ID, y=mean)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=0.2, position=position_dodge(0.9)) + 
  labs(x="", y="% methylation", title=my_title) +
  geom_text(data=GENE.summary,aes(label=round(mean,2)), vjust=-2.5) + ##vjust: text/number farther AWAY from the error bar
  theme_classic() +
  theme(axis.text.x=element_text(size=7.5, angle=45, hjust=1, face="bold"), axis.title=element_text(size=10), legend.position="top")

#---------------------------------------Load 450k data---------------------------------------
load("NDRI_5mC_betas_for_7_sites.RData")
dim(ndri_selected_betas)

## Load sample map:
samp_map <- read.csv("NDRI_map_with_barcode.csv", stringsAsFactors=F)

## Important step: Match column names using one of the methods below:
## Option 1: `match` function
## This function can be a bit confusing at first
## Be sure to understand how it works!
? match
match( samp_map$array_barcode, colnames(ndri_selected_betas) )
ndri_selected_betas <- ndri_selected_betas[ , match( samp_map$array_barcode, colnames(ndri_selected_betas)) ]

## Option 2: supply string-based identifier to select/reorder:
# ndri_selected_betas <- ndri_selected_betas[ , as.character(samp_map$array_barcode)]

## Option 3: In theory, you can also invert the beta-value matrix and use the `merge` function, 
## set the new column as row.names,
## drop 2 extra columns, 
## and then invert the matrix back.
## But this approach involves more steps and too excessive.

## IMPORTANT: Use one of the following to check if the output is `TRUE` before continuing:
all.equal( samp_map$array_barcode, colnames(ndri_selected_betas) )
all( samp_map$array_barcode == colnames(ndri_selected_betas) )
identical( samp_map$array_barcode, colnames(ndri_selected_betas) ) #this method is a stronger condition, as you need to keep the class to be the same

## AFTER you reordered and made sure correct, update the column names
colnames(ndri_selected_betas) <- samp_map$X

## Select CpG:
my_CpG <- "YOUR CpG HERE"
array450k.sele <- ndri_selected_betas[my_CpG, , drop=FALSE] #since you'll have only 1 row, add `drop=FALSE` to maintain a matrix-like structure
array450k.sele <- as.data.frame( t(array450k.sele) )
array450k.sele$ID <- rownames(array450k.sele)
array450k.sele$ID <- paste("NDRI", array450k.sele$ID)

## Check if all samples (not QIAGEN controls) are present
## If not, go back to double-check your data matrices to see if there're any data entry errors
## Correct any typos & inconsistencies the pyrosequencing sample names, if needed
sum( array450k.sele$ID %in% GENE.summary$ID )
GENE.summary$ID[! GENE.summary$ID %in% array450k.sele$ID]

## Execute merge:
joint_table <- merge(array450k.sele, GENE.summary, by="ID")
colnames(joint_table)[colnames(joint_table) %in% c("YOUR CpG Here","mean")] <- c("array450k", "pyroseq")

#---------------------------------------Comparison by linear regression---------------------------------------
## Scatter plot:
ggplot(joint_table, aes(x=array450k, y=pyroseq)) +
  geom_jitter() +
  geom_smooth(method="lm", se=FALSE) + #add trendline
  theme_classic() +
  # scale_x_continuous(expand=c(0,0)) +
  # scale_y_continuous(expand=c(0,0)) +
  labs(x="450k (beta-value)", y="pyrosequencing (% methylation)", title=my_title)

## Statistical test:
## Record P-value and R-squared:
fit <- lm(joint_table$array450k ~ joint_table$pyroseq)
summary(fit)
