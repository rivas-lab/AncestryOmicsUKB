# multiomics

Usage
Run the script from the command line with specified options:

R
Copy code
Rscript [script-name].R --model [model-name] --only_wb_in_train [TRUE/FALSE] --folder [folder-name]
-m or --model: Specify the model (options: glinternet, l1_log_reg, pretrained_lasso).
-w or --only_wb_in_train: Include only White British in training (TRUE or FALSE).
-f or --folder: Name of the folder for saving models.
Data Processing Steps

Loading Datasets: Metabolomics, PRS, and phenotype data are loaded.
Data Preparation: Data is prepared based on the selected disease codes.
Preprocessing: Data is preprocessed considering the chosen populations and options.
Model Fitting
