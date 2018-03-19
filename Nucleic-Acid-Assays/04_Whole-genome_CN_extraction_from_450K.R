#################################################################################################################################
# Whole-Genome Copy Number Inference from Illumina 450K Methylation Array Output
# Script author: David Chen 
# Date: 03/17/2018
# Notes:
# 1. Illumina 450K IDAT files required (for TCGA, download from GDC Legacy Archive).
# 2. At least 1 normal control sample is required. Here, I used 97 normal-adjacent breast tissues.
# 3. Only autosomal genomic regions are considered.
# 4. The final output is a matrix, geneCNAMatrix, rows=genes, columns=sample, values=log2(tumor CN / control CN)
#    You may directly contact me for the 450K-inferred CNA profiles for 783 TCGA primary breast tumors (file size > 100Mb).
#################################################################################################################################

rm(list=ls())

library(biomaRt)
library(dplyr)
library(GenomicRanges)
library(minfi)
library(conumee)
library(doParallel); registerDoParallel(detectCores() - 1)
library(IlluminaHumanMethylation450kanno.ilmn12.hg19)

#---------------------------------------Step 0. Genome and gene annotations---------------------------------------
## 1. Whole-genome annotation for conumee:
## Load whole-genome gene coordinates as GRanges object:
library(TxDb.Hsapiens.UCSC.hg19.knownGene);
txdb.hg19 <- genes(TxDb.Hsapiens.UCSC.hg19.knownGene);
head(txdb.hg19)
txdb.hg19 <- txdb.hg19[txdb.hg19@seqnames %in% paste0("chr",1:22)];
names(txdb.hg19@elementMetadata) <- "name"; #conumee requirement
txdb.hg19
## Assemble CNV Annotation Object based on included & excluded regions:
annot <- CNV.create_anno(
  detail_regions = txdb.hg19,
  exclude_regions = exclude_regions,
  array_type = "450k", 
  chrXY = FALSE
);
annot

## 2. Gene ID annotation:
ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl");
attr.ensembl <- listAttributes(ensembl, page="feature_page");
data(exclude_regions);

#---------------------------------------Step 1. Channel loading by minfi---------------------------------------
## Change to IDAT working directory:
setwd("~/Dropbox (Christensen Lab)/Breast_Cancer_Data_Sets/All_TCGA_breast_450k/Unpacked_all_breast_450k_IDATs/")

## Separate target files for tumors and normals:
targets <- read.metharray.sheet(getwd());
table(targets$tissue.definition)

targetTum <- subset(targets, tissue.definition=="Primary solid Tumor");
targetCtrls <- subset(targets, tissue.definition=="Solid Tissue Normal"); 
rm(targets)

## Separate IDAT file loading: 
gdc_primary_breast <- read.metharray.exp(targets=targetTum);
gdc_primary_breast <- preprocessIllumina(gdc_primary_breast);
gdc_primary_breast
# class: MethylSet 
# dim: 485512 783 
# metadata(0):
#   assays(2): Meth Unmeth
# rownames(485512): cg00050873 cg00212031 ... ch.22.47579720R ch.22.48274842R
# rowData names(0):
#   colnames(783): 9993943013_R04C01 9993943013_R01C02 ... 9993943017_R06C01 3999997079_R01C02
# colData names(18): Sample_Name Sample_Well ... Basename filenames
# Annotation
# array: IlluminaHumanMethylation450k
# annotation: ilmn12.hg19
# Preprocessing
# Method: Illumina, bg.correct = TRUE, normalize = controls, reference = 1
# minfi version: 1.24.0
# Manifest version: 0.4.0

gdc_normalAdj <- read.metharray.exp(targets=targetCtrls);
gdc_normalAdj <- preprocessIllumina(gdc_normalAdj); 
gdc_normalAdj
# class: MethylSet 
# dim: 485512 97 
# metadata(0):
#   assays(2): Meth Unmeth
# rownames(485512): cg00050873 cg00212031 ... ch.22.47579720R ch.22.48274842R
# rowData names(0):
#   colnames(97): 6005486013_R02C02 6005486011_R06C02 ... 6057833134_R03C02 6057833155_R06C02
# colData names(18): Sample_Name Sample_Well ... Basename filenames
# Annotation
# array: IlluminaHumanMethylation450k
# annotation: ilmn12.hg19
# Preprocessing
# Method: Illumina, bg.correct = TRUE, normalize = controls, reference = 1
# minfi version: 1.24.0
# Manifest version: 0.4.0

#---------------------------------------Step 2. Execute CNA inference by conumee---------------------------------------
## Combine case-control intensity channels:
Illumina450.dat <- CNV.load(gdc_primary_breast, names=pData(gdc_primary_breast)$Sample_ID);
Illumina450.dat
# CNV data object
# created   : 
#  @intensity : available (783 samples, 485512 probes)

ctrl.dat <- CNV.load(gdc_normalAdj, names=pData(gdc_normalAdj)$Sample_ID);
ctrl.dat
# CNV data object
# created   : 
#   @intensity : available (97 samples, 485512 probes)

## Iterative CNA inference for selected genes
fitObj <- list(); #"raw" objects
segmentList <- list(); #CNA segmentation
geneCNAList <- list(); #for matrix conversion

for(k in 1:length(names(Illumina450.dat))){
  ## CNA inference:
  sampName <- names(Illumina450.dat)[k];
  x <- CNV.fit(Illumina450.dat[k], ctrl.dat, anno=annot);
  x <- CNV.bin(x);
  x <- CNV.detail(x);
  x <- CNV.segment(x);
  ## Save:
  fitObj[[sampName]] <- x;
  geneCNAList[[sampName]] <- CNV.write(x, what="detail");
  segmentList[[sampName]] <- CNV.write(x, what="segments");
}
rm(k, x, sampName); 

#---------------------------------------Step 3. Convert gene-based CNA to matrix format---------------------------------------
geneCNAMatrix <- NULL;
for(sampName in names(geneCNAList)){
  df <- data.frame(geneCNAList[[sampName]][ , c("sample","name","value")]);
  df <- subset(df, ! is.na(name)); 
  geneCNAMatrix <- rbind(geneCNAMatrix, df);
}
geneCNAMatrix <- stats::reshape(geneCNAMatrix,idvar="name",timevar="sample",direction="wide");
colnames(geneCNAMatrix) <- gsub("value.", "", colnames(geneCNAMatrix), fixed=TRUE);
colnames(geneCNAMatrix)[colnames(geneCNAMatrix)=="name"] <- "entrezgene";

## Retrieve gene mapping from biomaRt:
myEntrez <- as.character(geneCNAMatrix$entrezgene); 
entrez2hgnc_Map <- getBM(
  attributes = c('entrezgene','hgnc_symbol'), 
  filters = 'entrezgene', 
  values = myEntrez, 
  mart = ensembl
);
sum(duplicated(entrez2hgnc_Map$hgnc_symbol))

geneCNAMatrix <- merge(geneCNAMatrix, entrez2hgnc_Map, by="entrezgene", all.x=TRUE);
geneCNAMatrix <- geneCNAMatrix %>%
  select(c(entrezgene, hgnc_symbol), everything());

## Ready to export the `geneCNAMatrix` as CSV, XLS, or RData!
