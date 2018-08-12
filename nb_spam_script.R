# Copyright (c) 2018 Hannah Galbraith

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
  
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



mean_standard_dev <- function(dataset)
{
  # Calculate mean and standard deviation of each feature in the training
  # dataset. Store the results in a matrix.
  # mean_sd_matrix[i][1] = mean for that feature given that it's spam
  # mean_sd_matrix[i][2] = mean for that feature given that it's not spam
  # mean_sd_matrix[i][3] = standard deviation for that feature given that it's spam
  # mean_sd_matrix[i][4] = standard deviation for that feature given that it's not spam
  
  # Create an empty matrix to put feature means/standard deviations in
  num_col <- ncol(dataset)
  mean_sd_matrix <- matrix(0, nrow = (num_col - 1), ncol = 4)
  
  # Loop through each column of the dataset and calculate the mean and
  # standard deviations of each feature given that it's spam/not spam.
  # Place the results in the corresponding columns of 'mean_sd_matrix'.
  # Used https://stackoverflow.com/questions/1660124/how-to-sum-a-variable-by-group#1661144
  # as a reference.
  i <- 1:(num_col-1)
  means <- aggregate(dataset[, i], by=list(dataset[, num_col]), FUN=mean)
  means <- as.matrix(means)
  standard_devs <- aggregate(dataset[, i], by=list(dataset[, num_col]), FUN=sd)
  standard_devs <- as.matrix(standard_devs)
  
  mean_sd_matrix[, 1] <- means[2, (2:num_col)]
  mean_sd_matrix[, 2] <- means[1, (2:num_col)]
  mean_sd_matrix[, 3] <- standard_devs[2, (2:num_col)]
  mean_sd_matrix[, 4] <- standard_devs[1, (2:num_col)]
  
  # So as to not mess up future calculations, if there are any features
  # with 0.0 for their means and/or standard deviations, replace those values
  # with 0.0001.
  # Used https://stackoverflow.com/questions/9439619/replace-all-values-in-a-matrix-0-1-with-0
  # as a reference.
  mean_sd_matrix[mean_sd_matrix == 0.0] <- 0.0001
  return(mean_sd_matrix)
}

get_class_predictions <- function(dataset, mean_sd_matrix)
{
  # Creates a matrix of probabilities where each row represents a data sample.
  # Each column represents:
  # probability_matrix[i, 1] = probability of that data sample being spam
  # probability_matrix[i, 2] = probability of that data sample not being spam
  
  num_samples <- nrow(dataset)
  num_cols <- ncol(dataset)
  
  # Stores the results of the PDF on each feature for each sample, given that the sample is spam/not spam
  conditional_spam <- matrix(0, nrow = num_samples, ncol = (num_cols - 1))
  conditional_non_spam <- matrix(0, nrow = num_samples, ncol = (num_cols - 1))
  
  probability_matrix <- matrix(0, nrow = num_samples, ncol = 2)
  
  # Calculate the probability density function (PDF) for each feature of each sample in dataset.
  for (i in 1:num_samples)
  {
    for (j in 1:(num_cols - 1))
    {
      feature <- dataset[i, j]
      spam_mu <- mean_sd_matrix[j, 1]
      non_spam_mu <- mean_sd_matrix[j, 2]
      spam_sigma <- mean_sd_matrix[j, 3]
      non_spam_sigma <- mean_sd_matrix[j, 4]
      
      conditional_spam[i,j] <- (1/(sqrt(2*pi)*spam_sigma)) * exp(-(((feature - spam_mu)^2)/(2 * spam_sigma^2)))
      conditional_non_spam[i,j] <- (1/(sqrt(2*pi)*non_spam_sigma)) * exp(-(((feature - non_spam_mu)^2)/(2 * non_spam_sigma^2)))
    }
  }
  
  
  # Convert every PDF result to its log in order to add the values of each feature rather than multiply.
  # This will help avoid buffer overflow.
  conditional_spam <- log10(conditional_spam)
  conditional_non_spam <- log10(conditional_non_spam)
  
  
  # Sum the PDF results for each sample and store sum in probability_matrix
  probability_matrix[, 1] <- rowSums(conditional_non_spam)
  probability_matrix[, 2] <- rowSums(conditional_spam)
  probability_matrix[probability_matrix == '-Inf'] <- log10(.Machine$double.xmin) # Corrects buffer overflow
  
  
  # Calculate the spam & non-spam priors
  num_spam <- length(which(dataset[, num_cols] == 1))
  num_non_spam <- length(which(dataset[, num_cols] == 0))
  spam_prior <- num_spam / num_samples
  non_spam_prior <- num_non_spam / num_samples
  
  
  # Take the log of the spam & non-spam priors and add it to their corresponding log sums
  probability_matrix[, 1] <- probability_matrix[, 1] + log10(spam_prior)
  probability_matrix[, 2] <- probability_matrix[, 2] + log10(non_spam_prior)
  return(probability_matrix)
}

predict <- function(dataset, probability_matrix)
{
  # Takes a matrix of spam/non-spam probabilities of each data sample and the test dataset and 
  # compares the prediction of each data sample in the probability_matrix with the target 
  # in the test data. It then creates a confusion matrix where:
  # confusion_matrix[1][1] = Actual is non-spam and Prediction is non-spam (TN)
  # confusion_matrix[1][2] = Actual is non-spam and Prediction is spam (FP)
  # confusion_matrix[2][1] = Actual is spam and Prediction is non-spam (FN)
  # confusion_matrix[2][2] = Actual is spam and Prediction is spam (TP)
  
  confusion_matrix <- matrix(0, nrow = 2, ncol = 2)
  num_samples <- nrow(probability_matrix)
  max_col <- ncol(dataset)
  
  for (i in 1:num_samples)
  {
    predicted_class <- which.max(probability_matrix[i, ])
    actual_class <- dataset[i, max_col] + 1
    confusion_matrix[actual_class, predicted_class] <- confusion_matrix[actual_class, predicted_class] + 1
  }
  
  print(confusion_matrix)
  print("***************")
  return(confusion_matrix)
}

get_accuracy <- function(confusion_matrix)
{
  # Returns the accuracy percentage of a confusion matrix: 
  # (TP+TN) / (TP+FP+FN+TN) * 100
  
  accuracy <- sum(diag(confusion_matrix))
  accuracy <- accuracy / sum(confusion_matrix)
  accuracy <- accuracy * 100

  return(accuracy)
}



NUM_FOLDS <- 10

set.seed(1)       # Set a seed so that results are reproducible

spambase <- read.csv(file = "spambase.csv", header = FALSE, sep = ",")
spambase <- as.data.frame(spambase)
names(spambase) <- c(1:58)

spambase <- spambase[sample(nrow(spambase)), ]  # Shuffle dataset

# Perform K-fold cross-validation on dataset
folds <- list()

folds <- split(spambase, sample(1:NUM_FOLDS, nrow(spambase), replace = T))
accuracy_list <- list()

print("Confusion Matrices for each fold:")
print("TN   |   FP")
print("-----|-----")
print("FN   |   TP")
for (i in 1:NUM_FOLDS)
{
  test_set <- folds[[i]]
  training_set <- matrix(, nrow = 0, ncol = 58)
  for (j in 1:NUM_FOLDS)
  {
    if (j != i)
    {
      training_set <- rbind(training_set, folds[[j]])
    }
  }
  mean_sd_matrix <- mean_standard_dev(dataset=training_set)
  probability_matrix <- get_class_predictions(dataset = test_set, mean_sd_matrix = mean_sd_matrix)
  confusion_matrix <- predict(dataset = test_set, probability_matrix = probability_matrix)
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

