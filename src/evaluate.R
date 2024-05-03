library(pROC)  
library(glinternet)
library(glmnet)
library(ptLasso)

compute_auc_for_model <- function(model, preprocessed_data, model_type, split) {
    
    print(model_type)
    if (model_type == "l1_log_reg") {
        
        predictions <- predict(model, newx = as.matrix(preprocessed_data$X_test), type = "response")
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))

    } else if (model_type == "glinternet" && split != 'ALL') {
        
        print('Computing results with glinternet on WB_ancestry split')
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        preprocessed_data$X_test[,4] <- 1
        
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        predictions <- predict(model, preprocessed_data$X_test, type = "response")

    } else if (model_type == "glinternet" && split == 'ALL') {
        
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        preprocessed_data$X_test[, 4] <- preprocessed_data$X_test[, 4] - 1
        
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        predictions <- as.vector(predict(model, preprocessed_data$X_test, type = "response"))
        
        print('Predictions results')
   
    } else if (model_type == "pretrained_lasso" && split != 'ALL') {
        
        X_test <- as.matrix(preprocessed_data$X_test, nrow = nrow(preprocessed_data$X_test))
        print('TABLE ################################')
        print(table(X_test[,4]))
        X_test[,4] <- 2
        print(table(X_test[,4]))

        preds  = predict(model, X_test[, -4], groupstest = X_test[,4], alphatype='varying')
        predictions = preds$yhatpre
        
        
    } else if (model_type == "pretrained_lasso" && split == 'ALL') {

        X_test = as.matrix(preprocessed_data$X_test)
        preds  = predict(model, X_test[, -4], groupstest = X_test[,4], alphatype='varying')
        predictions = preds$yhatpre
    }

    print('Dimensions:')
    print(dim(preprocessed_data$X_test))

    roc_curve <- roc(preprocessed_data$y_test, predictions)
    print('ROC-AUC:')
    print(auc(roc_curve))
    return(auc(roc_curve))
}

compute_roc_for_model <- function(model, preprocessed_data, model_type, split) {
    
    print(model_type)
    if (model_type == "l1_log_reg") {
        
        predictions <- predict(model, newx = as.matrix(preprocessed_data$X_test), type = "response")
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))

    } else if (model_type == "glinternet" && split != 'ALL') {
        
        print('Computing results with glinternet on WB_ancestry split')
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        preprocessed_data$X_test[,4] <- 1
        
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        predictions <- predict(model, preprocessed_data$X_test, type = "response")

    } else if (model_type == "glinternet" && split == 'ALL') {
        
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        preprocessed_data$X_test[, 4] <- preprocessed_data$X_test[, 4] - 1
        
        print('TABLE ################################')
        print(table(preprocessed_data$X_test[,4]))
        
        predictions <- as.vector(predict(model, preprocessed_data$X_test, type = "response"))
        
        print('Predictions results')
   
    } else if (model_type == "pretrained_lasso" && split != 'ALL') {
        
        X_test <- as.matrix(preprocessed_data$X_test, nrow = nrow(preprocessed_data$X_test))
        print('TABLE ################################')
        print(table(X_test[,4]))
        X_test[,4] <- 2
        print(table(X_test[,4]))

        preds  = predict(model, X_test[, -4], groupstest = X_test[,4], alphatype='varying')
        predictions = preds$yhatpre
        
        
    } else if (model_type == "pretrained_lasso" && split == 'ALL') {

        X_test = as.matrix(preprocessed_data$X_test)
        preds  = predict(model, X_test[, -4], groupstest = X_test[,4], alphatype='varying')
        predictions = preds$yhatpre
    }

    print('Dimensions:')
    print(dim(preprocessed_data$X_test))

    roc_curve <- roc(as.vector(preprocessed_data$y_test), as.vector(predictions))
    print('ROC-AUC:')
    print(auc(roc_curve))
    return(roc_curve)
}
