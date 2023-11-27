"""
Disease Cases Summary Module.

This module provides a function to summarize disease cases based on phenotypic data. 
It calculates the number of cases for different populations and disease statuses, 
and prints a summary including the ratio of cases between populations and the distribution of cases across different data splits.
"""

import pandas as pd

from constants import DISEASE_CODES

def cases_summary(pheno):
    """
    Summarizes disease cases based on phenotype DataFrame.

    Parameters:
    - pheno (DataFrame): Phenotype DataFrame containing population, disease codes, and data splits.

    Prints:
    - Summary of disease cases by population and data split.
    - Ratio of cases between South Asian and White British populations.
    """
    results = {}

    for disease_name, disease_code in DISEASE_CODES.items():
        counts = {}
        counts['SA_1'] = pheno[(pheno['population'] == 's_asian') & (pheno[disease_code] == 2)].shape[0]
        counts['WB_1'] = pheno[(pheno['population'] == 'white_british') & (pheno[disease_code] == 2)].shape[0]
        counts['SA_0'] = pheno[(pheno['population'] == 's_asian') & (pheno[disease_code] == 1)].shape[0]
        counts['WB_0'] = pheno[(pheno['population'] == 'white_british') & (pheno[disease_code] == 1)].shape[0]
        counts['SA_Train'] = pheno[(pheno['population'] == 's_asian') & (pheno[disease_code] == 2) & (pheno['final_split'] == 'train')].shape[0]
        counts['SA_Val'] = pheno[(pheno['population'] == 's_asian') & (pheno[disease_code] == 2) & (pheno['final_split'] == 'val')].shape[0]
        counts['SA_Test'] = pheno[(pheno['population'] == 's_asian') & (pheno[disease_code] == 2) & (pheno['final_split'] == 'test')].shape[0]

        results[disease_name] = counts

    for disease_name, counts in results.items():
        print(f"Disease Name: {disease_name}, Disease Code: {DISEASE_CODES[disease_name]}")
        disease_matrix = pd.DataFrame({'Disease 1': [counts['SA_1'], counts['WB_1']], 'Disease 0': [counts['SA_0'], counts['WB_0']]},
                                      index=['SA', 'WB'])
        print(disease_matrix)

        ratio_sa_wb = "NA (No WB cases)" if disease_matrix.loc['WB', 'Disease 1'] == 0 else disease_matrix.loc['SA', 'Disease 1'] / disease_matrix.loc['WB', 'Disease 1']
        print(f"Ratio of SA 1 to WB 1 cases: {ratio_sa_wb}")
        print(f"SA cases with disease in Train: {counts['SA_Train']}")
        print(f"SA cases with disease in Val: {counts['SA_Val']}")
        print(f"SA cases with disease in Test: {counts['SA_Test']}\n")
        