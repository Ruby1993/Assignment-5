## BA - Text as Data  
### Author: JC Bonilla
### jb3379@nyu.edu

library(quanteda)
library(stm)
library(tm)
library(NLP)
library(openNLP)
library(ggplot2)
library(ggdendro)
library(cluster)
library(fpc)  

#require(quanteda)
#using Corpus from quanteda - US President inaugural speeches
#summary(inaugCorpus)

precorpus<- read.csv("~/Desktop/business analysis/homework/5_text/speech.csv",header=FALSE,stringsAsFactors=FALSE)
precorpus$V2
dim(precorpus) # dim of file; 107 files with 11 headers
names(precorpus)   # names of the headers
head(precorpus)
str(precorpus)

#create a corpus with metadata
require(quanteda)
help(corpus)
newscorpus<- corpus(precorpus$V2,
                      docnames=precorpus$V1)
#explore the corpus
names(newscorpus)   #to explore the output of the corpus function: "documents" "metadata"  "settings"  "tokens" 
summary(newscorpus)  #summary of corpus
head(newscorpus)

#Generate DFM
#corpus<- toLower(inaugCorpus, keepAcronyms = FALSE) 
cleancorpus <- tokenize(newscorpus, 
                        removeNumbers=TRUE,  
                        removePunct = TRUE,
                        removeSeparators=TRUE,
                        removeTwitter=FALSE,
                        verbose=TRUE)
cleancorpus

dfm<- dfm(cleancorpus,
          toLower = TRUE, 
          ignoredFeatures =c("s","t","ve", stopwords("english")), 
          verbose=TRUE, 
          stem=TRUE)
# Reviewing top features
topfeatures(dfm, 100)    # displays 100 features

#Sentiment Analysis
help(dfm)
positive_wordlist<- read.csv("~/Desktop/business analysis/homework/5_text/positive_wordlist.csv",header=FALSE,stringsAsFactors=FALSE)
positive_wordlist
negaive_wordlist<- read.csv("~/Desktop/business analysis/homework/5_text/negative_wordlist.csv",header=FALSE,stringsAsFactors=FALSE)
negaive_wordlist

mydict <- dictionary(list(negative = c(negaive_wordlist),
                          postive = c(positive_wordlist)))
dfm.sentiment <- dfm(cleancorpus, dictionary = mydict)
topfeatures(dfm.sentiment)
View(dfm.sentiment)

#########################
### WORD CLOUD ########
#########################

library(wordcloud)
set.seed(142)   #keeps cloud' shape fixed
dark2 <- brewer.pal(8, "Set1")   
freq<-topfeatures(dfm, n=500)

help("wordcloud")
wordcloud(names(freq), 
          freq, max.words=200, 
          scale=c(3, .1), 
          colors=brewer.pal(8, "Set1"))

#specifying a correlation limit of 0.5   
dfm.tm<-convert(dfm.stem, to="tm")
findAssocs(dfm.tm, 
           c("data", "tech", "big"), 
           corlimit=0.6)
findAssocs(dfm.tm, 
           c("public","model", "create" ), 
           corlimit=0.7)

##########################
### Topic Modeling
##########################

library(stm)

#Process the data for analysis.
help("textProcessor")
temp<-textProcessor(documents=precorpus$V2, metadata = precorpus)
names(temp)  # produces:  "documents", "vocab", "meta", "docs.removed" 
meta<-temp$meta
vocab<-temp$vocab
docs<-temp$documents
out <- prepDocuments(docs, vocab, meta)
docs<-out$documents
vocab<-out$vocab
meta <-out$meta
#running stm for top 4 topics as there are only 4 speeches in the dataframe
help("stm")
prevfit <-stm(docs , vocab , 
              K=20, 
              verbose=TRUE,
              data=meta, 
              max.em.its=25)

topics <-labelTopics(prevfit , topics=c(1:4))
topics   #shows topics with highest probability words

#explore the topics in context.  Provides an example of the text 
help("findThoughts")
findThoughts(prevfit, texts = precorpus$V2,  topics = 4,  n = 2)

help("plot.STM")
plot.STM(prevfit, type="summary")
plot.STM(prevfit, type="labels", topics=c(1,2,3,4))
plot.STM(prevfit, type="perspectives", topics = c(3,4))

# to aid on assigment of labels & intepretation of topics
help(topicCorr)
mod.out.corr <- topicCorr(prevfit)  #Estimates a graph of topic correlations
plot.topicCorr(mod.out.corr)

