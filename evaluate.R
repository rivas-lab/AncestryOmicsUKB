library(optparse)
library(data.table)
library(dplyr)

option_list <- list(
  make_option(c("-a", "--ancestry"), type = "character", default = "AF", 
              help = "Ancestry group", metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

ancestry <- opt$ancestry

source('src/constants.R')
source('src/evaluate.R')

set.seed(1001)

# Function to get all RDS model file paths
get_model_paths <- function(base_dir) {
  list.files(base_dir, full.names = TRUE, recursive = TRUE, pattern = "\\.rds$")
}

# Function to extract model type, split, and disease code from a given path
extract_details <- function(path) {
  parts <- strsplit(path, "/")[[1]]
  model_type_index <- length(parts) - 2  # Index of the model type in the path
  split_index <- length(parts) - 1  # Index of the split in the path

  # Check if the index is valid and extract model_type
  model_type <- ifelse(model_type_index > 0 && model_type_index <= length(parts), parts[model_type_index], NA)
    
  list(
    model_type = model_type,
    split = parts[split_index],
    disease_code = tools::file_path_sans_ext(basename(path))
  )
}

base_model_dir_path <- paste0('models/', ancestry)

model_paths <- get_model_paths(base_model_dir_path)

disease_codes <- unique(sapply(lapply(model_paths, extract_details), `[[`, "disease_code"))

model_types <- c("glinternet", "l1_log_reg", "pretrained_lasso")
splits      <-   c(paste0("WB_", ancestry), ancestry, 'ALL')

auc_scores <- matrix(NA, nrow = length(model_types) * length(splits), ncol = length(disease_codes))
rownames(auc_scores) <- expand.grid(model_types, splits, stringsAsFactors = FALSE)[, 1:2] %>% apply(1, paste, collapse = " ")
colnames(auc_scores) <- disease_codes

# Evaluate models and store AUC scores
for (path in model_paths) {
  details <- extract_details(path)
  print(details)
    
  # Ensure no leading or trailing spaces
  row_name <- trimws(paste(details$model_type, details$split, sep = " "))
  print('Split')
  print(details$split)
  print(paste("Row Name:", row_name))

  if (row_name %in% rownames(auc_scores) && details$disease_code %in% colnames(auc_scores)) {
    print(details)
    cv_fit <- readRDS(path)
    print(path)

    print('Details:')
    print(details)

    X_test_path = paste0('./datasets/', ancestry, '/X_test_', details$disease_code, '.rds')
    print(X_test_path)
    X_test = readRDS(X_test_path)
    stopifnot(length(unique(X_test[, 4])) == 1)

    y_test_path = paste0('./datasets/', ancestry, '/y_test_', details$disease_code, '.rds')
    print(y_test_path)
    y_test = readRDS(y_test_path)
          
    preprocessed_data <- list(X_test = X_test, y_test = y_test)

    print('Calling AUC function')
    auc_score <- compute_auc_for_model(cv_fit, preprocessed_data, details$model_type, details$split)
    print(row_name)
    print(details$disease_code)
    print(auc_score)
      
    print('Checking everything is added correctly..')
    print(paste('Rowname:', row_name))
    print(paste('disease:', details$disease_code))
    print(paste('path:', path))
    if (!is.na(auc_scores[row_name, details$disease_code])) {
      stop(paste("AUC score already assigned for", row_name, "and disease code", details$disease_code, ". Execution halted."))
    }
    auc_scores[row_name, details$disease_code] <- auc_score
  }
}

write.csv(auc_scores, file = paste0("scores/auc_scores_", ancestry, "_final_final.csv"), row.names = TRUE)

print("AUC scores saved to auc_scores.csv")
