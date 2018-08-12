# Copyright (c) 2018 Hannah Galbraith

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Calculate mean and standard deviation of each feature in the training
# dataset. Store the results in a matrix.


convert_values <- function(x, num)
{
  threshold <- 4.1    # This number was obtained after experimenting with an extensive range of thresholds.
                      # As of 8/11/18, 4.1 is the threshold which allows the model to obtain the highest 
                      # average percentage of accuracy (~36%) without uniformly predicting 'spam' for each sample.
  
  # Function converts real number value to a 1.
  if (x >= threshold)
  {
    x = 1
  }
  else
  {
    x = 0
  }
  return(x)
}

get_conditional_probabilities <- function(dataset)
{
  # Calculates conditional probability for each feature in the training dataset and stores results in mean_matrix.
  # mean_matrix[1, j] = P(x_j = 0 | 0) => "Probability that the feature equals 0, given that the outcome is ham"
  # mean_matrix[2, j] = P(x_j = 1 | 0) => "Probability that the feature equals 1, given that the outcome is ham"
  # mean_matrix[3, j] = P(x_j = 0 | 1) => "Probability that the feature equals 0, given that the outcome is spam"
  # mean_matrix[4, j] = P(x_j = 1 | 1) => "Probability that the feature equals 1, given that the outcome is spam"
  
  num_total_rows <- nrow(dataset)
  num_total_cols <- ncol(dataset)
  mean_matrix <- matrix(0, nrow = 4, ncol = (num_total_cols - 1))
  
  # Get total number of spam samples and total number of non-spam samples
  num_spam <- length(which(dataset[, num_total_cols] == 1))
  num_spam <- num_spam + 2                                # Adding 2 to sum_spam as part of Laplace smoothing
  
  num_non_spam <- length(which(dataset[, num_total_cols] == 0))
  num_non_spam <- num_non_spam + 2                        # Adding 2 to sum_non_spam as part of Laplace smoothing
  
  # Get conditional probabilities for each feature
  for (j in 1:(num_total_cols - 1))
  {
    sum_ones_given_ham <- 0
    sum_zeros_given_ham <- 0
    sum_ones_given_spam <- 0
    sum_zeros_given_spam <- 0
    for (i in 1:num_total_rows)
    {
      feature <- dataset[i, j]
      if (dataset[i, num_total_cols] == 1)
      {
        if (feature == 1)
        {
          sum_ones_given_spam <- sum_ones_given_spam + 1
        }
        else
        {
          sum_zeros_given_spam <- sum_zeros_given_spam + 1
        }
      }
      else
      {
        if (feature == 1)
        {
          sum_ones_given_ham <- sum_ones_given_ham + 1
        }
        else
        {
          sum_zeros_given_ham <- sum_zeros_given_ham + 1
        }
      }
      
      if (i == num_total_rows)
      {
        # Add 1 to each sum as part of Laplace smoothing
        sum_ones_given_spam <- sum_ones_given_spam + 1
        sum_zeros_given_spam <- sum_zeros_given_spam + 1
        sum_ones_given_ham <- sum_ones_given_ham + 1
        sum_zeros_given_ham <- sum_zeros_given_ham + 1
        
        # Get the conditional probabilities
        ones_given_spam_avg <- sum_ones_given_spam / num_spam
        zeros_given_spam_avg <- sum_zeros_given_spam / num_spam
        ones_given_ham_avg <- sum_ones_given_ham / num_non_spam
        zeros_given_ham_avg <- sum_zeros_given_ham / num_non_spam
        
        # Store conditional probabilities for this feature in mean_matrix
        mean_matrix[1, j] <- zeros_given_ham_avg
        mean_matrix[2, j] <- ones_given_ham_avg
        mean_matrix[3, j] <- zeros_given_spam_avg
        mean_matrix[4, j] <- ones_given_spam_avg
      }
    }
  }
  return(mean_matrix)
}

get_class_predictions <- function(dataset, mean_matrix)
{
  # Creates a matrix of probabilities where each row represents a data sample.
  # Each column represents:
  # results_matrix[i, 1] = probability of that data sample being spam
  # results_matrix[i, 2] = probability of that data sample not being spam
  
  total_rows <- nrow(dataset)
  total_cols <- ncol(dataset)
  results_matrix <- matrix(0, nrow = total_rows, ncol = 2)
  
  # Calculate spam & non-spam priors and then take the log of the values
  spam_prior <- length(which(dataset[, total_cols] == 1))
  spam_prior <- spam_prior / total_rows
  spam_prior <- log10(spam_prior)
  
  ham_prior <- length(which(dataset[, total_cols] == 0))
  ham_prior <- ham_prior / total_rows
  ham_prior <- log10(ham_prior)
  
  # Take the logs of all conditional probabilities in order to add the values of each feature rather than multiply.
  # This will help avoid buffer overflow. 
  mean_matrix <- log10(mean_matrix)
  
  # Calculate the probability of each sample being spam or not and store the probabalities in results_matrix
  for (i in 1:total_rows)
  {
    spam_probability = spam_prior
    ham_probability = ham_prior
    for (j in 1:(total_cols - 1))
    {
      feature <- dataset[i, j]
      if (feature == 1)
      {
        spam_probability <- spam_probability + mean_matrix[4, j]
        ham_probability <- ham_probability + mean_matrix[2, j]
      }
      else
      {
        spam_probability <- spam_probability + mean_matrix[3, j]
        ham_probability <- ham_probability + mean_matrix[1, j]
      }
      
      if (j == (total_cols - 1))
      {
        results_matrix[i, 1] <- spam_probability
        results_matrix[i, 2] <- ham_probability
      }
    }
  }
  return(results_matrix)
}

