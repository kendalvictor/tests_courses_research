rm(list = ls())
dev.off()
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tokenizers)
options(max.print = 25)

###############tokenizacion por oraciones#######################
james <- paste0(
  "The question thus becomes a verbal one\n",
  "again; and our knowledge of all these early stages of thought and feeling\n",
  "is in any case so conjectural and imperfect that farther discussion would\n",
  "not be worth while.\n",
  "\n",
  "Religion, therefore, as I now ask you arbitrarily to take it, shall mean\n",
  "for us _the feelings, acts, and experiences of individual men in their\n",
  "solitude, so far as they apprehend themselves to stand in relation to\n",
  "whatever they may consider the divine_. Since the relation may be either\n",
  "moral, physical, or ritual, it is evident that out of religion in the\n",
  "sense in which we take it, theologies, philosophies, and ecclesiastical\n",
  "organizations may secondarily grow.\n"
)

tokenize_sentences(james) 

coronavirus <- readLines("noticia.txt",encoding="UTF-8")
tokenize_sentences(coronavirus)

##############tokenizacion por palarbas#################

tokenize_words(james)
tokenize_words(coronavirus)
tokenize_words(coronavirus[[2]])

##################limpieza##########
####forma 1#######

library(tm)

coronavirus <- readLines("noticia.txt",encoding="UTF-8")
#coronavirus = iconv(coronavirus, to="ASCII//TRANSLIT")
corpus <- VCorpus(VectorSource(coronavirus))
d  <- tm_map(corpus, content_transformer(tolower))
d  <- tm_map(d, stripWhitespace)
d <- tm_map(d, removePunctuation)
d <- tm_map(d,removeNumbers)

d[["3"]][["content"]]
coronavirus[[1]]

######forma 2###########
library(tidyverse)
library(dplyr)

limpiar_tokenizar <- function(texto){
  # El orden de la limpieza no es arbitrario
  # Se convierte todo el texto a minÃºsculas
  nuevo_texto <- tolower(texto)
  # EliminaciÃ³n de pÃ¡ginas web (palabras que empiezan por "http." seguidas 
  # de cualquier cosa que no sea un espacio)
  nuevo_texto <- str_replace_all(nuevo_texto,"http\\S*", "")
  # EliminaciÃ³n de signos de puntuaciÃ³n
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:punct:]]", " ")
  # EliminaciÃ³n de nÃºmeros
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:digit:]]", " ")
  # EliminaciÃ³n de espacios en blanco mÃºltiples
  nuevo_texto <- str_replace_all(nuevo_texto,"[\\s]+", " ")
  # Eliminacion de tildes
  nuevo_texto <- chartr('áéíóúñ','aeioun',nuevo_texto)
  # TokenizaciÃ³n por palabras individuales
  nuevo_texto <- str_split(nuevo_texto, " ")[[1]]
  # EliminaciÃ³n de tokens con una longitud < 2
  nuevo_texto <- keep(.x = nuevo_texto, .p = function(x){str_length(x) > 1})
  return(nuevo_texto)
}

test = "El presidente de Perú, Martin VIZCARRA nació en 1990 en cañete a las 12:00 del mediodia
       según e'l portal l'limpieza del 6 TEXTO  https://t.co/rnHPgyhx4Z usuario tRodrigo #text"
limpiar_tokenizar(texto = test)

coronavirus=as.data.frame(coronavirus)
coronavirus <- coronavirus %>% mutate(texto_tokenizado = map(.x = coronavirus,
                                                   .f = limpiar_tokenizar))
coronavirus %>% select(texto_tokenizado) %>% head()
coronavirus %>% slice(1) %>% select(texto_tokenizado) %>% pull()
coronavirus$ID <- seq.int(nrow(coronavirus))

####################Stop Words#######################
##############ingles#######################
library(stopwords)
tokenize_words(james)
tokenize_words(james, stopwords = stopwords::stopwords("en"))

length(stopwords(source = "smart"))
length(stopwords(source = "snowball"))
length(stopwords(source = "stopwords-iso"))


stopwords(language = "en", source = "smart")

###########espaÃ±ol#####################
####palabras por defecto de la libreria###
d <- tm_map(d, removeWords, stopwords("spanish"))
d[["1"]][["content"]]
####lista personalizada  1###############
sw <- readLines("./stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
d <- tm_map(d, removeWords, sw)
d[["1"]][["content"]]
####lista personalizada  2############
coronavirus_tidy <- coronavirus %>% select(-coronavirus) %>% unnest()
head(coronavirus_tidy) 

# Se filtran las stopwords
coronavirus_tidy <- coronavirus_tidy %>% filter(!(texto_tokenizado %in% sw))
head(coronavirus_tidy) 


#######stemming################
#install.packages('pacman')
library(pacman)
#install.packages('textstem')
library(textstem)
dw <- c('driver', 'drive', 'drove', 'driven', 'drives', 'driving')
stem_words(dw)

y <- c(
  'the dirtier dog has eaten the pies',
  'that shameful pooch is tricky and sneaky',
  "He opened and then reopened the food bag",
  'There are skies of blue and red roses too!',
  NA,
  "The doggies, well they aren't joyfully running.",
  "The daddies are coming over...",
  "This is 34.546 above"
)

stem_strings(y)

#######lematization################
dw <- c('driver', 'drive', 'drove', 'driven', 'drives', 'driving')
lemmatize_words(dw)

y <- c(
  'the dirtier dog has eaten the pies',
  'that shameful pooch is tricky and sneaky',
  "He opened and then reopened the food bag",
  'There are skies of blue and red roses too!',
  NA,
  "The doggies, well they aren't joyfully running.",
  "The daddies are coming over...",
  "This is 34.546 above"
)
lemmatize_strings(y)


####lemtizacion_espaÃ±ol########
#############stemming y lemmantizacion########
library(SnowballC)
#install.packages('corpus')
library(corpus)

tabes=read.delim("./lemmatization-es.txt",header = FALSE, sep = "",
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


text <- "los presidentes de las regiones tuvieron que aumentar los dias de cuarentena debido al incremento de nuevos casos"
text_tokens(text, stemmer = stem_liste)

names(coronavirus_tidy)[1] <- "term"
coronavirus_tidy=coronavirus_tidy %>%left_join(tabes, by = "term")
coronavirus_tidy$lemma=ifelse(is.na(coronavirus_tidy$stem ), coronavirus_tidy$term, coronavirus_tidy$stem)

 
####TDM##############
d_tdm <- TermDocumentMatrix(d)
m <- as.matrix(d_tdm)
dim(m)
v <- sort(rowSums(m),decreasing=TRUE)
df <- data.frame(word = names(v),freq=v)

####DTM###########
d_dtm <- DocumentTermMatrix(d)
m2 <- as.matrix(d_dtm)
m2
