# Using Pre-training and Interaction Modeling for ancestry-specific disease prediction using multiomics data from the UK Biobank

![GitHub](https://img.shields.io/github/license/rivas-lab/AncestryOmicsUKB)
![Github](https://img.shields.io/badge/status-under_development-yellow)

![Biobank Image](https://github.com/rivas-lab/multiomics/raw/main/images/diagram_ukb.jpg)

## Abstract
Recent genome-wide association studies (GWAS) have uncovered the genetic basis of complex traits, but show an under-representation of non-European descent individuals, underscoring a critical gap in genetic research. Here, we assess whether we can improve disease prediction across diverse ancestries using multiomic data. We evaluate the performance of Group-LASSO INTERaction-NET (glinternet) and pretrained lasso in disease prediction focusing on diverse ancestries in the UK Biobank. Models were trained on data from White British and other ancestries and validated across a cohort of over 96,000 individuals for 8 diseases. Out of 96 models trained, we report 16 with statistically significant incremental predictive performance in terms of ROC-AUC scores (p-value < 0.05), found for diabetes, arthritis, gall stones, cystitis, asthma and osteoarthritis. For the interaction and pretrained models that outperformed the baseline, the PRS score was the primary driver behind prediction. Our findings indicate that both interaction terms and pre-training can enhance prediction accuracy but for a limited set of diseases and moderate improvements in accuracy.

## Getting Started
To use this pipeline, clone the repository and ensure you have the required R packages installed.

### Prerequisites
- R environment
- Necessary R libraries (listed in `requirements.txt`)

### Installation
Clone the repository to your local machine:
```bash
git clone https://github.com/rivas-lab/AncestryOmicsUKB.git
```