predict <- function(dataset, results_matrix)
{
  # Takes a matrix of spam/non-spam probabilities of each data sample and the test dataset and 
  # compares the prediction of each data sample in the probability_matrix with the target 
  # in the test data. It then creates a confusion matrix where:
  # confusion_matrix[1][1] = Actual is non-spam and Prediction is non-spam (TN)
  # confusion_matrix[1][2] = Actual is non-spam and Prediction is spam (FP)
  # confusion_matrix[2][1] = Actual is spam and Prediction is non-spam (FN)
  # confusion_matrix[2][2] = Actual is spam and Prediction is spam (TP)
  
  confusion_matrix <- matrix(0, nrow = 2, ncol = 2)
  num_samples <- nrow(results_matrix)
  num_col <- ncol(dataset)
  
  for (i in 1:num_samples)
  {
    predicted_class <- which.max(results_matrix[i, ])
    actual_class <- dataset[i, num_col] + 1
    confusion_matrix[actual_class, predicted_class] <- confusion_matrix[actual_class, predicted_class] + 1
  }
  
  return(confusion_matrix)
}

get_accuracy <- function(confusion_matrix)
{
  # Returns the accuracy percentage of a confusion matrix: 
  # (TP+TN) / (TP+FP+FN+TN) * 100
  
  accuracy <- sum(diag(confusion_matrix))
  accuracy <- accuracy / sum(confusion_matrix)
  accuracy <- accuracy * 100
  
  print(confusion_matrix)
  print("***************")
  return(accuracy)
}

run_program <- function(num)
{
  NUM_FOLDS <- 10
  
  set.seed(1)     # Set a seed so that results are reproducible
  
  spambase <- read.csv(file = "spambase.csv", header = FALSE, sep = ",")
  spambase <- as.data.frame(spambase)
  names(spambase) <- c(1:58)
  
  spambase <- spambase[sample(nrow(spambase)), ]    # Shuffle dataset
  
  # Remove rows 55-57 (which don't calculate frequency of a word in an email)
  # and convert the remaining values from real numbers to 1s and 0s
  bernoulli_spambase <- apply(spambase[1:54], MARGIN = 1:2, FUN = convert_values, num=num)
  bernoulli_spambase <- cbind(bernoulli_spambase, spambase[ , 58]) 
  bernoulli_spambase <- as.data.frame(bernoulli_spambase)
  
  # Perform K-fold cross-validation on dataset
  folds <- list()
  
  folds <- split(bernoulli_spambase, sample(1:NUM_FOLDS, nrow(bernoulli_spambase), replace = T))
  accuracy_list <- list()
  
  print("Confusion Matrices for each fold:")
  print("TN   |   FP")
  print("-----|-----")
  print("FN   |   TP")
  
  for (i in 1:NUM_FOLDS)
  {

    
    test_set <- folds[[i]]
    training_set <- matrix(, nrow = 0, ncol = 55)
    for (j in 1:NUM_FOLDS)
    {
      if (j != i)
      {
        training_set <- rbind(training_set, folds[[j]])
      }
    }
    mean_matrix <- get_conditional_probabilities(dataset = training_set)
    results_matrix <- get_class_predictions(dataset = test_set, mean_matrix = mean_matrix)
    confusion_matrix <- predict(dataset = test_set, results_matrix = results_matrix)
    accuracy <- get_accuracy(confusion_matrix = confusion_matrix)
    accuracy_list[[i]] <- accuracy
  }
  
  print("Accuracy of each fold (%):")
  print(accuracy_list)
  print("Average Accuracy (%):")
  print(mean(unlist(accuracy_list)))
  print("Max Accuracy (%):")
  print(max(unlist(accuracy_list)))
  print("Min Accuracy (%):")
  print(min(unlist(accuracy_list)))
  print("Standard Deviation:")
  print(sd(unlist(accuracy_list)))
}



thresholds <- c(3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 4.1, 4.2, 4.3, 4.4)
len <- length(thresholds)
for (i in 1:len)
{
  print("Threshold:")
  print(thresholds[[i]])
  run_program(thresholds[[i]])
}
