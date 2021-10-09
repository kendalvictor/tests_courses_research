library(tokenizers)
#proceso de tokenizacion
lematizacion <- readLines("noticia.txt",encoding="UTF-8")
tokenize_sentences(lematizacion)
tokenize_words(lematizacion[[2]])

##################limpieza##########

library(tm)
lematizacion <- readLines("noticia.txt",encoding="UTF-8")
#coronavirus = iconv(coronavirus, to="ASCII//TRANSLIT")
corpus <- VCorpus(VectorSource(lematizacion))
d  <- tm_map(corpus, content_transformer(tolower))
d  <- tm_map(d, stripWhitespace)
d <- tm_map(d, removePunctuation)
d <- tm_map(d,removeNumbers)

d[["3"]][["content"]]
lematizacion[[3]]


####################Stop Words#######################
library(stopwords)
####palabras por defecto de la libreria###
d <- tm_map(d, removeWords, stopwords("spanish"))
d[["3"]][["content"]]

####lista personalizada  1###############
sw <- readLines("stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
d <- tm_map(d, removeWords, sw)
d[["1"]][["content"]]

#dplyr::select(.)
####lista personalizada  2############
library(tidyverse)
library(dplyr)

lematizacion_tidy <- lematizacion %>% select(-lematizacion) %>% unnest()
head(lematizacion_tidy) 

# Se filtran las stopwords
lematizacion_tidy <- lematizacion_tidy %>% filter(!(texto_tokenizado %in% sw))
head(lematizacion_tidy) 

#############stemming y lemmantizacion########
library(SnowballC)
library(corpus)
tabes=read.delim("lemmatization-es.txt",header = FALSE, sep = "",
                 stringsAsFactors = FALSE)
names(tabes) <- c("stem", "term")

head(tabes,10)

stem_liste <- function(term) {
  i <- match(term, tabes$term)
  if (is.na(i)) {
    stem <- term
  } else {
    stem <- tabes$stem[[i]]
  }
  stem
}

names(lematizacion_tidy)[1] <- "term"
lematizacion_tidy=lematizacion_tidy %>%left_join(tabes, by = "term")
lematizacion_tidy$lemma=ifelse(is.na(lematizacion_tidy$stem ), lematizacion_tidy$term, lematizacion$stem)

######tagging#################
install.packages("udpipe")
library(udpipe)
#cuando se descarga por primera vez el modelo
ud_model <- udpipe_download_model(language = "spanish")
ud_model <- udpipe_load_model(ud_model$file_model)

x <- udpipe_annotate(ud_model, x = lematizacion$lematizacion, doc_id = lematizacion$id)
x <- as.data.frame(x)
