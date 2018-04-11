#########################################################
# pROC execution & data visualization tutorial
# References: package vignette & assoc. 2011 BMC paper
#########################################################

library(pROC);
data(aSAH)
## Outcome variable: poor post-aSAH outcome
## 3 clinical measures; WFNS score, GOS score, age
## 2 (of 5) biomarkers: S100b, NKDA

## Most basic e.g. (see ?roc):
## Note: In some cases, ignoring levels could lead to unexpected results
roc(aSAH$outcome, aSAH$s100b, levels=c("Good", "Poor"), plot=TRUE)
## The following are 4 equivalent syntaxes:
roc(outcome ~ s100b, data=aSAH, plot=TRUE, smooth=TRUE) #no.1
roc(aSAH$outcome ~ aSAH$s100b, plot=TRUE, smooth=TRUE)  #no.2
with(aSAH, roc(outcome, s100b))                         #no.3
with(aSAH, roc(outcome ~ s100b))                        #no.4

## Execution & data visualization:
roc(
  response  = aSAH$outcome, #binary factor variable: truth
  predictor = aSAH$wfns,    #numeric predictor
  smooth    = TRUE,
  percent   = TRUE,
  # ci = TRUE, #determined by bootstrap-related meth.
  plot      = TRUE, 
  col       = "gold",
  main      = "ROC curves for standard clinical test vs. biomarker"
);
auc(as.numeric(aSAH$outcome), ifelse(aSAH$s100b >= 0.14, 1, 2))
roc(
  response  = aSAH$outcome, #binary factor variable: truth
  predictor = aSAH$s100b,   #numeric predictor
  smooth    = TRUE,
  percent   = TRUE,
  # ci = TRUE, #determined by bootstrap
  plot      = TRUE,
  col       = "darkolivegreen",
  add       = TRUE
);
legend("bottomright", legend=c("WFNS test","S100beta"), col=c("gold","darkolivegreen"), lwd=1, lty=1)


## Bootstrap test for the 2 classifiers from repeat measures:
## Note that multiple testing is not being accounted for here.
roc.test(
  response    = aSAH$outcome, 
  predictor1  = aSAH$wfns, 
  predictor2  = aSAH$s100, 
  partial.auc = c(100, 90), 
  percent     = TRUE, 
  alternative = "two.sided",
  boot.n      = 5 #the `...` argument
)


