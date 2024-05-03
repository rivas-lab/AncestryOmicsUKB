library(data.table)
library(glinternet)
library(glmnet)
library(doMC)
library(ptLasso)

registerDoMC(cores = 12)

fit_models <- function(model_dir_path, disease, preprocessed_data, update_models, model_desired) {

    cat('Disease : ', disease, '\n')
    model_path <- file.path(model_dir_path, paste0(disease, '.rds'))
    
    if (file.exists(model_path) && update_models == FALSE) {
        cat('Already fitted model for disease', disease, '\n\n')
        cv_fit = readRDS(file.path(model_dir_path, paste0(disease, '.rds')))
        return(cv_fit) }

    X_train <- preprocessed_data$X_train
    y_train <- preprocessed_data$y_train

    if (any(is.na(y_train))) {
        stop("NA values found in y.")}
    if (any(is.na(X_train))) {
    X_train <- as.data.frame(X_train)
    print('NA columns')
    na_columns <- colSums(is.na(X_train))
    na_columns_names <- names(na_columns[na_columns > 0])
    print(na_columns_names)
        stop("NA values found in X.")}

    cat('Fitting model\n')
    flush.console()
    
    if (model_desired == 'glinternet') { 
        print('Desired model to fit: Glinternet')
        cv_fit <- fit_glinternet_cv(X_train, y_train, 3, 10)
    } else if (model_desired == 'l1_log_reg') {         
        print('Desired model to fit: L1 Logistic Regression')
        cv_fit <- fit_l1_log_reg(X_train, y_train, 3)    
    } else if (model_desired == 'pretrained_lasso') {   
        print('Desired model to fit: Pretrained LASSO')
        cv_fit <- fit_pretrained_lasso(X_train, y_train, nfolds=3)    
    }

    cat('Finished fitting model\n\n')
    flush.console()
    
    saveRDS(cv_fit, file.path(model_dir_path, paste0(disease, '.rds')))
    return (cv_fit)
}

fit_glinternet_cv <- function(X_train, y_train, nFolds, numCores) {
    
    num_cols  <- ncol(X_train)
    numLevels <- c(1, 1, 2, 2, rep(1, num_cols - 4))
    
    interactionCandidates=c(1,2,3,4)
    
    cv_fit <- glinternet.cv(
        X=X_train, 
        Y=y_train, 
        numLevels=numLevels, 
        nFolds=nFolds, 
        family='binomial', 
        interactionCandidates=interactionCandidates,
        numCores=numCores)
    
    return (cv_fit)
    
}

fit_l1_log_reg <- function(X_train, y_train, nFolds){
        
    X_train_matrix <- as.matrix(X_train)
        
    cv_fit <- cv.glmnet(
        X_train_matrix, y_train, 
        family = "binomial",
        alpha = 1, 
        nfolds = nFolds,
        parallel=TRUE)    
    
    return (cv_fit)
}   

fit_pretrained_lasso <- function(X_train, y_train, nfolds) {
    
    X_train <- as.matrix(X_train, nrow = nrow(X_train))
    
    cv_fit = cv.ptLasso(
        X_train[, -4], y_train, groups = X_train[,4],
        family="binomial",type.measure="auc",
        foldid=NULL, nfolds=nfolds, overall.lambda = "lambda.min",
        parallel=TRUE,verbose=TRUE, trace.it=TRUE)

    return (cv_fit)
}
