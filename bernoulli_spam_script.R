PERCENT_TRAINING <- 0.6

spambase <- read.csv(file = "spambase.csv", header = FALSE, sep = ",")
spambase <- as.data.frame(spambase)
names(spambase) <- c(1:58)

spambase <- spambase[sample(nrow(spambase)), ]

bernoulli_spambase <- apply(spambase[1:54], MARGIN = 1:2, FUN = convert_values)
bernoulli_spambase <- cbind(bernoulli_spambase, spambase[ , 58])

num_rows <- as.integer(nrow(bernoulli_spambase))
num_training <- as.integer(PERCENT_TRAINING * num_rows)

training_set <- bernoulli_spambase[1:num_training, ]
test_set <- bernoulli_spambase[(num_training + 1):num_rows, ]

convert_values <- function(x)
{
  if (x > 0.0)
  {
    x = 1
  }
  return(x)
}

get_feature_probabilities <- function(dataset)
{
  # mean_matrix[1, j] = P(x_j = 0 | 0) => P(x_j = 0 | ham)
  # mean_matrix[2, j] = P(x_j = 1 | 0) => P(x_j = 1 | ham)
  # mean_matrix[3, j] = P(x_j = 0 | 1) => P(x_j = 0 | spam)
  # mean_matrix[4, j] = P(x_j = 1 | 1) => P(x_j = 1 | spam)
  
  num_total_rows <- nrow(dataset)
  num_total_cols <- ncol(dataset)
  mean_matrix <- matrix(0, nrow = 4, ncol = 54)
  
  num_spam <- length(which(dataset[, num_total_cols] == 1))
  num_spam <- num_spam + 2                                # Adding 2 to sum_spam as part of Laplace smoothing
  
  num_non_spam <- length(which(dataset[, num_total_cols] == 0))
  num_non_spam <- num_non_spam + 2                        # Adding 2 to sum_non_spam as part of Laplace smoothing
  
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
        # Adding 1 to each sum as part of Laplace smoothing
        sum_ones_given_spam <- sum_ones_given_spam + 1
        sum_zeros_given_spam <- sum_zeros_given_spam + 1
        sum_ones_given_ham <- sum_ones_given_ham + 1
        sum_zeros_given_ham <- sum_zeros_given_ham + 1
        
        ones_given_spam_avg <- sum_ones_given_spam / num_spam
        zeros_given_spam_avg <- sum_zeros_given_spam / num_spam
        ones_given_ham_avg <- sum_ones_given_ham / num_non_spam
        zeros_given_ham_avg <- sum_zeros_given_ham / num_non_spam
        
        mean_matrix[1, j] <- zeros_given_ham_avg
        mean_matrix[2, j] <- ones_given_ham_avg
        mean_matrix[3, j] <- zeros_given_spam_avg
        mean_matrix[4, j] <- ones_given_spam_avg
      }
    }
  }
  return(mean_matrix)
}

naive_bayes <- function(dataset, mean_matrix)
{
  # mean_matrix[1, j] = P(x_j = 0 | 0) => P(x_j = 0 | ham)
  # mean_matrix[2, j] = P(x_j = 1 | 0) => P(x_j = 1 | ham)
  # mean_matrix[3, j] = P(x_j = 0 | 1) => P(x_j = 0 | spam)
  # mean_matrix[4, j] = P(x_j = 1 | 1) => P(x_j = 1 | spam)
  
  # results_matrix[i, 1] = spam prediction for sample i
  # results_matrix[i, 2] = non-spam prediction for sample i
  
  total_rows <- nrow(dataset)
  total_cols <- ncol(dataset)
  results_matrix <- matrix(0, nrow = total_rows, ncol = 2)
  
  spam_prior <- length(which(dataset[, total_cols] == 1))
  spam_prior <- spam_prior / total_rows
  spam_prior <- log10(spam_prior)
  
  ham_prior <- length(which(dataset[, total_cols] == 0))
  ham_prior <- ham_prior / total_rows
  ham_prior <- log10(ham_prior)
  
  mean_matrix <- log10(mean_matrix)
  
  for (i in 1:total_rows)
  {
    spam_prediction = spam_prior
    ham_prediction = ham_prior
    for (j in 1:(total_cols - 1))
    {
      feature <- dataset[i, j]
      if (feature == 1)
      {
        spam_prediction <- spam_prediction + mean_matrix[4, j]
        ham_prediction <- ham_prediction + mean_matrix[2, j]
      }
      else
      {
        spam_prediction <- spam_prediction + mean_matrix[3, j]
        ham_prediction <- ham_prediction + mean_matrix[1, j]
      }
      
      if (j == (total_cols - 1))
      {
        results_matrix[i, 1] <- spam_prediction
        results_matrix[i, 2] <- ham_prediction
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
  print(accuracy)
  return(accuracy)
}

mean_matrix <- get_feature_probabilities(dataset = training_set)
results_matrix <- naive_bayes(dataset = test_set, mean_matrix = mean_matrix)
accuracy <- get_accuracy(confusion_matrix = confusion_matrix)
confusion_matrix <- predict(dataset = test_set, results_matrix = results_matrix)