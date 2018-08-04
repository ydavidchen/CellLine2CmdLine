# Template Code for LIMMA Differential Analysis for DNA Methylation Measured by the 450K Array
# Script author: David Chen
# Script maintainer: David Chen

## Notes:
## `betas` is a matrix of beta-values with rows=CpGs, columns=Samples
## `sheet` is a patient covariate matrix with case-control status (Sample_Group), Age, and Sex as columns

rm(list=ls())
library(limma)
library(matrixStats)

## Load your data
# load(...)
# sheet <- read.csv(...)

## First, select 10,000 CpG loci with the greatest variance (across all samples)
## This approach reduces the number of statistical comparisons
k <- 1e4 #can choose a different number of CpGs
sele <- order(rowVars(betas), decreasing=TRUE)[1:k]
betas <- betas[sele, ]

## Transform to M-values:
mVals <- minfi::logit2(betas) #can also use: boot::logit(betas)

## Important checkpoint: Double check myDesign rows match with methylation data columns:
stopifnot(identical(as.character(sheet$Sample_Name), colnames(mVals)))

## Assemble the design matrix:
sheet$Status <- 1 * (sheet$Sample_Group == "Cases")
myDesign <- model.matrix( ~ Status + Sex + Age, data=sheet) #adjust as needed
myDesign #Make sure that column no.2 is named "Sample_Group1", not "Sample_Group0"

## Execute statistical tests:
fit <- lmFit(mVals, design=myDesign)
fit <- eBayes(fit)

## Subset 450K annotation & identify:
library(IlluminaHumanMethylation450kanno.ilmn12.hg19)
annotCpGs <- as.data.frame(getAnnotation(IlluminaHumanMethylation450kanno.ilmn12.hg19))

myCpGs <- annotCpGs[match(rownames(mVals),annotCpGs$Name), ]
DMPs <- topTable(
  fit,
  number = Inf, 
  coef = "Status1",
  genelist = myCpGs, 
  adjust.method = "fdr", 
  sort.by = "p"
)
