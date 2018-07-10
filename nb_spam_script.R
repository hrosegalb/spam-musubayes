# Copyright (c) 2018 Hannah Galbraith

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
  
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Read in spambase csv file and separate the resulting data frame into
# spam and non-spam data frames.
# Some code used here has been modified from
# https://stackoverflow.com/questions/26341246/r-subset-of-matrix-based-on-cell-value-of-one-column
spambase <- read.csv(file = "spambase.csv", header = FALSE, sep = ",")
spambase <- as.data.frame(spambase)
spam_df <- spambase[spambase$V58 == 1, ]
non_spam_df <- spambase[spambase$V58 == 0, ]

# Split spam_df and non_spam_df in half
spam_rows <- nrow(spam_df)
non_spam_rows <- nrow(non_spam_df)
spam_1 <- spam_df[1:(spam_rows/2), ]
spam_2 <- spam_df[(spam_rows/2):spam_rows+1, ]
non_spam_1 <- non_spam_df[1:(non_spam_rows/2), ]
non_spam_2 <- non_spam_df[(non_spam_rows/2):non_spam_rows, ]

# Combine the two halves into a training set and test set
training_set <- rbind(spam_1, non_spam_1)
test_set <- rbind(spam_2, non_spam_2)
