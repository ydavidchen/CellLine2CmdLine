# Minimal ComBat Example
# Script author: Y. David Chen
# References: Leek J.T. et al. & sva package

rm(list=ls());
library(sva);

load_bladder_data_and_annot <- function() {
  #'@description Wrapper for Leek et al.'s example data set
  require(bladderbatch); 
  data(bladderdata); 
  pheno <- pData(bladderEset);
  edata <- exprs(bladderEset);
  assign("pheno", pheno, envir=.GlobalEnv);
  assign("edata", edata, envir=.GlobalEnv); 
}

run_combat <- function(edata, pheno, batchVarName, ...) {
  #'@description Execute ComBat
  #'@param edata Original gene expression data.matrix
  #'@param pheno data.frame for sample annotation containing batch & main outcome as columns
  #'@param batchVarName String indicating the batch variable column in `pheno`
  #'@param ... Additional parameters passed to `ComBat`
  require(sva);
  batch <- pheno[ , batchVarName];
  mm_combat <- model.matrix(~1, data=pheno); 
  corrected_edata <- ComBat(
    edata,
    batch = batch,
    mod = mm_combat,
    ...
  ); 
  return(corrected_edata); 
}

assess_combat <- function(pheno, corrected_edata, outcomeVarName) {
  #'@description Assess performance of ComBat
  #'@param pheno data.frame for sample annotation containing batch & main outcome as columns
  #'@param corrected_edata ComBat-adjusted expression data
  #'@param outcomeVarName String indicating the outcome variable in `pheno`
  require(sva); 
  mod <- model.matrix( ~ pheno[ , outcomeVarName]); 
  mod0 <- model.matrix(~ 1, data=pheno); 
  pValuesComBat <- sva::f.pvalue(corrected_edata, mod, mod0); 
  qValuesComBat <- p.adjust(pValuesComBat,method="BH"); 
  return(data.frame(cbind(pValuesComBat, qValuesComBat)));
}

main <- function() {
  load_bladder_data_and_annot();
  cb_data <- run_combat(edata, pheno, "batch");
  cb_quality <- assess_combat(pheno, cb_data, "cancer");
}

if(! interactive()) main();
