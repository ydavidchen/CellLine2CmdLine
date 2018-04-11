thresholdEval <- function(actual_labels,pred_probs,threshold){
  #'@author Originally P. Li; wrapped by PGA
  #'@author Further edited/wrapped by ydavidchen
  #'@describeIn StackOverflow
  #'@description Function that calculates precision, recall, and F-measure to evaluate probabilistic threshold
  #'@param pred_probs One or more numeric values representing predicted probabilities
  #'@param actual_labels Numeric or factor
  #'@param threshold A single numeric value between 0 and 1 representing threshold for the positive class
  
  if(! all(c(1,0) %in% names( table(actual_labels))) ){stop("Factor levels must be 0/1!")}; 
  if( any(pred_probs > 1 | pred_probs < 0) ){
    print(paste("Your range is", range(pred_probs)) ); 
    stop("Probability measure is likely wrong!"); 
  };
  predict_labels <- ifelse(as.numeric(pred_probs) > as.numeric(threshold), 1, 0); 
  precision <- sum(predict_labels & actual_labels) / sum(predict_labels);
  recall <- sum(predict_labels & actual_labels) / sum(actual_labels);
  fmeasure <- 2 * precision * recall / (precision + recall);
  
  cat('Precision:  '); cat(precision * 100); cat('%'); cat('\n'); 
  cat('Recall:     '); cat(recall * 100); cat('%'); cat('\n')
  cat('F1 score:  '); cat(fmeasure * 100); cat('%'); cat('\n')
}

## Simulation example: 
## On average, expect approximately 0.50 for all metrics
## Use the F1 score to judge whether a probabilistic threshold is appropriate
pred_probs <- rnorm(100, 0.5, 0.1);
my_true_labels <- sample(c(0,1), 100, replace=TRUE); 
thresholdEval(
  actual_labels = my_true_labels, 
  pred_probs = pred_probs,
  threshold = 0.50
)