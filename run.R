library(optparse) 

source('src/constants.R')
source('src/statistics.R')
source('src/preprocess.R')
source('src/fit.R')

set.seed(1001)

option_list <- list(
    make_option(c("-m", "--model"), type="character", 
                help="Model desired: glinternet, l1_log_reg or pretrained_lasso", 
                metavar="character"),
    make_option(c("-f", "--folder"), type="character",
                help="Folder name for saving models", 
                metavar="character"),
    make_option(c("-a", "--ancestry"), type="character", 
                help="Ancestry group to include in the model",
                metavar="character"),
    make_option(c("-o", "--only_ancestry_in_train"), type="logical", 
                default=FALSE, metavar="logical",
                help="Only include Ancestry people in training: TRUE or FALSE")
)

parser <- OptionParser(option_list=option_list)
args   <- parse_args(parser)

required_options <- c("model", "folder", "ancestry")
for (option in required_options) {
  if (is.null(args[[option]]) || args[[option]] == "") {
    cat(sprintf("Error: --%s is required and cannot be empty.\n", option))
    quit(save = "no", status = 1)  
  }
}

model_desired          <- args$model
folder                 <- args$folder
ancestry               <- args$ancestry  
only_ancestry_in_train <- args$only_ancestry_in_train

# 3 different datasets: WB and ancestry, All ancestries or ancestry-only
if (folder == 'ALL') { 
    populations <- tolower(unname(ANCESTRY_LIST))
} else if (only_ancestry_in_train == TRUE) {
    populations <- c(ANCESTRY_LIST[ancestry])
} else {
    populations <- c('white_british', ANCESTRY_LIST[ancestry])
}

print('Populations:')
print(populations)

model_dir_path <- paste0('models/', ancestry, '/', model_desired, '/', folder, '/')
print(paste0('Model dir path: ', model_dir_path))

print('Loading datasets...')

meta  = fread('data/meta.csv')
print('Loaded metabolomics data...')

prs    = fread('data/prs.csv')
print('Loaded PRS data...')

pheno = fread('data/pheno.csv')
print('Loaded phenotype data...')

for (disease in DISEASE_CODES) {
    
    prepared_data <- prepare_data(meta, prs, pheno)
    preprocessed_data <- preprocess_data(
        populations, 
        disease, 
        prepared_data$pheno, 
        prepared_data$meta, 
        prepared_data$prs, 
        prepared_data$demo,
        model_desired)
    
    system.time({cv_fit <- fit_models(
        model_dir_path, disease, preprocessed_data, 
        update_models=FALSE, model_desired=model_desired)})
}
