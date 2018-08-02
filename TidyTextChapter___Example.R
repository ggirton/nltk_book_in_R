
# Tidy Text Chapter 1 -----------------------------------------------------

text <- c("Because I could not stop for Death -",
          "He kindly stopped for me -",
          "The Carriage held but just Ourselves -",
          "and Immortality")

text

library(dplyr)
text_df <- data_frame(line =1:4, text=text)
text_df

library(tidytext)
text_df %>% unnest_tokens(word,text)

library(janeaustenr)
library(stringr)


# Combine Jane Austen books -----------------------------------------------


original_books <- austen_books() %>%
  group_by(book) %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",
                                                 ignore_case = TRUE)))) %>%
  ungroup()

original_books


# Tidy Jane Austen books  ---------------------------------------------------


tidy_books <- original_books %>%
  unnest_tokens(word, text)

tidy_books

stop_words
"no" %in% stop_words$word
"able" %in% stop_words$word
"accobacco" %in% stop_words$word



# Without removing stop words, count words --------------------------------

library(ggplot2)

tidy_books %>%
  count(word, sort = TRUE) %>%
  filter(n > 1000) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip()


# Gutenberg loading -------------------------------------------------------

if(!require("gutenbergr")) install.packages("gutenbergr"); library(gutenbergr)

hgwells <- gutenberg_download(c(35, 36, 5230, 159))

tidy_hgwells <- hgwells %>% unnest_tokens(word,text) %>% anti_join(stop_words)

tidy_hgwells %>% count(word, sort = TRUE)

bronte <- gutenberg_download(c(1260, 768, 969, 9182, 767))

tidy_bronte <- bronte %>% unnest_tokens(word, text) %>% anti_join(stop_words)
tidy_bronte %>% count(word, sort=TRUE)
tidy_austen <- tidy_books %>%  anti_join(stop_words)
tidy_austen %>% count(word, sort=TRUE)




library(tidyr)

frequency <- bind_rows(mutate(tidy_bronte, author = "Brontë Sisters"),
                       mutate(tidy_hgwells, author = "H.G. Wells"), 
                       mutate(tidy_austen, author = "Jane Austen")) %>% 
  mutate(word = str_extract(word, "[a-z']+")) %>%
  count(author, word) %>%
  group_by(author) %>%
  mutate(proportion = n / sum(n)) %>% 
  select(-n) %>% 
  spread(author, proportion) %>% 
  gather(author, proportion, `Brontë Sisters`:`H.G. Wells`)


# Plot the frequency of the three corpi -----------------------------------

library(scales)

# expect a warning about rows with missing values being removed
ggplot(frequency, aes(x = proportion, y = `Jane Austen`, color = abs(`Jane Austen` - proportion))) +
  geom_abline(color = "gray40", lty = 2) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  scale_color_gradient(limits = c(0, 0.001), low = "darkslategray4", high = "gray75") +
  facet_wrap(~author, ncol = 2) +
  theme(legend.position="none") +
  labs(y = "Jane Austen", x = NULL)



# Correlate the word sets -------------------------------------------------

cor.test(data=frequency[frequency$author == "Brontë Sisters",],
         ~ proportion + `Jane Austen`)

cor.test(data=frequency[frequency$author == "H.G. Wells",],
         ~ proportion + `Jane Austen`)

# Tidy Text Chapter 2 Sentiment Analysis  -----------------------------------------------------
#  https://www.tidytextmining.com/sentiment.html

unique(stop_words$lexicon)

unique(sentiments$lexicon)
unique(sentiments$sentiment)
length(unique(sentiments$word))

get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")
get_sentiments("loughran")

tidy_books <- austen_books() %>% group_by(book) %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",
                                                 ignore_case = TRUE)))) %>%
  ungroup() %>%
  unnest_tokens(word, text)

## Joy in Emma
nrc_joy <-get_sentiments("nrc") %>%
  filter(sentiment == "joy")

tidy_books %>% filter(book == "Emma") %>%
  inner_join(nrc_joy) %>%
  count(word, sort = TRUE)



jane_austen_sentiment <- tidy_books %>%
  inner_join(get_sentiments("bing")) %>%
  count(book, index = linenumber %/% 80, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)


ggplot(jane_austen_sentiment, aes(index, sentiment, fill = book)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~book, ncol = 2, scales = "free_x")


## 2.4 most common positive & ne8ative words

str(tidy_books)
str(get_sentiments("bing"))

