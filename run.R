source('src/sampling.R')
source('constants.R')
source('src/statistics.R')
source('src/preprocess.R')
source('src/fit.R')

set.seed(1001)

print('Loading datasets...')
meta  = fread('data/meta.csv')
prs   = fread('data/prs.csv')
pheno = fread('data/pheno.csv')
print('Finished loading datasets...')

populations <- list('white_british', 's_asian')
model_dir_path <- 'models/glinternet/under_sampling/WB_SA_metabolomics'

aucs_with_prs  <- list()

for (disease in DISEASE_CODES) {
    
    prepared_data <- prepare_data(meta, prs, pheno)
    preprocessed_data <- preprocess_data(
        populations, disease, 
        prepared_data$pheno, prepared_data$meta, 
        prepared_data$prs, use_prs=TRUE, prepared_data$demo, use_demo=TRUE)
    
    sampled_data        <- sample_data(preprocessed_data, 'under_sampling')
    system.time({cv_fit <- fit_models(model_dir_path, disease, preprocessed_data, update_models=FALSE)})
    
    #i_1Std <- which(cv_fit$lambdaHat1Std == cv_fit$lambda)
    #coefs <- coef(cv_fit$glinternetFit)[[i_1Std]]
    
    #main_effects <- coefs$mainEffects$cont
    
    #cat('Main effects:\n')
    #for (effect in main_effects) {
    #    col_index <- effect
    #    print(colnames(preprocessed_data$X_train[, ..col_index]))
    #}

    #cat('\nInteractions:\n')
    
    #if (length(coefs$interactions$catcont) > 0) {
    #for (row in 1:nrow(coefs$interactions$catcont)) {
    
    #    var_idx <- (coefs$interactions$catcont[row, 2])
    #    print(colnames(preprocessed_data$X_train[, ..var_idx]))
    #}
    #}
    
    #X_test <- preprocessed_data$X_test
    #y_test <- preprocessed_data$y_test

    #predictions <- as.vector(predict(cv_fit, X_test, type = "response"))

    #roc_curve <- suppressMessages(roc(y_test, predictions, quietly = TRUE))
    #auc_score <- auc(roc_curve)
    #aucs_with_prs <- c(aucs_with_prs, auc_score)
    #cat('\nAUC score: ', auc_score)
    #cat('\n\n####################################################################################################')
    #cat('\n####################################################################################################\n')

}