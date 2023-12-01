library(pROC)

source('src/constants.R')

print_interactions_and_main_effects <- function(cv_fit, preprocessed_data) {
    # Extracting the index where lambdaHat1Std equals lambda
    i_1Std <- which(cv_fit$lambdaHat1Std == cv_fit$lambda)
    coefs <- coef(cv_fit$glinternetFit)[[i_1Std]]

    # Processing main effects
    main_effects <- coefs$mainEffects$cont
    cat('Main effects:\n')
    for (effect in main_effects) {
        col_index <- effect
        print(colnames(preprocessed_data$X_train[, ..col_index]))
    }

    # Processing interactions
    cat('\nInteractions:\n')
    if (length(coefs$interactions$catcont) > 0) {
        for (row in 1:nrow(coefs$interactions$catcont)) {
            var_idx <- (coefs$interactions$catcont[row, 2])
            print(colnames(preprocessed_data$X_train[, ..var_idx]))
        }
    }
}

compute_and_print_roc_auc <- function(cv_fit, preprocessed_data) {

    X_test <- preprocessed_data$X_test
    y_test <- preprocessed_data$y_test

    predictions <- as.vector(predict(cv_fit, X_test, type = "response"))

    roc_curve <- suppressMessages(roc(y_test, predictions, quietly = TRUE))
    auc_score <- auc(roc_curve)
    cat('\nAUC score: ', auc_score)
    cat('\n\n####################################################################################################')
    cat('\n####################################################################################################\n')

    # Return the AUC score
    return(auc_score)
}

cases_summary <- function(pheno) {

    results <- list()

    for (disease_name in names(DISEASE_CODES)) {
        disease_code <- DISEASE_CODES[disease_name]

        s_asian_cases_1       <- sum(pheno$population == "s_asian" & pheno[[disease_code]] == 2, na.rm = TRUE)
        white_british_cases_1 <- sum(pheno$population == "white_british" & pheno[[disease_code]] == 2, na.rm = TRUE)
        s_asian_cases_0       <- sum(pheno$population == "s_asian" & pheno[[disease_code]] == 1, na.rm = TRUE)
        white_british_cases_0 <- sum(pheno$population == "white_british" & pheno[[disease_code]] == 1, na.rm = TRUE)

        # Count SA cases with disease in each final_split category
        s_asian_cases_train <- sum(
            pheno$population == "s_asian" 
            & pheno[[disease_code]] == 2 
            & pheno$final_split == "train", 
            na.rm = TRUE)
        
        s_asian_cases_val   <- sum(
            pheno$population == "s_asian"
            & pheno[[disease_code]] == 2 
            & pheno$final_split == "val", 
            na.rm = TRUE)
        
        s_asian_cases_test  <- sum(
            pheno$population == "s_asian" 
            & pheno[[disease_code]] == 2 
            & pheno$final_split == "test", 
            na.rm = TRUE)

        results[[disease_name]] <- c(
            SA_1 = s_asian_cases_1, WB_1 = white_british_cases_1, 
            SA_0 = s_asian_cases_0, WB_0 = white_british_cases_0,
            SA_Train = s_asian_cases_train, SA_Val = s_asian_cases_val, SA_Test = s_asian_cases_test)
    }

    for (disease_name in names(results)) {
        disease_code <- DISEASE_CODES[disease_name]
        cat("Disease Name:", disease_name, "\nDisease Code:", disease_code, "\n")

        disease_matrix <- matrix(unlist(results[[disease_name]][1:4]), nrow = 2, byrow = TRUE, 
                                 dimnames = list(c("SA", "WB"), c("Disease 1", "Disease 0")))
        print(disease_matrix)

        # Calculate and print the ratio of SA 1 to WB 1 cases
        ratio_sa_wb <- ifelse(disease_matrix[2,1] > 0, disease_matrix[1,1] / disease_matrix[2,1], "NA (No WB cases)")
        cat("Ratio of SA 1 to WB 1 cases:", ratio_sa_wb, "\n")

        # Print the number of SA cases with disease in each final_split category
        cat("SA cases with disease in Train:", results[[disease_name]]["SA_Train"], "\n")
        cat("SA cases with disease in Val:", results[[disease_name]]["SA_Val"], "\n")
        cat("SA cases with disease in Test:", results[[disease_name]]["SA_Test"], "\n\n")
    }
        }