# 'word' is in common

bing_word_sentiment_counts <- tidy_austen %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()

bing_word_sentiment_counts %>% group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill=sentiment)) +
  geom_col() + facet_wrap(~sentiment, scales ="free_y") +
  labs(y= "Contribution to sentiment", x=NULL) +
  coord_flip()

new_stop <- data_frame(word = c("miss"), 
           lexicon = c("custom"))

# I like this ideom better for its clarity:
new_stop <- tribble(~word, ~lexicon, 
                    c("doubt"), c("custom"),
                    c("miss"), c("custom"))
# I didn't think 'doubt' was all that negative either

custom_stop_words <- bind_rows(new_stop,stop_words)

custom_stop_words

if (!require("wordcloud")) install.packages("wordcloud"); library(wordcloud)

tidy_austen %>% 
  anti_join(custom_stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))

library(reshape2)

tidy_austen %>%  anti_join(custom_stop_words) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors =c("purple", "green"), max.words = 45)

## Other units

PandP_sentences <- data_frame(text = prideprejudice) %>% 
  unnest_tokens(sentence, text, token = "sentences")

no_no_no <- c("no no")

table(str_detect(PandP_sentences$sentence, no_no_no))

pp_nono <- filter(PandP_sentences, str_detect(sentence,no_no_no))
print(pp_nono$sentence[1])
print(pp_nono$sentence[2])
# "no notice"   and "no notion"

PandP_sentences$sentence[str_detect(PandP_sentences$sentence, no_no_no)]

str(bronte)
bronte_sentences <- data_frame(text = bronte$text) %>% 
  unnest_tokens(sentence, text, token = "sentences")

no_no_no <- c("no no")
table(str_detect(bronte_sentences$sentence, no_no_no))

# 3 word and document frequency  ------------------------------------------


# 4 Word relationships by n-gram!! ------------------------------------------
wow <- c("What we've been waiting for, no no no? Yeah yeah!")

str(austen_books())
austen_bigrams <- austen_books() %>%
  unnest_tokens(bigram, text, token = "ngrams", n=2)

austen_trigrams <- austen_books() %>%
  unnest_tokens(bigram, text, token = "ngrams", n=3)

austen_bigrams
table(austen_bigrams$bigram == "no no")

table(austen_trigrams$bigram == "no no no")

table(austen_trigrams$bigram == "no no no no")

str_count(bronte, c("no no"))

# 5 Wheelhouse Glue (onversions-Cay) --------------------------------------

if(!require('tm')) install.packages("tm"); library(tm)
if(!require('topicmodels')) install.packages("topicmodels"); library(topicmodels)

data("AssociatedPress", package ="topicmodels")

AssociatedPress
terms <- Terms(AssociatedPress)
head(terms,99)


library(dplyr)
library(tidytext)

ap_td <- tidy(AssociatedPress)
ap_td
(ap_corpus_vocabulary <- length(unique(ap_td$term)))
sum(ap_td$count)

(ap_sentiments <- ap_td %>%
  inner_join(get_sentiments("bing"), by=c(term="word"))
)


ap_sentiments %>%
  count(sentiment, term, wt=count) %>%
  ungroup() %>%
  filter(n >=200) %>%
  mutate(n = ifelse(sentiment == "negative", -n,n)) %>%
  mutate(term = reorder(term, n)) %>%
  ggplot(aes(term, n, fill = sentiment)) +
  geom_col()+
  ylab("contribution to sentiment") +
  coord_flip()

if(!require('quanteda')) install.packages("quanteda"); library(quanteda)
data("data_corpus_inaugural")
inaug_dfm <- quanteda::dfm(data_corpus_inaugural, verbose=FALSE)

(inaug_td <- tidy(inaug_dfm))

inaug_tf_idf <- inaug_td %>%
  bind_tf_idf(term, document, count) %>%
  arrange(desc(tf_idf))
inaug_tf_idf  

unique(inaug_tf_idf$document)


year_term_counts <- inaug_td %>%
  extract(document, "year", "(\\d+)", convert = TRUE) %>%
  complete(year, term, fill= list(count=0)) %>%
  group_by(year) %>%
  mutate(year_total = sum(count))

year_term_counts %>%
  filter(term %in% c("god", "america", "foreign", "union", "constitution", "freedom")) %>%
  ggplot(aes(year, count/year_total)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~term, scales = "free_y") +
  ylab("% frequency of word in inaugural address")
