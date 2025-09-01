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

preprocess_data <- function(populations, disease, pheno, meta, prs, demo, model) {
    
    set.seed(123)

    y <- subset(pheno, population %in% populations)
    X <- subset(meta,  population %in% populations)
    
    print('Pop of X before encoding before train-test split')
    print(table(X$population))
    
    prs_column <- paste0('PRS_', disease)
    prs_subset <- subset(prs, population %in% populations, select = prs_column)
    X          <- cbind(prs_subset, X)
    
    demo_subset            <- subset(demo, population %in% populations)
    demo_subset$population <- NULL 
    X                      <- cbind(X, demo_subset)
    
    # Ensure y only contains 1 or 2, and filter X accordingly
    valid_y_indices <- which(y[[disease]] %in% c(1, 2))
    y <- y[valid_y_indices,]
    X <- X[valid_y_indices,]
    
    positions    <- match(X$population, ANCESTRY_LIST)
    X$population <- as.numeric(ANCESTRY_CODE[names(ANCESTRY_LIST)[positions]])
    
    if (model == 'pretrained_lasso') {
        X$population <- ifelse(X$population != 1, 2, X$population)
    }
    print('Pop of X after encoding before train-test split')
    print(table(X$population), useNA = "always")
    
    y_train <- subset(y, final_split %in% c('train', 'val'))[[disease]]
    X_train <- subset(X, final_split %in% c('train', 'val'))

    print('Pop of X after encoding after train-test split')
    print(table(X_train$population))
    
    X_train$final_split <- NULL

    X_train <- X_train %>% 
  mutate(across(.cols = -c(population, sex),
                .fns = ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
    
    X_train <- replace_na_columns_with_zeros(X_train)
    y_train <- y_train - 1

    return(list(X_train = X_train, y_train = y_train))
}

print_train_stats <- function(X_train, y_train, populations) {
    
    combined_df          <- cbind(X_train, data.frame(y_train = y_train))

    combined_df$combined <- paste(combined_df$population, combined_df$y_train, sep = "-")
    value_counts <- table(combined_df$combined)
    print(value_counts)
    
}

replace_na_columns_with_zeros <- function(dt) {
  for (column in names(dt)) {
    if (all(is.na(dt[[column]]))) {
      set(dt, j = column, value = 0)
    }
  }
  if (any(sapply(dt, function(col) all(is.na(col))))) {
    stop("There are still columns with only NAs")
  }
  return(dt)
}
