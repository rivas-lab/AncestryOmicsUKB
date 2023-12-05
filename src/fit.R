library(data.table)
library(glinternet)
library(glmnet)
library(doMC)

source('src/sampling.R')

registerDoMC(cores = 5)

fit_models <- function(model_dir_path, disease, preprocessed_data, update_models, model_desired) {

    cat('Disease : ', disease, '\n')
    model_path <- file.path(model_dir_path, paste0(disease, '.rds'))
    
    if (file.exists(model_path) && update_models == FALSE) {
        cat('Already fitted model for disease', disease, '\n\n')
        cv_fit = readRDS(file.path(model_dir_path, paste0(disease, '.rds')))
        return(cv_fit) }

    X_train <- preprocessed_data$X_train
    y_train <- preprocessed_data$y_train
    X_val   <- preprocessed_data$X_val
    y_val   <- preprocessed_data$y_val

    if (any(is.na(y_train)) || any(is.na(X_train))) {
        stop("NA values found in Y or X.")}
    
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
        cv_fit <- fit_pretrained_lasso(X_train, y_train, nfolds=5)    
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
        X_train=X_train, 
        y_train=y_train, 
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
        nfolds = nFolds)    
    
    return (cv_fit)
}   

fit_pretrained_lasso <- function(X_train, y_train, nfolds){
    
    set.seed(1234)
    
    n = nrow(X_train)
    p = ncol(X_train)
    k = 2 # of classes

    race = X_train[,4]
    print('Race table')
    print(table(race))
    
    X_train <- as.matrix(X_train, nrow = nrow(X_train))
    foldid  <- create_stratified_folds(X_train, 4, nfolds)
    print('Created folds for the pan-ethnicity model')
    
    foldid2 <- create_regular_folds(X_train[X_train[, 4] == 1, ], nfolds)
    print('Created folds for other models')

    ## standardize
    mx = colMeans(X_train)
    sx = apply(X_train,2,sd)
    
    X_train = scale(X_train, mx, sx)

    # upweight SA pop
    wt = rep(NA,n)
    tt = table(y_train)/n
    
    wt[y_train==0] = tt[2]
    wt[y_train==1] = tt[1]
    
    print('Fitting pan-ethnicity model')
    # Fit pan-ethnicity model
    cv_fit_pan_ethnicity <-cv.glmnet(
        X_train,y_train,weights=wt,standardize=FALSE,foldid=foldid,
        family="binomial",trace.it=TRUE, parallel=TRUE, keep=TRUE)
    
    lamhat  = cv_fit_pan_ethnicity$lambda.1se
    bhatpan = as.numeric(coef(cv_fit_pan_ethnicity, s=lamhat, exact=FALSE))
    supp3   = which(bhatpan[2:(p + 1)]!=0)
    print('Fitted pan-ethnicity model')
    
    # Fit individual model
    sa = race == 1
    
    print('Fitting individual model')

    cv_fit_individual = cv.glmnet(
        X_train[sa,],y_train[sa],family="binomial",
        trace.it=T, standardize=FALSE, 
        foldid=foldid2,parallel=TRUE) 
    
    print('Fitted individual model')

    res2 = NULL
    supp = NULL
    eps = 1e-8
   
    best_roc_auc <- 0
    best_alpha <- NULL
    best_model <- NULL

    alphalist = seq(eps, 1, length.out = 10)
    
    print('Fitting pretrained LASSO model')

    for(alpha in alphalist){
        cat(c("alpha=", alpha), fill = TRUE)

        offset = (1 - alpha) * cv_fit_pan_ethnicity$fit.preval[, which(cv_fit_pan_ethnicity$cvm == min(cv_fit_pan_ethnicity$cvm))]  # prevalidated offset

        fac = rep(1 / alpha, p)
        fac[supp3] = 1
        pf = fac

        cv_fit_pretrained_lasso = cv.glmnet(
            X_train[sa, ], y_train[sa], family = "binomial", standardize = FALSE,
            offset = offset[sa], trace.it = TRUE, penalty.factor = pf, 
            foldid = foldid2, parallel = TRUE)
        
        lamhat4 = cv_fit_pretrained_lasso$lambda.min
        
        offset  = (1 - alpha) * predict(cv_fit_pan_ethnicity, X_train, s = lamhat)
        phatpre = predict(cv_fit_pretrained_lasso, X_train, s = lamhat4, newoffset = offset,type = "response")

        roc_curve <- roc(y_train, phatpre)
        roc_auc <- auc(roc_curve)
        
        print('ROC-AUC')
        print(roc_auc)

        if (roc_auc > best_roc_auc) {
            best_roc_auc <- roc_auc
            best_alpha   <- alpha
            best_model   <- cv_fit_pretrained_lasso
            best_lamhat  <- lamhat
        }
    }
    
    print('Fitted pretrained LASSO model')

    # Store extra variables needed for prediction on test set
    best_model$best_alpha = best_alpha
    best_model$lamhat     = lamhat
    best_model$mx         = mx
    best_model$sx         = sx
    
    best_model$cv_fit_pan_ethnicity = cv_fit_pan_ethnicity
        
    return (best_model)
     
}    
