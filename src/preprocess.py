"""
Data Preparation and Preprocessing Module.

This module provides functions for preparing and preprocessing data for machine learning tasks. 
It includes functions to prepare data by managing splits and merging demographic information, 
as well as a function to preprocess data by filtering based on populations, handling missing values, 
and preparing datasets for training and testing.
"""
import pandas as pd
import numpy as np

def prepare_data(meta, prs, pheno):
    """
    Prepares data by merging demographic information and handling data splits.

    Parameters:
    - meta (DataFrame): Metabolomics DataFrame.
    - prs (DataFrame): Polygenic risk scores DataFrame.
    - pheno (DataFrame): Phenotype DataFrame.

    Returns:
    - dict: Dictionary containing prepared meta, pheno, demo, and prs DataFrames.
    """
    prs['final_split'] = pheno['split_nonWB'].fillna(prs['split'])
    pheno['final_split'] = pheno['split_nonWB'].fillna(prs['split'])
    meta['final_split'] = pheno['split_nonWB'].fillna(prs['split'])

    global_pc_cols = [f"Global_PC{i}" for i in range(1, 41)]
    pc_cols = [f"PC{i}" for i in range(1, 41)]
    drop_cols = global_pc_cols + pc_cols + ['split', 'IID', 'age', 'age0', 'age1', 'age2', 'age3', 'sex', 'BMI', 'N_CNV', 'LEN_CNV', 'Array']

    demo_cols = ['age', 'sex', 'population'] + pc_cols[:10] + global_pc_cols
    demo      = meta[demo_cols]
    meta      = meta.drop(columns=drop_cols)

    meta = pd.concat([demo[['sex', 'age']], meta], axis=1)
    demo = demo.drop(columns=['age', 'sex'])

    return {'meta': meta, 'pheno': pheno, 'demo': demo, 'prs': prs}

def preprocess_data(populations, disease, pheno, meta, prs, use_prs, demo, use_demo):
    """
    Preprocesses data for machine learning models, handling population filtering, PRS, and demographic data.

    Parameters:
    - populations (list): List of populations to filter by.
    - disease (str): Disease column name in pheno DataFrame.
    - pheno, meta, prs, demo (DataFrame): DataFrames for phenotypes, metabolomics, polygenic risk scores, and demographic data.
    - use_prs, use_demo (bool): Flags to include PRS scores and demographic data.

    Returns:
    - dict: Dictionary containing preprocessed training and testing sets (X_train, y_train, X_test, y_test).
    """
    np.random.seed(123)

    y = pheno[pheno['population'].isin(populations)]
    X = meta[meta['population'].isin(populations)]

    if use_prs:
        prs_column = f'PRS_{disease}'
        prs_subset = prs[prs['population'].isin(populations)][[prs_column]]
        X = pd.concat([prs_subset, X], axis=1)

    if use_demo:
        demo_subset = demo[demo['population'].isin(populations)].drop(columns=['population'])
        X = pd.concat([X, demo_subset], axis=1)

    valid_y_indices = y[disease].isin([1, 2])
    y = y[valid_y_indices]
    X = X.loc[valid_y_indices]

    X['population'] = np.where(X['population'] == "white_british", 0, np.where(X['population'] == "s_asian", 1, np.nan))
        
    y_train = y[y['final_split'].isin(['train', 'val'])][disease]
    y_test  = y[(y['final_split'] == 'test') & (y['population'] == 's_asian')][disease]

    X_train = X[X['final_split'].isin(['train', 'val'])]
    X_test  = X[(X['final_split'] == 'test') & (X['population'] == 1)]

    X_train.drop(columns=['final_split'], inplace=True)
    X_test.drop(columns=['final_split'], inplace=True)

    # Impute missing numeric values in training and testing sets
    for col in X_train.columns:
        if X_train[col].dtype == np.number:
            X_train[col] = X_train[col].fillna(X_train[col].mean())
    for col in X_test.columns:
        if X_test[col].dtype == np.number:
            X_test[col] = X_test[col].fillna(X_test[col].mean())

    y_train -= 1
    y_test -= 1

    return {'X_train': X_train, 'y_train': y_train, 'X_test': X_test, 'y_test': y_test}
