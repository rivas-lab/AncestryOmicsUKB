library(dplyr)

prepare_data <- function(meta, prs, pheno) {
    
    prs$final_split   <- ifelse(is.na(pheno$split_nonWB), prs$split, pheno$split_nonWB)
    pheno$final_split <- ifelse(is.na(pheno$split_nonWB), prs$split, pheno$split_nonWB)
    meta$final_split  <- ifelse(is.na(pheno$split_nonWB), prs$split, pheno$split_nonWB)
    
    global_pc_cols    <- paste0("Global_PC", 1:40)
    pc_cols           <- paste0("PC", 1:40)
    drop_cols         <- c(global_pc_cols, pc_cols, 'split','IID','age', 'age0', 'age1', 'age2', 'age3', 'sex', 'BMI', 'N_CNV', 'LEN_CNV', 'Array')
    
    global_pc_cols    <- paste0("Global_PC", 1:40)
    pc_cols           <- paste0("PC", 1:10)
    demo_cols         <- c('age', 'sex', 'population', pc_cols, global_pc_cols)
    
    demo <- subset(meta, select = which(names(meta) %in% demo_cols))
    meta <- subset(meta, select = -which(names(meta) %in% drop_cols))
    
    column_to_add <- demo$sex
    meta <- cbind (sex = column_to_add, meta)

    column_to_add <- demo$age
    meta <- cbind (age = column_to_add, meta)
    
    demo$age <- NULL
    demo$sex <- NULL
    
    return(list(meta = meta, pheno = pheno, demo = demo, prs = prs))
}

preprocess_data <- function(populations, disease, pheno, meta, prs, use_prs, demo, use_demo) {
    
    set.seed(123)

    y <- subset(pheno, population %in% populations)
    X <- subset(meta, population %in% populations)
    
    # Add PRS scores column to the X dataframe
    if (use_prs == TRUE){
        prs_column <- paste0('PRS_', disease)
        prs_subset <- subset(prs, population %in% populations, select = prs_column)
        X          <- cbind(prs_subset, X)
        }
    
    # Add demographics columns to the X dataframe
    if (use_demo == TRUE) {
        demo_subset            <- subset(demo, population %in% populations)
        demo_subset$population <- NULL 
        X           <- cbind(X, demo_subset)
    }
    
    # Ensure y only contains 1 or 2, and filter X accordingly
    valid_y_indices <- which(y[[disease]] %in% c(1, 2))
    y <- y[valid_y_indices,]
    X <- X[valid_y_indices,]

    X$population <- ifelse(X$population == "white_british", 0, ifelse(X$population == "s_asian", 1, NA))
        
    y_train <- subset(y, final_split %in% c('train', 'val'))[[disease]]
    y_test <- subset(y, final_split == 'test' & population == 's_asian')[[disease]]

    X_train <- subset(X, final_split %in% c('train', 'val'))
    X_test      <- subset(X, final_split == 'test' & population == 1)
    
    X_train$final_split     <- NULL
    X_test$final_split      <- NULL

    # Impute missing numeric values in training and testing sets
    X_train     <- X_train %>% mutate(across(where(is.numeric), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
    X_test      <- X_test %>% mutate(across(where(is.numeric), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))

    y_train <- y_train - 1
    y_test  <- y_test  - 1
    
    print(X_train)
    return(list(X_train = X_train, y_train = y_train, X_test = X_test, y_test = y_test))
}