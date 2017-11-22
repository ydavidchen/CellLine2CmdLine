## Visualization of oncogene 5hmC in adult glioma & normal PFC tissues
## David Chen
## August 2017

rm(list=ls())
library(biomaRt)
library(gdata)
library(matrixStats)
library(pheatmap)
library(doParallel); registerDoParallel(detectCores() - 1)
setwd("~/Dropbox (Christensen Lab)/Glioma_Data_Sets/")


#--------------------------------Gene and CpG annotations--------------------------------
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
);

## Oncogene genomic locations: 
ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl"); #ref.
human.chrom <- c(1:22, "X", "Y"); #standard human chr only
detailed.regions <- getBM(
  c("chromosome_name", "start_position", "end_position", "hgnc_symbol", "strand"),
  filters = c("hgnc_symbol", "chromosome_name"),
  values = list(hgnc_symbol=oncogenes, chromosome_name=human.chrom),
  mart = ensembl
);
detailed.regions$strand <- sub(pattern=1,    replacement='+', x=detailed.regions$strand, fixed=T);
detailed.regions$strand <- sub(pattern="-+", replacement='-', x=detailed.regions$strand, fixed=T);
detailed.regions$chromosome_name <- paste0('chr', detailed.regions$chromosome_name);

## Extract gene indices
indices <- rep(NA, length(oncogenes)); 
for(g in oncogenes){
  indices <- c(indices, grep(g, annot.450k$UCSC_RefGene_Name) )
}; 
indices <- na.omit(indices); 
library(IlluminaHumanMethylation450kanno.ilmn12.hg19);
annot.450k <- getAnnotation(IlluminaHumanMethylation450kanno.ilmn12.hg19); 
annot.450k <- annot.450k[indices, ]; 
annot.450k <- annot.450k[! grepl("HOXA1[0-9]",annot.450k$UCSC_RefGene_Name), ]; 
annot.450k <- annot.450k[! grepl("CCNB1IP1",annot.450k$UCSC_RefGene_Name), ]; 

#--------------------------------Lunnon PFC data set annotations--------------------------------
load("082017_5hmC_GBM_PFC_data_sets.RData");
colnames(pfc_annot)[11:15] <- paste0("Sample_Charac", 1:5); 
pfc_annot <- droplevels(pfc_annot); 
rownames(pfc_annot) <- NULL; 
table(pfc_annot$Sample_Charac3)
pfc_annot <- pfc_annot[grepl("Prefrontal", pfc_annot$Sample_title), ];
pfc_annot <- pfc_annot[! grepl("BSZY", pfc_annot$Sample_title), ]; #remove non CE runs
pfc_annot$Sample_Charac2 <- gsub("gender: ", "", pfc_annot$Sample_Charac2); 
pfc_annot$Sample_Charac3 <- gsub("treatment: bisulfite", "BS", pfc_annot$Sample_Charac3);
pfc_annot$Sample_Charac3 <- gsub("treatment: oxidative bisulfite", "oxBS", pfc_annot$Sample_Charac3);
pfc_annot$Sample_Charac4 <- gsub("donor id: ", "", pfc_annot$Sample_Charac4); 
pfc_annot$ID <- paste(pfc_annot$Sample_Charac4, pfc_annot$Sample_Charac3, sep="_");

## Switch out GEO sample IDs:
pfc_series <- pfc_series[ , match(pfc_annot$Sample_geo_accession, colnames(pfc_series))]; 
stopifnot(all(pfc_annot$Sample_geo_accession == colnames(pfc_series))) #checkpoint
colnames(pfc_series) <- as.character(pfc_annot$ID);

## Subset data:
pfc_series.oxBS <- pfc_series[ , grepl("oxBS", colnames(pfc_series))];
pfc_series.BS <- pfc_series[ , ! grepl("oxBS", colnames(pfc_series))];
if(all(
  gsub("_BS", "", colnames(pfc_series.BS)) == gsub("_oxBS", "", colnames(pfc_series.oxBS))
)){
  print("Ready to perform subtraction!"); 
  pfc_5hmC <- pfc_series.BS - pfc_series.oxBS;
  colnames(pfc_5hmC) <- gsub("\\_.*", "", colnames(pfc_5hmC)); 
} else {
  stop("BS and oxBS matrices do NOT match by sample! Need to order"); 
}
dim(pfc_5hmC)

## Select CpGs that pass the threshold set by the original authors:
# thresh <- 0.09158275; #See Lunnon K 2016
thresh <- 0; 
pfc_5hmC[pfc_5hmC < thresh] <- 0;
## Subset to CpGs of oncogenes of interest:
pfc_5hmC <- pfc_5hmC[rownames(pfc_5hmC) %in% annot.450k$Name, ]; 

## Data visualization: 
pheatmap(
  pfc_5hmC,
  show_rownames = FALSE, #CpGs
  # show_colnames = FALSE, #samples
  # annotation_colors =  ann_colors,
  color = colorRampPalette(c("yellow", "blue"))(1024),
  clustering_distance_rows = "manhattan",
  clustering_distance_cols = "manhattan",
  clustering_method = "average",
  border_color = NA, 
  fontsize = 7.5, #labels,titles
  fontsize_col = 7.5 #samples
)

#--------------------------------------------Circos plot--------------------------------------------
library(RCircos)
library(RColorBrewer)
data("UCSC.HG19.Human.CytoBandIdeogram");
RCircos.Set.Core.Components(UCSC.HG19.Human.CytoBandIdeogram,tracks.inside=10,tracks.outside=5);
RCircos.Set.Plot.Area();
RCircos.Draw.Chromosome.Ideogram(ideo.pos=NULL, ideo.width=NULL);
RCircos.Label.Chromosome.Names(chr.name.pos=NULL);
label_dat <- detailed.regions[ , 1:4];
RCircos.Gene.Connector.Plot(label_dat, track.num=1, side="out", outside.pos=1);
RCircos.Gene.Name.Plot(label_dat, name.col=4, track.num=2, side="out",outside.pos=3);

#--------------------------------------------Add in CpG labels--------------------------------------------
cpg_labels <- as.data.frame(annot.450k[ , c(1,2,2)]);
colnames(cpg_labels) <- c("Chromosome","ChromStart","ChromEnd") 
# cpg_labels$h <- 1;  #arbitrary height
# RCircos.Histogram.Plot(cpg_labels, data.col=4, track.num=2, side="in")
# RCircos.Scatter.Plot(cpg_labels, data.col=4, track.num=2, side="in")
# data("RCircos.Polygon.Data")
# RCircos.Polygon.Plot(RCircos.Polygon.Data,  track.num=1, side="in")

cpg_data <- data.frame(
  row.names = rownames(pfc_5hmC),
  placeholder = NA, 
  hmC_mean = rowMeans(pfc_5hmC)
); 
cpg_data  <- merge(cpg_labels, cpg_data, by="row.names");
rownames(cpg_data) <- cpg_data$Row.names; 
cpg_data$Row.names <- NULL
colnames(cpg_data) <- colnames(RCircos.Heatmap.Data)[1:5]
View(RCircos.Heatmap.Data)
RCircos.Heatmap.Plot(cpg_data, data.col=5, side="in", inside.pos=0.9, outside.pos=1.2)
