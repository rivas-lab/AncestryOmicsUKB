sample_data <- function(prepared_data, sampling_method, ratio_wb_to_sa) {
    
    if (sampling_method == 'skip_sampling') {
        return (skip_sampling(prepared_data))
    }
    
    if (sampling_method == 'ratio_sampling') {
        return (ratio_sampling(prepared_data, ratio_wb_to_sa))
    }
    
    if (sampling_method == 'under_sampling') {
        return (under_sampling(prepared_data))
    }   
}

ratio_sampling <- function(prepared_data, ratio_wb_to_sa) {
    
    X_train = prepared_data$X_train
    X_test  = prepared_data$X_test
    
    y_train = prepared_data$y_train
    y_test  = prepared_data$y_test

    # Include all South Asian cases in training set
    sa_indices <- which(X_train$population == 1)

    # Count of South Asian cases with and without disease
    num_sa_with_disease    <- sum(X_train$population == 1 & y_train == 1)
    num_sa_without_disease <- sum(X_train$population == 1 & y_train == 0)

    # Calculate WB samples to pick
    wb_indices_with_disease    <- which(X_train$population == 0 & y_train == 1)
    wb_indices_without_disease <- which(X_train$population == 0 & y_train == 0)

    num_to_sample_wb_with    <- min(num_sa_with_disease * ratio_wb_to_sa, length(wb_indices_with_disease))
    ratio_sa_0_to_sa_1       <- num_sa_without_disease / num_sa_with_disease
    num_to_sample_wb_without <- min(ratio_sa_0_to_sa_1 * num_to_sample_wb_with, length(wb_indices_without_disease))

    sampled_wb_indices_with_disease    <- sample(wb_indices_with_disease, num_to_sample_wb_with)
    sampled_wb_indices_without_disease <- sample(wb_indices_without_disease, num_to_sample_wb_without)

    final_indices_train_val <- c(sa_indices, sampled_wb_indices_with_disease, sampled_wb_indices_without_disease)

    X_train <- X_train[final_indices_train_val, ]
    y_train <- y_train[final_indices_train_val]
    
    print_train_stats(X_train, y_train)
    
    return(list(X_train = X_train, y_train = y_train, X_test = X_test, y_test = y_test))
}

under_sampling <- function(prepared_data) {
    
    X_train = prepared_data$X_train
    X_test  = prepared_data$X_test
    
    y_train = prepared_data$y_train
    y_test  = prepared_data$y_test

    sa_with_disease    <- which(X_train$population == 1 & y_train == 1)
    sa_without_disease <- which(X_train$population == 1 & y_train == 0)
    wb_with_disease    <- which(X_train$population == 0 & y_train == 1)
    wb_without_disease <- which(X_train$population == 0 & y_train == 0)

    num_sa_with    <- length(sa_with_disease)
    num_wb_with    <- length(wb_with_disease)

    # Sample without disease cases to match disease cases
    sampled_sa_without_disease <- sample(sa_without_disease, min(num_sa_with, length(sa_without_disease)))
    sampled_wb_without_disease <- sample(wb_without_disease, min(num_wb_with, length(wb_without_disease)))

    # Combine indices
    final_indices_train_val <- c(sa_with_disease, sampled_sa_without_disease, wb_with_disease, sampled_wb_without_disease)

    X_train <- X_train[final_indices_train_val, ]
    y_train <- y_train[final_indices_train_val]
    
    print_train_stats(X_train, y_train)
    
    return(list(X_train = X_train, y_train = y_train, X_test = X_test, y_test = y_test))
}

skip_sampling <- function(prepared_data) {
    
    X_train = prepared_data$X_train
    X_test  = prepared_data$X_test
    
    y_train = prepared_data$y_train
    y_test  = prepared_data$y_test
    
    print_train_stats(X_train, y_train)
    
    return(list(X_train = X_train, y_train = y_train, X_test = X_test, y_test = y_test))
}

print_train_stats <- function(X_train, y_train) {
    
    combined_df          <- cbind(X_train, data.frame(y_train = y_train))
    
    combined_df$population <- ifelse(combined_df$population == 0, "WB", 
                                     ifelse(combined_df$population == 1, "SA", NA))

    combined_df$combined <- paste(combined_df$population, combined_df$y_train, sep = "-")
    value_counts <- table(combined_df$combined)
    print(value_counts)
    
}
