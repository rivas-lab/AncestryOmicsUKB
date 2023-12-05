library(pROC)  

compute_auc_for_model <- function(model, preprocessed_data, model_type) {
    
    print(model_type)
    if (model_type == "l1_log_reg") {
        
        predictions <- predict(model, newx = as.matrix(preprocessed_data$X_test), type = "response")
        
    } else if (model_type == "glinternet") {
        
        predictions <- as.vector(predict(model, preprocessed_data$X_test, type = "response"))
        
    } else if (model_type == "pretrained_lasso") {
        
        print('Model mx')
        print(model$mx)
        
        print('Model sx')
        print(model$sx)
        
        X_test <- as.matrix(preprocessed_data$X_test, nrow = nrow(preprocessed_data$X_test))
        X_test <- scale(X_test, model$mx, model$sx)

        lamhat4 = model$lambda.min
        offset  = (1 - model$best_alpha) * predict(model$cv_fit_pan_ethnicity, X_test, s = model$lamhat)
        
        predictions = predict(model, X_test, s = lamhat4, newoffset = offset,type="response")
        
    } else {
        stop("Unsupported model type: ", model_type)
    }
    roc_curve <- roc(preprocessed_data$y_test, predictions)
    return(auc(roc_curve))
}
