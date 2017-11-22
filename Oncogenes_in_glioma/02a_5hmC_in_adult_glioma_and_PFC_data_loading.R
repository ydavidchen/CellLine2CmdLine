## Exploration of 5hmC and gene expression in adult glioma
## David Chen
## August 2017

rm(list=ls())
library(gdata)
library(doParallel); registerDoParallel(detectCores() - 1)
setwd("~/Dropbox (Christensen Lab)/Glioma_Data_Sets/")

## GBM 5hmC data (n=30):
gbm_series <- read.csv("Johnson_KC_GSE73895_series_matrix.txt.gz", sep="\t", skip=67, header=F); 
colnames(gbm_series) <- as.character(unlist(gbm_series[1, ])); #converts to strings
gbm_series <- gbm_series[-1, ]; 
class(gbm_series)
rownames(gbm_series) <- gbm_series$ID_REF; 
gbm_series$ID_REF <- NULL; 
gbm_series <- as.matrix(gbm_series); 
mode(gbm_series) <- "numeric";
sum(is.na(gbm_series))
## Gene expression data:
nanoString <- read.xls("Johnson_KC_2016_NanoString.xls", skip=1);
## Sample annotations: 
gbm_annot <- read.csv("Johnson_KC_GSE73895_series_matrix.txt.gz", sep="\t", skip=27, header=F)[1:40, ];
gbm_annot <- as.data.frame(t(gbm_annot));
colnames(gbm_annot) <- as.character(unlist(gbm_annot[1, ]));
colnames(gbm_annot) <- gsub("!", "", colnames(gbm_annot)); 
gbm_annot <- gbm_annot[-1, ];

## PFC 5hmC data (n=5):
pfc_series <- read.csv("Lunnon2016_GSE74368_series_matrix.txt.gz", sep='\t', skip=76, header=F);
colnames(pfc_series) <- as.character(unlist(pfc_series[1, ]));
pfc_series <- pfc_series[-1, ];
rownames(pfc_series) <- pfc_series$ID_REF;
pfc_series$ID_REF <- NULL;
pfc_series <- as.matrix(pfc_series); 
mode(pfc_series) <- "numeric"; 
sum(is.na(pfc_series))

pfc_annot <- read.csv("Lunnon2016_GSE74368_series_matrix.txt.gz", sep='\t', skip=37, header=F)[1:20, ];
pfc_annot <- as.data.frame(t(pfc_annot));
colnames(pfc_annot) <- as.character(unlist(pfc_annot[1, ]));
colnames(pfc_annot) <- gsub("!", "", colnames(pfc_annot) );
pfc_annot <- pfc_annot[-1, ];

## Export workspace: 
save(
  list = ls(),
  file = "082017_5hmC_GBM_PFC_data_sets.RData",
  compress = TRUE
)
