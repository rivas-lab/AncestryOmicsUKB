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

balanced.folds <- function(y, nfolds = min(min(table(y)), 10)) {
   totals <- table(y)
   fmax <- max(totals)
   nfolds <- min(nfolds, fmax)     
   nfolds= max(nfolds, 2)
         # makes no sense to have more folds than the max class size
   folds <- as.list(seq(nfolds))
   yids <- split(seq(y), y) 
         # nice we to get the ids in a list, split by class
###Make a big matrix, with enough rows to get in all the folds per class
   bigmat <- matrix(NA, ceiling(fmax/nfolds) * nfolds, length(totals))
   for(i in seq(totals)) {
cat(i)
     if(length(yids[[i]])>1){bigmat[seq(totals[i]), i] <- sample(yids[[i]])}
     if(length(yids[[i]])==1){bigmat[seq(totals[i]), i] <- yids[[i]]}

   }
   smallmat <- matrix(bigmat, nrow = nfolds)# reshape the matrix
### Now do a clever sort to mix up the NAs
   smallmat <- permute.rows(t(smallmat))   ### Now a clever unlisting
         # the "clever" unlist doesn't work when there are no NAs
         #       apply(smallmat, 2, function(x)
         #        x[!is.na(x)])
   res <-vector("list", nfolds)
   for(j in 1:nfolds) {
     jj <- !is.na(smallmat[, j])
     res[[j]] <- smallmat[jj, j]
   }
   return(res)
 }
permute.rows <-function(x)
{
        dd <- dim(x)
        n <- dd[1]
        p <- dd[2]
        mm <- runif(length(x)) + rep(seq(n) * 10, rep(p, n))
        matrix(t(x)[order(mm)], n, p, byrow = TRUE)
}