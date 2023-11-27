library(data.table)
library(glinternet)

fit_models <- function(model_dir_path, disease, preprocessed_data, update_models) {
    
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
    
    num_cols <- ncol(X_train)
    numLevels <- c(1, 1, 2, 2, rep(1, num_cols - 4))
    
    cat('Fitting model\n')
    flush.console()

    cv_fit <- glinternet.cv(
        X_train, y_train, numLevels, nFolds = 3, 
        family='binomial', interactionCandidates=c(1,2,3,4),
        numCores=10
    )    

    cat('Finished fitting model\n\n')
    flush.console()
    
    saveRDS(cv_fit, file.path(model_dir_path, paste0(disease, '.rds')))
    return (cv_fit)
}
