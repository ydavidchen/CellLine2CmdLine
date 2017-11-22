#######################################################
# Exploration of oncogenes
# Script author: David Chen
# Date: 08/08/2017
########################################################

rm(list=ls())

library(biomaRt)
library(GenomicRanges)
library(ggplot2)
library(matrixStats)
library(pheatmap)
library(RColorBrewer); gradient_cols <- brewer.pal(12, "Paired")
library(doParallel); registerDoParallel(detectCores() - 1)

ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl"); #ref.
human.chrom <- c(1:22, "X", "Y"); #standard human chr only
oncogenes <- c(
  "CCNB1",
  "EGFR",
  "IGFBP2",
  "CXCL8", #IL8
  "CXCR2",
  "CCL18",
  "SOX2",
  "OLIG2",
  "HOXA1",
  "PAX8",
  "SERPINE1", #PAI1
  "HSPA1A" #HSP70
)

## Gene list with hg19 mapping: 
detailed.regions <- getBM(
  c("chromosome_name", "start_position", "end_position", "hgnc_symbol", "strand"),
  filters = c("hgnc_symbol", "chromosome_name"),
  values = list(hgnc_symbol=oncogenes, chromosome_name=human.chrom),
  mart = ensembl
);
detailed.regions$strand <- sub(pattern=1,    replacement='+', x=detailed.regions$strand, fixed=T);
detailed.regions$strand <- sub(pattern="-+", replacement='-', x=detailed.regions$strand, fixed=T);
detailed.regions$chromosome_name <- paste0('chr', detailed.regions$chromosome_name);

detailed.regions$category <- NA;
detailed.regions$category[detailed.regions$hgnc_symbol %in% c("CCNB1","EGFR","IGFBP2")]      <- "cell cycle and proliferation"
detailed.regions$category[detailed.regions$hgnc_symbol %in% c("CXCL8","CXCR2","CCL18")]      <- "immune signaling";
detailed.regions$category[detailed.regions$hgnc_symbol %in% c("SOX2","OLIG2","HOXA1")]       <- "stem cell maintenance";
detailed.regions$category[detailed.regions$hgnc_symbol %in% c("PAX8","SERPINE1","HSPA1A")]   <- "negative regulator of apoptosis";

anno <- data.frame(
  chr    = as.character(detailed.regions$chromosome_name),
  start  = as.numeric(detailed.regions$start_position),
  end    = as.numeric(detailed.regions$end_position),
  name   = as.character(detailed.regions$hgnc_symbol), 
  strand = detailed.regions$strand
)
anno
gr <- makeGRangesFromDataFrame(anno, keep.extra.columns=TRUE)
View(gr)


## Query annotation file:
library(IlluminaHumanMethylationEPICanno.ilm10b3.hg19);
annot.850kb3 <- getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b3.hg19);
# library(IlluminaHumanMethylation450kanno.ilmn12.hg19)
# annot.450k <- getAnnotation(IlluminaHumanMethylation450kanno.ilmn12.hg19)
indices <- rep(NA, length(oncogenes));
for(g in oncogenes){
  indices <- c(indices, grep(g, annot.850kb3$UCSC_RefGene_Name) )
};
indices <- na.omit(indices);
annot.oncogene850k <- annot.850kb3[indices, ];
annot.oncogene850k <- annot.oncogene850k[! grepl("HOXA1[0-9]",annot.oncogene850k$UCSC_RefGene_Name), ];
annot.oncogene850k <- annot.oncogene850k[! grepl("CCNB1IP1",annot.oncogene850k$UCSC_RefGene_Name),   ];

## An enhancer associated probe has at least 1 of the following features
## 1. Annotation (450k, Phantom 4/5)
## 2. Evidence for open chromatin
## 3. Evidence for TFBS
annot.oncogene850k <- annot.oncogene850k[annot.oncogene850k$X450k_Enhancer     == TRUE |
                                         annot.oncogene850k$Phantom4_Enhancers != "" | 
                                         annot.oncogene850k$Phantom5_Enhancers != "" |
                                         annot.oncogene850k$OpenChromatin_NAME != "" |
                                         annot.oncogene850k$TFBS_NAME          != "", ]

