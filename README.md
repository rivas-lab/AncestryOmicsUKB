# Predictive Modeling Pipeline for Disease Risk Assessment

## Overview
This repository contains a comprehensive R script designed for predictive modeling in disease risk assessment. It integrates various data sources, including metabolomics, PRS (Polygenic Risk Scores), and phenotype data, to fit predictive models for different diseases. The script offers flexibility in model selection and the inclusion of specific population groups in the training process.

## Features
- **Model Selection**: Choose from models `glinternet`, `l1_log_reg`, or `pretrained_lasso`.
- **Population Specific Training**: Option to include only White British in training data.
- **Data Integration**: Combines metabolomics, PRS, and phenotype data from the UK Biobank.

## Getting Started
To use this pipeline, clone the repository and ensure you have the required R packages installed.

### Prerequisites
- R environment
- Necessary R libraries (listed in `requirements.txt`)

### Installation
Clone the repository to your local machine:
\```bash
git clone [repository-url]
\```

### Usage
Run the script from the command line with specified options:
\```R
Rscript [script-name].R --model [model-name] --only_wb_in_train [TRUE/FALSE] --folder [folder-name]
\```

- `-m` or `--model`: Specify the model (options: `glinternet`, `l1_log_reg`, `pretrained_lasso`).
- `-w` or `--only_wb_in_train`: Include only White British in training (TRUE or FALSE).
- `-f` or `--folder`: Name of the folder for saving models.

## Data Processing Steps
1. **Loading Datasets**: Metabolomics, PRS, and phenotype data are loaded.
2. **Data Preparation**: Data is prepared based on the selected disease codes.
3. **Preprocessing**: Data is preprocessed considering the chosen populations and options.
4. **Model Fitting**: Selected models are fit using cross-validation.

## Output
The script outputs models for each disease, stored in the specified directory structure.
