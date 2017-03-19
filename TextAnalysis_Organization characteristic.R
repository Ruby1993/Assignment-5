library(quanteda)
library(stm)
library(tm)
library(NLP)
library(openNLP)

#load .csv file with news articles

# read the mission statement  must have the string as factor
precorpus_1<- read.csv("~/Desktop/business analysis/homework/5_text/company_mission.csv",header=FALSE,stringsAsFactors=FALSE)
#precorpus_1
dim(precorpus_1) # dim of file; 107 files with 11 headers
names(precorpus_1)   # names of the headers
head(precorpus_1)
str(precorpus_1)

#read the core value
precorpus_2<- read.csv("~/Desktop/business analysis/homework/5_text/company_corevalue.csv",header=FALSE,stringsAsFactors=FALSE)
dim(precorpus_2) # dim of file; 107 files with 11 headers
names(precorpus_2)   # names of the headers
head(precorpus_2)
str(precorpus_2)

##########################
### Preprocessing
##########################

#create a corpus with metadata
require(quanteda)
help(corpus)
newscorpus_1<- corpus(precorpus_1$V2,
                    docnames=precorpus_1$V1)
#explore the corpus
names(newscorpus_1)   #to explore the output of the corpus function: "documents" "metadata"  "settings"  "tokens" 
summary(newscorpus_1)  #summary of corpus
head(newscorpus_1)

#create a corpus with metadata
require(quanteda)
help(corpus)
newscorpus_2<- corpus(precorpus_2$V2,
                    docnames=precorpus_2$V1)
#explore the corpus
names(newscorpus_2)   #to explore the output of the corpus function: "documents" "metadata"  "settings"  "tokens" 
summary(newscorpus_2)  #summary of corpus
head(newscorpus_2)

######### clean corpus #############

#clean corpus_1: removes punctuation, digits, converts to lower case
help(tokenize)
newscorpus_1<- toLower(newscorpus_1, keepAcronyms = FALSE) 
#seperate sentence
cleancorpus_1 <- tokenize(newscorpus_1, 
                        removeNumbers=TRUE,  
                        removePunct = TRUE,
                        removeSeparators=TRUE,
                        removeTwitter=FALSE,
                        verbose=TRUE)

head(cleancorpus_1)
#create document feature matrix from clean corpus + stem
help(dfm)
dfm.simple_1<- dfm(cleancorpus_1,
                   toLower = TRUE, 
                   ignoredFeatures =stopwords("english"), 
                   verbose=TRUE, 
                   stem=FALSE)
head(dfm.simple_1) #explore output of dfm

#clean corpus_2: removes punctuation, digits, converts to lower case
newscorpus_2<- toLower(newscorpus_2, keepAcronyms = FALSE) 
#seperate sentence
cleancorpus_2 <- tokenize(newscorpus_2, 
                          removeNumbers=TRUE,  
                          removePunct = TRUE,
                          removeSeparators=TRUE,
                          removeTwitter=FALSE,
                          verbose=TRUE)

head(cleancorpus_2)  
#create document feature matrix from clean corpus + stem
dfm.simple_2<- dfm(cleancorpus_2,
                   toLower = TRUE, 
                   ignoredFeatures =stopwords("english"), 
                   verbose=TRUE, 
                   stem=FALSE)
head(dfm.simple_2) #explore output of dfm

############## display the most frequent terms in dfm  ###############

topfeatures_1<-topfeatures(dfm.simple_1, n=50)
topfeatures_1

topfeatures_2<-topfeatures(dfm.simple_2, n=50)
topfeatures_2

############# add more stop words based on the output  ##########
#to create a custom dictionary  list of stop words
# stem could help u to find all similar words in shape
swlist = c("data","big","analytics")
dfm.stem_1<- dfm(cleancorpus_1, toLower = TRUE, 
               ignoredFeatures = c(swlist, stopwords("english")),
               verbose=TRUE, 
               stem=FALSE)
topfeatures.stem_1<-topfeatures(dfm.stem_1, n=50)
topfeatures.stem_1

dfm.stem_2<- dfm(cleancorpus_2, toLower = TRUE, 
                 ignoredFeatures = c(swlist, stopwords("english")),
                 verbose=TRUE, 
                 stem=FALSE)
topfeatures.stem_2<-topfeatures(dfm.stem_2, n=50)
topfeatures.stem_2

#exploration in context  get the searched word in the sentence
kwic(cleancorpus_1, "people", 2)
kwic(cleancorpus_1, "world", window = 3)
kwic(cleancorpus_2, "people", 2)
kwic(cleancorpus_2, "world", window = 3)

#dfm with bigrams
help("tokenize")
######################## two words searched frequency##################################
cleancorpus_1 <- tokenize(newscorpus_1, 
                        removeNumbers=TRUE,  
                        removePunct = TRUE,
                        removeSeparators=TRUE,
                        removeTwitter=FALSE, 
                        ngrams=2, verbose=TRUE)
dfm.bigram_1<- dfm(cleancorpus_1, toLower = TRUE, 
                 ignoredFeatures = c(swlist, stopwords("english")),
                 verbose=TRUE, 
                 stem=FALSE)
topfeatures.bigram_1<-topfeatures(dfm.bigram_1, n=50)
topfeatures.bigram_1

cleancorpus_2 <- tokenize(newscorpus_2, 
                          removeNumbers=TRUE,  
                          removePunct = TRUE,
                          removeSeparators=TRUE,
                          removeTwitter=FALSE, 
                          ngrams=2, verbose=TRUE)


dfm.bigram_2<- dfm(cleancorpus_2, toLower = TRUE, 
                   ignoredFeatures = c(swlist, stopwords("english")),
                   verbose=TRUE, 
                   stem=FALSE)
topfeatures.bigram_2<-topfeatures(dfm.bigram_2, n=50)
topfeatures.bigram_2


#########################
### WORD CLOUD ########
#########################


library(wordcloud)
set.seed(142)   #keeps cloud' shape fixed
dark2 <- brewer.pal(8, "Set1")   
freq<-topfeatures(dfm.stem_1, n=500)

help("wordcloud")
wordcloud(names(freq), 
          freq, max.words=200, 
          scale=c(3, .1), 
          colors=brewer.pal(8, "Set1"))


#specifying a correlation limit of 0.5 
# finding the data correlation based on the certain one
dfm.tm<-convert(dfm.stem, to="tm")
findAssocs(dfm.tm, 
           c("data", "tech", "big"), 
           corlimit=0.6)
findAssocs(dfm.tm, 
           c("public","model", "create" ), 
           corlimit=0.7)

