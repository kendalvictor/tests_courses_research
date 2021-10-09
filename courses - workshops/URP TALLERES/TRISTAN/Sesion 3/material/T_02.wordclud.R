library(tm)
library(SnowballC)
library(wordcloud)

reviews=read.csv("IMDB Dataset.csv", stringsAsFactors=FALSE)
#####filtrado de las primeras 7000 reseñas#######
reviews=reviews[1:7000,]
#####vectorizacion del archivo###
review_corpus = VCorpus(VectorSource(reviews$review))
###limpieza del archivo######
review_corpus = tm_map(review_corpus, content_transformer(tolower))
review_corpus = tm_map(review_corpus, removeNumbers)
review_corpus = tm_map(review_corpus, removePunctuation)
review_corpus = tm_map(review_corpus, removeWords, c("the", "and", stopwords("english")))
review_corpus =  tm_map(review_corpus, stripWhitespace)
###vista del primer comentario###
inspect(review_corpus[1])
####transformacion tdm#####
review_tdm <- TermDocumentMatrix(review_corpus)
review_tdm
inspect(review_tdm[500:505, 500:505])
####eliminacion de las palabras menos frecuentes de modo que la dispersión sea inferior a 0,99####
##Un ejemplo del umbral de dispersión de 0,99, donde un término que aparece menos
##  de 0,01 en los documentos
review_tdm = removeSparseTerms(review_tdm, 0.99)
review_tdm
m <- as.matrix(review_tdm)
v <- sort(rowSums(m),decreasing=TRUE)
##frecuencia de palabras##
df <- data.frame(word = names(v),freq=v)
####nube de palabras forma 1###
wordcloud(words = df$word, freq = df$freq,
          min.freq = 420, random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))
###nube la palabras forma 2####
library(wordcloud2)
wordcloud2(df, 
           color = "random-light", 
           backgroundColor = "white")
########tf_idf################################
review_tdm_tfidf = TermDocumentMatrix(review_corpus, control = list(weighting = weightTfIdf))
review_tdm_tfidf = removeSparseTerms(review_tdm_tfidf, 0.99)
review_tdm_tfidf
m_tfidf <- as.matrix(review_tdm_tfidf)
v_tfidf <- sort(rowSums(m_tfidf),decreasing=TRUE)
df_tfidf <- data.frame(word = names(v_tfidf),freq=v_tfidf)
###nube de palabras#####
wordcloud2(df_tfidf, 
           color = "random-light", 
           backgroundColor = "white")
