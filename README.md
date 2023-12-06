# Predictive Modeling Pipeline for Disease Risk Assessment

## Overview
This repository contains a comprehensive R script designed for predictive modeling in disease risk assessment. It integrates various data sources, including metabolomics, PRS (Polygenic Risk Scores), and phenotype data, to fit predictive models for different diseases. The script offers flexibility in model selection and the inclusion of specific population groups in the training process.

## Features
- **Model Selection**: Choose from models `glinternet`, `l1_log_reg`, or `pretrained_lasso`.
- **Population Specific Training**: Option to include only White British, White British and an ancestry in training data.
- **Data Integration**: Combines metabolomics, PRS, and phenotype data from the UK Biobank.

## Getting Started
To use this pipeline, clone the repository and ensure you have the required R packages installed.

### Prerequisites
- R environment
- Necessary R libraries (listed in `requirements.txt`)

### Installation
Clone the repository to your local machine:
```bash
git clone [repository-url]
```

### Usage
Run the script from the command line with specified options:
```R
Rscript [script-name].R --model [model-name] --only_ancestry_in_train [TRUE/FALSE] --folder [folder-name] --ancestry [ancestry-group]
```

#### Options:
- `-m` or `--model`: Model to use (`glinternet`, `l1_log_reg`, `pretrained_lasso`).
- `-w` or `--only_ancestry_in_train`: Include only a specific ancestry group in training (TRUE or FALSE).
- `-f` or `--folder`: Folder name for saving models.
- `-a` or `--ancestry`: Ancestry group to include in the model.

## Data Processing Steps
1. **Loading Datasets**: Loads metabolomics, PRS, and phenotype data.
2. **Data Preparation and Preprocessing**: Prepares and preprocesses the data for the selected disease codes and populations.
3. **Model Fitting**: Fits models using cross-validation and stores them in a structured directory.

## Output
The script outputs models for each disease, stored in the specified directory structure.
