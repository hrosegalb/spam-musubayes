# spam-musubayes by Hannah Galbraith (hrg@pdx.edu)
A program that classifies spam versus non-spam emails in the Spambase data set using different versions of Naïve Bayes. `nb_spam_script` uses Gaussian Naïve Bayes to predict whether an email sample in the Spambase data set (https://archive.ics.uci.edu/ml/datasets/spambase) is spam or not. `bernoulli_spam_script` also predicts whether an email sample in the Spambase data set is spam or not, but uses Multivariate Bernoulli Naive Bayes as opposed to Gaussian by truncating the data set and converting the real number values to '1's and '0's: '1's indicate that the word is present while '0's indicate the absence of that word in the sample.

# Spambase Data Set Background Information
The Spambase data set was created by Mark Hopkins, Erik Reeber, George Forman, and Jaap Suermondt at Hewlett-Packard Labs. Hopkins et al. used a collection of spam e-mails came from the researchers' postmaster and individuals who had filed spam. Their collection of non-spam e-mails came from filed work and personal e-mails, and hence the word 'george' and the area code '650' are indicators of non-spam. There are 4601 labeled samples with 57 features. 

The first 48 features are continuous real attributes of type `word_freq_WORD`, i.e. the percentage of words in the e-mail that match a given word. 

Features 49 through 54 are 6 continuous real attributes of type `char_freq_CHAR`, i.e. the percentage of characters in the e-mail that match a given character. 

Feature 55 is a continuous real attribute of type `capital_run_length_average`, i.e. the average length of uninterrupted sequences of capital letters. 

Feature 56 is a continuous integer attribute of type `capital_run_length_longest`, i.e. the length of the longest uninterrupted sequence of capital letters. 

Feature 57 is a continuous integer attribute of type `capital_run_length_total`, i.e. the total number of capital letters in the e-mail. 

The 58th column in the dataset is stores a nominal {0,1} class attribute of type `spam`. The sample is given a '1' if the email was considered spam and a '0' if it was not.

To see the specific words and and characters the researchers used, visit https://archive.ics.uci.edu/ml/machine-learning-databases/spambase/spambase.names.

# License
Copyright 2018 Hannah Galbraith

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Setup
* Make sure you have R version 3.5.0 (2018-04-23) ("Joy in Playing") or higher installed: https://www.r-project.org/
* Though not strictly necessary to run the program, if you'd like to use RStudio, make sure you have RStudio Desktop Version 1.1 or higher installed: https://www.rstudio.com/products/rstudio/download/#download


