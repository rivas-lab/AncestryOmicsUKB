library(optparse)
library(data.table)
library(glmnet)  # Load glmnet package
library(glinternet)  # Load glinternet package

source('src/sampling.R')
source('src/constants.R')
source('src/statistics.R')
source('src/preprocess.R')
source('src/evaluate.R')
source('src/fit.R')

set.seed(1001)

# Function to get all RDS model file paths
get_model_paths <- function(base_dir) {
  list.files(base_dir, full.names = TRUE, recursive = TRUE, pattern = "\\.rds$")
}

# Function to extract model type, split, and disease code from a given path
extract_details <- function(path) {
  print(path)
  parts <- strsplit(path, "/")[[1]]
  model_type_index <- length(parts) - 2  # Index of the model type in the path
  split_index <- length(parts) - 1  # Index of the split in the path

  # Check if the index is valid and extract model_type
  model_type <- ifelse(model_type_index > 0 && model_type_index <= length(parts), parts[model_type_index], NA)
  print(model_type)
    
  list(
    model_type = model_type,
    split = parts[split_index],
    disease_code = tools::file_path_sans_ext(basename(path))
  )
}

base_model_dir_path <- 'models'

model_paths <- get_model_paths(base_model_dir_path)

disease_codes <- unique(sapply(lapply(model_paths, extract_details), `[[`, "disease_code"))

model_types <- c("glinternet", "l1_log_reg", "pretrained_lasso")
splits <- c("WB_only", "WB_SA", "SA")

auc_scores <- matrix(NA, nrow = length(model_types) * length(splits), ncol = length(disease_codes))
rownames(auc_scores) <- expand.grid(model_types, splits, stringsAsFactors = FALSE)[, 1:2] %>% apply(1, paste, collapse = " ")
colnames(auc_scores) <- disease_codes

meta  <- fread('data/meta.csv')
prs   <- fread('data/prs.csv')
pheno <- fread('data/pheno.csv')

# Evaluate models and store AUC scores
for (path in model_paths) {
  details <- extract_details(path)
  print(details)
    
  # Ensure no leading or trailing spaces
  row_name <- trimws(paste(details$model_type, details$split, sep = " "))

  print(paste("Row Name:", row_name))

  if (row_name %in% rownames(auc_scores) && details$disease_code %in% colnames(auc_scores)) {
    cv_fit <- readRDS(path)
    prepared_data <- prepare_data(meta, prs, pheno)
    preprocessed_data <- preprocess_data(
      list('white_british', 's_asian'), details$disease_code, prepared_data$pheno,
      prepared_data$meta, prepared_data$prs, use_prs=TRUE, prepared_data$demo, use_demo=TRUE, only_wb_in_train=TRUE)
    
    sx = apply(preprocessed_data$X_train, 2, sd)
    cv_fit$sx = sx
      
    print('Calling AUC function')
    auc_score <- compute_auc_for_model(cv_fit, preprocessed_data, details$model_type)
    auc_scores[row_name, details$disease_code] <- auc_score
  }
}

# Save AUC scores to CSV file
write.csv(auc_scores, file = "scores/auc_scores.csv", row.names = TRUE)

print("AUC scores saved to auc_scores.csv")
