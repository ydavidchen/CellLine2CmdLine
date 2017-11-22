####################################################################################
# Descriptive stats: compare all EPIC array vs. most variable k CpGs
# Script author: David Chen
# Date: 11/22/2017
####################################################################################

rm(list=ls())

library(ggplot2)
library(matrixStats)
library(reshape2)
library(VennDiagram)

#----------------------------------------Data/annotation loading & preparation----------------------------------------
## EPIC annotation package:
library(IlluminaHumanMethylationEPICanno.ilm10b3.hg19)
annot.850kb3 <- getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b3.hg19)

## Load your data and make a copy for operation:
load("YOUR_PATH_HERE"); #or equivalent
methylationDat <- YOUR_DATA_MATRIX #make a copy

## Calculate variance & plot the ranked distribution:
meth_vars <- sort(rowVars(methylationDat), decreasing=TRUE)
varCut <- 0.01 #your choice
k <- sum(meth_vars > varCut)
sele <- order(rowVars(methylationDat), decreasing=TRUE)[1:k] #k most variable
plot(
  meth_vars,
  cex = 0.3,
  pch = 16,
  bty = "l",
  col = ifelse(meth_vars > varCut, "red", "black"),
  ylab = "Variance in beta-value",
  main = "Variance ranking"
)
abline(h=varCut, lty=2, col="darkgray")
text(6e05, varCut+0.02, paste(k,"CpGs with variance >",varCut), col="red")

## Select top k most variable CpGs:
methylationDat <- methylationDat[sele, ]
dim(methylationDat)

## Subset annotation file:
ann850KSub <- annot.850kb3[annot.850kb3$Name %in% rownames(methylationDat), ]
dim(ann850KSub)

#----------------------------------------Plot 1: Summary bar plot by genomic context----------------------------------------
arrayDescripStats <- merge(
  data.frame(table(annot.850kb3$Relation_to_Island) / nrow(annot.850kb3)), #all 850K probes
  data.frame(table(ann850KSub$Relation_to_Island) / nrow(ann850KSub)), #subset of 850K probes
  by = "Var1",
  stringsAsFactors = FALSE
)
colnames(arrayDescripStats) <- c("Category","all850K","mostVariable") #update as necessary; order matters
arrayDescripStats$Category <- as.character(arrayDescripStats$Category) 
arrayDescripStats <- rbind(
  arrayDescripStats,
  c(Category="TSS1500",  all850K=mean(grepl("TSS1500",annot.850kb3$UCSC_RefGene_Group)),  mostVariable=mean(grepl("TSS1500",ann850KSub$UCSC_RefGene_Group))),
  c(Category="TSS200",   all850K=mean(grepl("TSS200", annot.850kb3$UCSC_RefGene_Group)) , mostVariable=mean(grepl("TSS200", ann850KSub$UCSC_RefGene_Group)) ),
  c(Category="TSS (any)",all850K=mean(grepl("TSS",    annot.850kb3$UCSC_RefGene_Group)) , mostVariable=mean(grepl("TSS",    ann850KSub$UCSC_RefGene_Group)) ),
  c(Category="Gene body",all850K=mean(grepl("Body",   annot.850kb3$UCSC_RefGene_Group)) , mostVariable=mean(grepl("Body",   ann850KSub$UCSC_RefGene_Group)) ),
  c(Category="UTR",      all850K=mean(grepl("UTR",   annot.850kb3$UCSC_RefGene_Group)) , mostVariable=mean(grepl("UTR",     ann850KSub$UCSC_RefGene_Group)) ),
  c(Category="Enhancer", all850K=mean(annot.850kb3$Phantom5_Enhancers != "") , mostVariable=mean(ann850KSub$Phantom5_Enhancers != "") )
) 
arrayDescripStats$all850K <- as.numeric(arrayDescripStats$all850K)
arrayDescripStats$mostVariable <- as.numeric(arrayDescripStats$mostVariable) 

## Data visualization:
plt.descStats <- melt(arrayDescripStats, id.vars="Category", variable.name="CpGs", value.name="Proportion")
plt.descStats$Category <- factor(plt.descStats$Category, levels=c("TSS200","TSS1500","TSS (any)","Enhancer","Gene body","UTR","Island","N_Shelf","S_Shelf","N_Shore","S_Shore","OpenSea"))
ggplot(plt.descStats, aes(Category, Proportion, fill=CpGs)) +
  geom_bar(stat="identity", position="dodge") +
  labs(x="", title=paste("Var(beta-value) threshold:",varCut) ) +
  scale_y_continuous(limits=c(0,1)) +
  scale_fill_brewer(palette='Set1') +
  theme_classic() +
  theme(axis.text.x=element_text(size=14,color="black"), axis.text.y=element_text(size=14,color="black"),
        legend.position="top", legend.title=element_blank(), legend.text=element_text(size=14,color="black")) +
  geom_vline(xintercept=6.5, linetype="dashed")

## Can also export table: 
write.csv(arrayDescripStats, file="Descriptive stats of all vs selected CpGs.csv", row.names=F, quote=F)

#----------------------------------------Plot 2: Unique gene counts----------------------------------------
genes.sele <- as.character(ann850KSub$UCSC_RefGene_Name)
genes.sele <- paste(genes.sele,collapse=";")
genes.sele <- strsplit(genes.sele, split=";")[[1]]
genes.sele <- genes.sele[genes.sele != ""]
genes.sele <- unique(genes.sele)
length(genes.sele)

genes.all850K <- as.character(annot.850kb3$UCSC_RefGene_Name)
genes.all850K <- paste(genes.all850K, collapse=";")
genes.all850K <- strsplit(genes.all850K, split=";")[[1]]
genes.all850K <- genes.all850K[genes.all850K != ""]
genes.all850K <- unique(genes.all850K)
length(genes.all850K) #27378

grid.newpage();
draw.pairwise.venn(
  area1 = length(genes.sele), 
  area2 = length(genes.all850K), 
  cross.area = length(intersect(genes.sele, genes.all850K)), 
  category = c("Most variable", "All 850K array"), #order matters 
  lty = rep("blank", 2), 
  fill = c("skyblue", "yellow"), 
  alpha = rep(0.5, 2),
  cat.pos = c(0, 0), #relative position in "clock" direction
  cat.dist = c(-0.05, -0.05), #distance from circle
  cex = 1, 
  cat.cex = 1,
  print.mode = c("raw", "percent")
)
grid.text("Gene count", vjust=-45,just=c("top")) #set `vjust=-45` for pdf export only
