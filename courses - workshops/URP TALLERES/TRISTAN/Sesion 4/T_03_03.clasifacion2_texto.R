library(tidyverse)
library(tidytext)
library(naivebayes)
library(tm)
library(caret)
#######naive bayes######################
tuits_df =
  read.csv("tuits.csv", stringsAsFactors = F, fileEncoding = "latin1") %>%
  tbl_df

tuits_df$screen_name2=ifelse(tuits_df$screen_name== "MSFTMexico", tuits_df$screen_name, "Otro")
tuits_df$screen_name2=as.factor(tuits_df$screen_name2)

tuits_df$text <- str_replace_all(tuits_df$text,"http\\S*", "")
tuits_df$text <- str_replace_all(tuits_df$text,"[\\s]+", " ")
tuits_df$text <- chartr('αινσϊρ','aeioun',tuits_df$text)

tuits_df$text=as.character(tuits_df$text)

str(tuits_df)

tuits_df_corpus <- VCorpus(VectorSource(tuits_df$text))
print(tuits_df_corpus)
inspect(tuits_df_corpus[1:3])


tuits_df_clean <- tm_map(tuits_df_corpus, tolower)
tuits_df_clean <- tm_map(tuits_df_clean, removeNumbers)
sw <- readLines("D:/URP/MATERIAL_CLASES/CURSO_TEXT_MINING/stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
tuits_df_clean <- tm_map(tuits_df_clean, removeWords, stopwords("spanish"))
tuits_df_clean <- tm_map(tuits_df_clean, removeWords, sw)
tuits_df_clean <- tm_map(tuits_df_clean, removePunctuation)
tuits_df_clean <- tm_map(tuits_df_clean, stripWhitespace)
inspect(tuits_df_clean[1:3])
tuits_df_clean <- tm_map(tuits_df_clean, PlainTextDocument)

#tuits_df_dtm <- DocumentTermMatrix(tuits_df_clean)
#tuits_df_dtm

tuits_df_dtm <- DocumentTermMatrix(tuits_df_clean,control = list(weighting = weightTfIdf))
tuits_df_dtm

#tuits_df_dtm_idf = weightTfIdf(tuits_df_dtm, normalize = TRUE)
#tuits_df_dtm_idf

set.seed(123)
trainl <- sample(x = 1:nrow(tuits_df_dtm), size = 0.7 * nrow(tuits_df_dtm))

tuits_df_train <- tuits_df[trainl, ]
tuits_df_test  <- tuits_df[-trainl, ]

tuits_df_corpus_train <- tuits_df_clean[trainl ]
tuits_df_corpus_test  <- tuits_df_clean[-trainl ]

tuits_df_dtm_train <- tuits_df_dtm[trainl, ]
tuits_df_dtm_test  <- tuits_df_dtm[-trainl, ]

#tuits_df_dtmif_train <- tuits_df_dtm_idf[trainl, ]
#tuits_df_dtmif_test  <- tuits_df_dtm_idf[-trainl, ]

prop.table(table(tuits_df_train$screen_name2))
prop.table(table(tuits_df_test$screen_name2))

tuits_df_dict <- findFreqTerms(tuits_df_dtm_train, 1)

tuits_df_md_train <- DocumentTermMatrix(tuits_df_corpus_train, list(dictionary = tuits_df_dict))
tuits_df_md_test  <- DocumentTermMatrix(tuits_df_corpus_test, list(dictionary = tuits_df_dict))

convert_counts <- function(x) {
  x <- ifelse(x > 0, 1, 0)
  x <- factor(x, levels = c(0, 1), labels = c("No", "Yes"))
}

#memory.limit(3977)

tuits_df_md_train <- apply(tuits_df_md_train, MARGIN = 2, convert_counts)
tuits_df_md_test  <- apply(tuits_df_md_test, MARGIN = 2, convert_counts)

library(e1071)
library(gmodels)
realtextl2_classifier <- naiveBayes(tuits_df_md_train, tuits_df_train$screen_name2)
realtextl2_test_pred <- predict(realtextl2_classifier, tuits_df_md_test)

CrossTable(realtextl2_test_pred,tuits_df_test$screen_name2,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

library(caret)
confusionMatrix(realtextl2_test_pred, tuits_df_test$screen_name2)
