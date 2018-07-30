PERCENT_TRAINING <- 0.6

spambase <- read.csv(file = "spambase.csv", header = FALSE, sep = ",")
spambase <- as.data.frame(spambase)
names(spambase) <- c(1:58)

spambase <- spambase[sample(nrow(spambase)), ]

bernoulli_spambase <- apply(spambase[1:54], MARGIN = 1:2, FUN = convert_values)
bernoulli_spambase <- cbind(bernoulli_spambase, spambase[ , 58])

convert_values <- function(x)
{
  if (x > 0.0)
  {
    x = 1
  }
  return(x)
}
