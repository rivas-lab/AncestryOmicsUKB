"""
Data Sampling Module.

This module provides a suite of functions designed for data sampling in the context of machine learning model preparation. 
It includes various sampling strategies tailored for datasets with imbalances, particularly useful in disease prediction 
and other biomedical applications. The module offers ratio sampling, under sampling, and an option to bypass sampling, 
accommodating different scenarios in dataset preprocessing.

Functions:
    sample_data - Directs to a specific sampling method based on input.
    ratio_sampling - Balances the dataset based on a specified ratio between two groups.
    under_sampling - Balances the dataset by under-sampling the majority group.
    skip_sampling - Returns the data without applying any sampling.
    print_train_stats - Prints statistics of the training dataset.
"""

import pandas as pd
import numpy as np

def sample_data(prepared_data, sampling_method, ratio_wb_to_sa=None):
    """
    Selects and applies a sampling method to the prepared data.

    Parameters:
    - prepared_data (dict): A dictionary containing the training and test datasets.
    - sampling_method (str): The method of sampling to be used ('skip_sampling', 'ratio_sampling', or 'under_sampling').
    - ratio_wb_to_sa (float, optional): The ratio of White British to South Asian samples to be used in ratio sampling.

    Returns:
    - dict: A dictionary containing the sampled training and test datasets.
    """
    if sampling_method == 'skip_sampling':
        return skip_sampling(prepared_data)
    elif sampling_method == 'ratio_sampling':
        return ratio_sampling(prepared_data, ratio_wb_to_sa)
    elif sampling_method == 'under_sampling':
        return under_sampling(prepared_data)

def ratio_sampling(prepared_data, ratio_wb_to_sa):
    """
    Applies ratio sampling to the training data based on a specified ratio.

    Parameters:
    - prepared_data (dict): A dictionary containing the training and test datasets.
    - ratio_wb_to_sa (float): The ratio of White British to South Asian samples in the dataset.

    Returns:
    - dict: A dictionary containing the sampled training and test datasets.
    """
    X_train, X_test = prepared_data['X_train'], prepared_data['X_test']
    y_train, y_test = prepared_data['y_train'], prepared_data['y_test']

    sa_indices = X_train[X_train['population'] == 1].index

    num_sa_with_disease = sum((X_train['population'] == 1) & (y_train == 1))
    num_sa_without_disease = sum((X_train['population'] == 1) & (y_train == 0))

    wb_indices_with_disease = X_train[(X_train['population'] == 0) & (y_train == 1)].index
    wb_indices_without_disease = X_train[(X_train['population'] == 0) & (y_train == 0)].index

    num_to_sample_wb_with = min(num_sa_with_disease * ratio_wb_to_sa, len(wb_indices_with_disease))
    ratio_sa_0_to_sa_1 = num_sa_without_disease / num_sa_with_disease
    num_to_sample_wb_without = min(ratio_sa_0_to_sa_1 * num_to_sample_wb_with, len(wb_indices_without_disease))

    sampled_wb_indices_with_disease = np.random.choice(wb_indices_with_disease, num_to_sample_wb_with, replace=False)
    sampled_wb_indices_without_disease = np.random.choice(wb_indices_without_disease, num_to_sample_wb_without, replace=False)

    final_indices_train_val = np.concatenate((sa_indices, sampled_wb_indices_with_disease, sampled_wb_indices_without_disease))

    X_train = X_train.loc[final_indices_train_val]
    y_train = y_train.loc[final_indices_train_val]

    print_train_stats(X_train, y_train)

    return {'X_train': X_train, 'y_train': y_train, 'X_test': X_test, 'y_test': y_test}

def under_sampling(prepared_data):
    """
    Applies under-sampling to balance the dataset by reducing the number of samples in the majority class.

    Parameters:
    - prepared_data (dict): A dictionary containing the training and test datasets.

    Returns:
    - dict: A dictionary containing the under-sampled training and test datasets.
    """
    X_train, X_test = prepared_data['X_train'], prepared_data['X_test']
    y_train, y_test = prepared_data['y_train'], prepared_data['y_test']

    sa_with_disease = X_train[(X_train['population'] == 1) & (y_train == 1)].index
    sa_without_disease = X_train[(X_train['population'] == 1) & (y_train == 0)].index
    wb_with_disease = X_train[(X_train['population'] == 0) & (y_train == 1)].index
    wb_without_disease = X_train[(X_train['population'] == 0) & (y_train == 0)].index

    num_sa_with = len(sa_with_disease)
    num_wb_with = len(wb_with_disease)

    sampled_sa_without_disease = np.random.choice(sa_without_disease, min(num_sa_with, len(sa_without_disease)), replace=False)
    sampled_wb_without_disease = np.random.choice(wb_without_disease, min(num_wb_with, len(wb_without_disease)), replace=False)

    final_indices_train_val = np.concatenate((sa_with_disease, sampled_sa_without_disease, wb_with_disease, sampled_wb_without_disease))

    X_train = X_train.loc[final_indices_train_val]
    y_train = y_train.loc[final_indices_train_val]

    print_train_stats(X_train, y_train)

    return {'X_train': X_train, 'y_train': y_train, 'X_test': X_test, 'y_test': y_test}

def skip_sampling(prepared_data):
    """
    Returns the prepared data without applying any sampling, essentially 'skipping' the sampling step.

    Parameters:
    - prepared_data (dict): A dictionary containing the training and test datasets.

    Returns:
    - dict: The same dictionary that was passed as input, unaltered.
    """
    X_train, X_test = prepared_data['X_train'], prepared_data['X_test']
    y_train, y_test = prepared_data['y_train'], prepared_data['y_test']

    print_train_stats(X_train, y_train)

    return {'X_train': X_train, 'y_train': y_train, 'X_test': X_test, 'y_test': y_test}

def print_train_stats(X_train, y_train):
    """
    Prints statistics of the training dataset, particularly focusing on the population distribution and disease prevalence.

    Parameters:
    - X_train (DataFrame): The training dataset features.
    - y_train (Series): The training dataset labels.
    """
    combined_df = pd.concat([X_train, y_train.rename('y_train')], axis=1)
    combined_df['population'] = combined_df['population'].map({0: "WB", 1: "SA"})
    combined_df['combined'] = combined_df['population'] + "-" + combined_df['y_train'].astype(str)
    value_counts = combined_df['combined'].value_counts()
    print(value_counts)
    