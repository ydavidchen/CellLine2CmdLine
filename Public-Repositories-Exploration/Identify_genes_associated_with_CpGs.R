#################################################################################################
# Proof of Concept: evaluate `missMethyl::getMappedEntrezIDs`'s consistency with annotation file
# Script Author: David Chen
# Date: 02/22/2017
# Notes:
# The goal of this script is is to evaluate to to which extent
# the function `missMethyl::getMappedEntrezIDs` agrees with the Illumina 850k/EPIC annotation.
#################################################################################################

#--------------------------Load annotation file--------------------------
library(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)
data(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)
annot.850k <- getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)
annot.850k <- as.data.frame(annot.850k@listData)

## As an example, let's focus on 1st n genes from methylationEPIC 850k annotation file:
n <- 100

#--------------------------## Method 1: Fetch gene names using missMethyl--------------------------
my_CpGs <- as.character(annot.850k$Name[1:n])
my_CpGs

## Conveniently retrive unique genes from CpG IDs
library(missMethyl)
res <- missMethyl::getMappedEntrezIDs(sig.cpg=NA, all.cpg = my_CpGs, array.type="EPIC")
res$universe ##Entrez gene IDs associated with CpGs

## Entrez genes to Hugo:
library(org.Hs.eg.db)
library(annotate)
my_genes <- getSYMBOL(res$universe, data="org.Hs.eg")
as.character(my_genes)
length(my_genes)

#--------------------------Method 2: query 850k Annotation (the ordinary approach)--------------------------
## First, extract the relevant column of the annotation:
x <- annot.850k$UCSC_RefGene_Name[1:n]
## Then, parse the annotation file and retrieve unique gene names:
x <- x[x != ""]
x <- paste(x, collapse=" ")
x <- paste(unlist(strsplit(x, split = ";")), collapse = " ")
x <- unique(strsplit(x, " ")[[1]])
x
length(x)

#--------------------------Evaluation--------------------------
mean(my_genes %in% x) #over 90% agreement
c(x[!x %in% my_genes], my_genes[! my_genes %in% x])
