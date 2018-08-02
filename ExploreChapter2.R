if(!require('reticulate')) install.packages("reticulate")
library(reticulate)
nltk <- import("nltk")



# book 2.1.9 loading your own corpus --------------------------------------


corpus <- nltk$corpus
corpus_reader <-nltk$corpus$PlaintextCorpusReader

corpuspath <- c('/usr/share/dict')
wordlists <- corpus_reader(corpuspath,'.*')
wordlists$fileids()
wordlists$words('propernames')
wordlists$words('web2a')
wordlists$words('words')
wordlists$words('connectives')
stopwords <- nltk$corpus$stopwords
stopwords$words()
stopwords$words('english')


py$run_string("print(unusual_words(\"goomba\")")
repl_python()
