source('constants.R')

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
