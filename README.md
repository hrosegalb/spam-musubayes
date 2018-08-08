# spam-musubayes by Hannah Galbraith (hrg@pdx.edu)
A program that classifies spam versus non-spam emails in the Spambase data set using different versions of Naïve Bayes. `nb_spam_script` uses Gaussian Naïve Bayes to predict whether an email sample in the Spambase data set (https://archive.ics.uci.edu/ml/datasets/spambase) is spam or not. `bernoulli_spam_script` also predicts whether an email sample in the Spambase data set is spam or not, but uses Multivariate Bernoulli Naive Bayes as opposed to Gaussian by using a subset of the features in the data set and converting the features' real number values to '1's and '0's: '1's indicate that the word is present while '0's indicate the absence of that word in the sample.

# Spambase Data Set Background Information
The Spambase data set was created by Mark Hopkins, Erik Reeber, George Forman, and Jaap Suermondt at Hewlett-Packard Labs. Hopkins et al. used a collection of spam e-mails came from the researchers' postmaster and individuals who had filed spam. Their collection of non-spam e-mails came from filed work and personal e-mails, and hence the word 'george' and the area code '650' are indicators of non-spam. There are 4601 labeled samples. Roughly 60% of the samples correspond to non-spam emails and 40% correspond to spam. Each sample has 57 features. The breakdown of the features is listed below:

The first 48 features are continuous real attributes of type `word_freq_WORD`, i.e. the percentage of words in the e-mail that match a given word. 

Features 49 through 54 are continuous real attributes of type `char_freq_CHAR`, i.e. the percentage of characters in the e-mail that match a given character. 

Feature 55 is a continuous real attribute of type `capital_run_length_average`, i.e. the average length of uninterrupted sequences of capital letters. 

Feature 56 is a continuous integer attribute of type `capital_run_length_longest`, i.e. the length of the longest uninterrupted sequence of capital letters. 

Feature 57 is a continuous integer attribute of type `capital_run_length_total`, i.e. the total number of capital letters in the e-mail. 

The 58th column in the dataset stores a nominal {0,1} class attribute of type `spam`. The sample is given a '1' if the email was considered spam and a '0' if it was not.

To see the specific words and and characters the researchers used, visit https://archive.ics.uci.edu/ml/machine-learning-databases/spambase/spambase.names.

# Program Info
There are two models a user can choose from for prediction: a Gaussian Naïve Bayes model or a Multivariate Bernoulli Naïve Bayes model. The Gaussian model uses the entire dataset and assumes the values associated with each class are distributed according to the Gaussian, or Normal, Distribution. The program uses K-fold cross-validation (with a default of K=10 folds) to split the data set into training and test sets. Using the training set, the program segments the data by class and then gets the means and standard deviations of each feature for both classes. Then, on the test set, it predicts the probability P(x<sub>i</sub> | 0) and P(x<sub>i</sub> | 1) for each feature of each sample by using the Gaussian equation, with each feature's respective mean and standard deviation for the given class substituted in for mu and sigma. To predict whether a sample is spam or not, it adds the logs of each of the sample's features' conditional probabilities to the log of the prior for both classes. The model predicts whichever class corresponds to the larger value of the two. The program prints out a confusion matrix for each fold as well as the accuracy percentage of each prediction. It then prints the average accuracy percentage across all folds, as well as the max accuracy, min accuracy, and standard deviation.

# License
Copyright 2018 Hannah Galbraith

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Setup
* Make sure you have R version 3.5.0 (2018-04-23) ("Joy in Playing") or higher installed: https://www.r-project.org/
* Though not strictly necessary to run the program, if you'd like to use RStudio, make sure you have RStudio Desktop Version 1.1 or higher installed: https://www.rstudio.com/products/rstudio/download/#download


