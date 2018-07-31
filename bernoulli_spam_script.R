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
  # conditional_probabilities[1, j] = P(x = 0 | 0)
  # conditional_probabilities[2, j] = P(x = 1 | 0)
  # conditional_probabilities[3, j] = P(x = 0 | 1)
  # conditional_probabilities[4, j] = P(x = 1 | 1)
  
  
}
