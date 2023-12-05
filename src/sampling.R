library(caret)

create_stratified_folds <- function(data, column_index, k) {

  stratify_column <- data[, column_index]

  if(any(is.na(stratify_column))) {
    stop("NA values found in stratify column.")
  }
    
  folds  <- createFolds(stratify_column, k = k)
  foldid <- rep(NA, nrow(data))
    
  for(i in seq_along(folds)) {
    foldid[folds[[i]]] <- i
  }
    
  return(foldid)
}

create_regular_folds <- function(data, k) {
  n <- nrow(data)
  foldid <- sample(rep(1:k, length.out = n))
  return(foldid)
}