#####################
# Hierc. Clustering 
#####################
dfm.tm<-convert(dfm, to="tm")
dfm.tm
dtmss <- removeSparseTerms(dfm.tm, 0.15)
dtmss
d.dfm <- dist(t(dtmss), method="euclidian")
fit <- hclust(d=d.dfm, method="average")
hcd <- as.dendrogram(fit)

require(cluster)
k<-5
plot(hcd, ylab = "Distance", horiz = FALSE, 
     main = "Five Cluster Dendrogram", 
     edgePar = list(col = 2:3, lwd = 2:2))
rect.hclust(fit, k=k, border=1:5) # draw dendogram with red borders around the 5 clusters

ggdendrogram(fit, rotate = TRUE, size = 4, theme_dendro = FALSE,  color = "blue") +
  xlab("Features") + 
  ggtitle("Cluster Dendrogram")

require(fpc)   
d <- dist(t(dtmss), method="euclidian")   
kfit <- kmeans(d, 5)   
clusplot(as.matrix(d), kfit$cluster, color=T, shade=T, labels=2, lines=0)


#######################################
### Advanced method for Topic Modeling
#######################################


library(dplyr)
require(magrittr)
library(tm)
library(ggplot2)
library(stringr)
library(NLP)
library(openNLP)

#load .csv file with news articles
#url<-"https://raw.githubusercontent.com/jcbonilla/BusinessAnalytics/master/Week-08_and_09/NewsText.csv"
#precorpus<- read.csv(url, 
                    # header=TRUE, stringsAsFactors=FALSE)

#passing Full Text to variable news_2015
news_2015<-precorpus$V2

news_2015
#Cleaning corpus
stop_words <- stopwords("SMART")
## additional junk words showing up in the data
stop_words <- c(stop_words, "said", "the", "also", "say", "just", "like","for", 
                "us", "can", "may", "now", "year", "according", "mr")
stop_words <- tolower(stop_words)


news_2015 <- gsub("'", "", news_2015) # remove apostrophes
news_2015 <- gsub("[[:punct:]]", " ", news_2015)  # replace punctuation with space
news_2015 <- gsub("[[:cntrl:]]", " ", news_2015)  # replace control characters with space
news_2015 <- gsub("^[[:space:]]+", "", news_2015) # remove whitespace at beginning of documents
news_2015 <- gsub("[[:space:]]+$", "", news_2015) # remove whitespace at end of documents
news_2015 <- gsub("[^a-zA-Z -]", " ", news_2015) # allows only letters
news_2015 <- tolower(news_2015)  # force to lowercase

## get rid of blank docs
news_2015 <- news_2015[news_2015 != ""]

# tokenize on space and output as a list:
doc.list <- strsplit(news_2015, "[[:space:]]+")

# compute the table of terms:
term.table <- table(unlist(doc.list))
term.table <- sort(term.table, decreasing = TRUE)


# remove terms that are stop words or occur fewer than 5 times:
del <- names(term.table) %in% stop_words | term.table < 5
term.table <- term.table[!del]
term.table <- term.table[names(term.table) != ""]
vocab <- names(term.table)

# now put the documents into the format required by the lda package:
get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents <- lapply(doc.list, get.terms)

#############
# Compute some statistics related to the data set:
D <- length(documents)  # number of documents (1)
W <- length(vocab)  # number of terms in the vocab (1741)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document [312, 288, 170, 436, 291, ...]
N <- sum(doc.length)  # total number of tokens in the data (56196)
term.frequency <- as.integer(term.table) 

# MCMC and model tuning parameters:
K <- 4
G <- 3000
alpha <- 0.02
eta <- 0.02

# Fit the model:
library(lda)
set.seed(357)
t1 <- Sys.time()
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
## display runtime
t2 - t1  

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

news_for_LDA <- list(phi = phi,
                     theta = theta,
                     doc.length = doc.length,
                     vocab = vocab,
                     term.frequency = term.frequency)

library(LDAvis)
library(servr)

# create the JSON object to feed the visualization:
json <- createJSON(phi = news_for_LDA$phi, 
                   theta = news_for_LDA$theta, 
                   doc.length = news_for_LDA$doc.length, 
                   vocab = news_for_LDA$vocab, 
                   term.frequency = news_for_LDA$term.frequency)

serVis(json, out.dir = 'vis', open.browser = TRUE)

