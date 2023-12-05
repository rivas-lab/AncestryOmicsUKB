library(optparse) 

source('src/sampling.R')
source('src/constants.R')
source('src/statistics.R')
source('src/preprocess.R')
source('src/fit.R')

set.seed(1001)

option_list <- list(
    make_option(c("-m", "--model"), type="character", default="l1_log_reg", 
                help="Model desired: glinternet, l1_log_reg or pretrained_lasso", metavar="character"),
    make_option(c("-w", "--only_wb_in_train"), type="logical", default=FALSE, 
                help="Only include White British in training: TRUE or FALSE", metavar="logical"),
    make_option(c("-f", "--folder"), type="character", default="SA",
                help="Folder name for saving models", metavar="character")
)

parser <- OptionParser(option_list=option_list)
args <- parse_args(parser)

model_desired    <- args$model
only_wb_in_train <- args$only_wb_in_train
folder           <- args$folder

populations <- list('white_british', 's_asian')

model_dir_path <- paste0('models/', paste0(model_desired, '/'), folder)

print(paste0('Model dir path: ', model_dir_path))

print('Loading datasets...')

meta  = fread('data/meta.csv')
print('Loaded metabolomics data...')

prs    = fread('data/prs.csv')
print('Loaded PRS data...')

pheno = fread('data/pheno.csv')
print('Loaded phenotype data...')

aucs <- list()

for (disease in DISEASE_CODES) {
    
    prepared_data <- prepare_data(meta, prs, pheno)
    preprocessed_data <- preprocess_data(
        populations, disease, 
        prepared_data$pheno, prepared_data$meta, 
        prepared_data$prs, use_prs=TRUE, 
        prepared_data$demo, use_demo=TRUE,
        only_wb_in_train=only_wb_in_train
    )
    
    system.time({cv_fit <- fit_models(
        model_dir_path, disease, preprocessed_data, 
        update_models=FALSE, model_desired=model_desired)})
}
