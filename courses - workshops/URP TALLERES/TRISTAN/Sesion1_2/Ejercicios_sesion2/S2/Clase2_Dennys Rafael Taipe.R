library(tokenizers)
options(max.print = 25)

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

tokenize_characters(james)[[1]] 

tokenize_words(james)

library(tidyverse)
library(dplyr)

limpiar_tokenizar <- function(texto){
  # El orden de la limpieza no es arbitrario
  # Se convierte todo el texto a minúsculas
  nuevo_texto <- tolower(texto)
  # Eliminación de páginas web (palabras que empiezan por "http." seguidas 
  # de cualquier cosa que no sea un espacio
  nuevo_texto <- str_replace_all(nuevo_texto,"http\\S*", "")
  # Eliminación de signos de puntuación
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:punct:]]", " ")
  # Eliminación de números
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:digit:]]", " ")
  # Eliminación de espacios en blanco múltiples
  nuevo_texto <- str_replace_all(nuevo_texto,"[\\s]+", " ")
  # Eliminacion de tildes
  nuevo_texto <- chartr('áéíóúñ','aeioun',nuevo_texto)
  # Tokenización por palabras individuales
  nuevo_texto <- str_split(nuevo_texto, " ")[[1]]
  # Eliminación de tokens con una longitud < 2
  nuevo_texto <- keep(.x = nuevo_texto, .p = function(x){str_length(x) > 1})
  return(nuevo_texto)
  
}

limpiar_tokenizar(james)










################nuevo inicio###########

coronavirus <- readLines("discurso.txt",encoding="UTF-8")

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

#coronavirus <- readLines("discurso.txt",encoding="UTF-8")
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
  # Se convierte todo el texto a minúsculas
  nuevo_texto <- tolower(texto)
  # Eliminación de páginas web (palabras que empiezan por "http." seguidas 
  # de cualquier cosa que no sea un espacio)
  nuevo_texto <- str_replace_all(nuevo_texto,"http\\S*", "")
  # Eliminación de signos de puntuación
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:punct:]]", " ")
  # Eliminación de números
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:digit:]]", " ")
  # Eliminación de espacios en blanco múltiples
  nuevo_texto <- str_replace_all(nuevo_texto,"[\\s]+", " ")
  # Eliminacion de tildes
  nuevo_texto <- chartr('áéíóúñ','aeioun',nuevo_texto)
  # Tokenización por palabras individuales
  nuevo_texto <- str_split(nuevo_texto, " ")[[1]]
  # Eliminación de tokens con una longitud < 2
  nuevo_texto <- keep(.x = nuevo_texto, .p = function(x){str_length(x) > 1})
  return(nuevo_texto)
}

test = "El presidente de Perú, Martin VIZCARRA nació en 1990 en cañete a las 12:00 del mediodia
       según e'l portal l'limpieza de6 TEXTO  https://t.co/rnHPgyhx4Z usuario tRodrigo #text"
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

###########español###########palabras por defecto de la libreria###
d <- tm_map(d, removeWords, stopwords("spanish"))
d[["1"]][["content"]]
####lista personalizada  1###############
sw <- readLines("stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
d <- tm_map(d, removeWords, sw)
d[["1"]][["content"]]
####lista personalizada  2############
coronavirus_tidy <- coronavirus %>% select(-coronavirus) %>% unnest()
head(coronavirus_tidy) 

# Se filtran las stopwords
coronavirus_tidy <- coronavirus_tidy %>% filter(!(texto_tokenizado %in% sw))
head(coronavirus_tidy) 

##############




#######stemming################
library(pacman)
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


####lemtizacion_español########
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


text <- "los presidentes de las regiones tuvieron que aumentar los dias de cuarentena debido al incremento de nuevos casos"
text_tokens(text, stemmer = stem_liste)

names(coronavirus_tidy)[1] <- "term"
coronavirus_tidy=coronavirus_tidy %>%left_join(tabes, by = "term")
coronavirus_tidy$lemma=ifelse(is.na(coronavirus_tidy$stem ), coronavirus_tidy$term, coronavirus_tidy$stem)

coronavirus_tidy$lemma



######tagging#################
library(udpipe)
#cuando se descarga por primera vez el modelo
ud_model <- udpipe_download_model(language = "spanish")

data(brussels_reviews)

brussels_reviews
comments <- subset(brussels_reviews, language %in% "es")

ud_model <- udpipe_load_model(ud_model$file_model)
x <- udpipe_annotate(ud_model, x = comments$feedback, doc_id = comments$id)
x <- as.data.frame(x)

head(cbind(x$token,x$upos,x$lemma))

library(lattice)
stats <- txt_freq(x$upos)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = stats, col = "cadetblue", 
         main = "UPOS (Universal Parts of Speech)\n frequency of occurrence", 
         xlab = "Freq")


#######Bag of words##############
coronavirus_tidy %>% group_by(term) %>% count(term)%>% 
  arrange(desc(n))


###nuevo documento#####
economia <- readLines("economia.txt",encoding="UTF-8")
economia=as.data.frame(economia)
economia$ID <- seq.int(nrow(economia))
economia <- economia %>% mutate(texto_tokenizado = map(.x = economia,
                                                       .f = limpiar_tokenizar))
economia_tidy <- economia %>% select(-economia) %>% unnest()
head(economia_tidy)

#b <- udpipe_annotate(ud_model, x = economia_tidy$texto_tokenizado)
#b <- as.data.frame(b)

####fecuencia#######
economia_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  arrange(desc(n))
####frecuencia sin stop words##########
economia_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>% 
  count(texto_tokenizado)%>% arrange(desc(n))
####graficos1####
economia_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  filter(n >= 10) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras")+
  geom_col(fill="blue") +
  theme_bw() +
  labs(y = "", x = "") 
####graficos2####
economia_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>%
  count(texto_tokenizado)%>% filter(n >= 5) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras sin stop words")+
  geom_col(fill="red") +
  theme_bw() +
  labs(y = "", x = "") 

####TDM##############
d_tdm <- TermDocumentMatrix(d)
m <- as.matrix(d_tdm)
dim(m)
v <- sort(rowSums(m),decreasing=TRUE)
df <- data.frame(word = names(v),freq=v)

####DTM###########
d_dtm <- DocumentTermMatrix(d)
m2 <- as.matrix(d_dtm)


#######################tf#################################
# Número de veces que aparece cada término por tweet
coronavirus_tf <- coronavirus_tidy %>% group_by(ID,term) %>% summarise(n = n())

# Se añade una columna con el total de términos por tweet
coronavirus_tf <- coronavirus_tf %>% mutate(total_n = sum(n))

# Se calcula el tf
coronavirus_tf<- coronavirus_tf %>% mutate(tf = n / total_n )
head(coronavirus_tf)

####wordcloud###
coronavirus_wc=cbind.data.frame(coronavirus_tf$term,coronavirus_tf$n)
names(coronavirus_wc)[1] <- "term"
names(coronavirus_wc)[2] <- "n"
coronavirus_wc=coronavirus_wc %>% group_by(term) %>% summarise(n = sum(n)) %>%
  arrange(desc(n))

library(wordcloud)
wordcloud(words = coronavirus_wc$term, freq = coronavirus_wc$n,
          min.freq = 2, random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

wordcloud(words = coronavirus_wc$term, freq = coronavirus_wc$n,
          min.freq = 2,scale=c(2,.5), random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

dev.new(width = 1000, height = 1000, unit = "px")
wordcloud(words = coronavirus_wc$term, freq = coronavirus_wc$n,
          min.freq = 2, random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

dev.new(width = 1000, height = 1000, unit = "px")
library(wordcloud2)
wordcloud2(coronavirus_wc, 
           color = "random-light", 
           backgroundColor = "white")

###################tf-idf###################################
total_documentos = coronavirus_tidy$ID %>% unique() %>% length()
total_documentos

# Número de documentos en los que aparece cada término
coronavirus_idf=coronavirus_tidy %>% distinct(term, ID) %>% group_by(term) %>%
  summarise(n_documentos = n())

# Cálculo del idf
coronavirus_idf <- coronavirus_idf %>% mutate(idf = log10(total_documentos/n_documentos) ) %>%
  arrange(desc(idf))
head(coronavirus_idf)

#tfidf
coronavirus_tf_idf <- left_join(x = coronavirus_tf, y = coronavirus_idf, by = "term") %>% ungroup()
coronavirus_tf_idf <- coronavirus_tf_idf %>% mutate(tf_idf = tf * idf)
head(coronavirus_tf_idf)

#####word cloud tfidf##########
coronavirus_wc_tfidf=cbind.data.frame(coronavirus_tf_idf$term,coronavirus_tf_idf$tf_idf)
names(coronavirus_wc_tfidf)[1] <- "term"
names(coronavirus_wc_tfidf)[2] <- "n"
coronavirus_wc_tfidf=coronavirus_wc_tfidf %>% group_by(term) %>% summarise(n = sum(n)) %>%
  arrange(desc(n))

wordcloud2(coronavirus_wc_tfidf, 
           color = "random-light", 
           backgroundColor = "white")

###########nuevo texto####################
economia_wc=economia_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>% 
  count(texto_tokenizado)%>% arrange(desc(n))

wordcloud(words = economia_wc$texto_tokenizado, freq = economia_wc$n,
          min.freq = 2, random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

##########idf2#####################################

total_documentos1 = economia_tidy$ID %>% unique() %>% length()
total_documentos1

# Número de veces que aparece cada término por tweet
names(economia_tidy)[2] <- "term"
economia_tf <- economia_tidy %>% group_by(ID,term) %>% summarise(n = n())

# Se añade una columna con el total de términos por tweet
economia_tf <- economia_tf %>% mutate(total_n = sum(n))

economia_tf<- economia_tf %>% mutate(tf = n / total_n )
head(economia_tf)

# Número de documentos en los que aparece cada término
names(economia_tidy)[2] <- "term"
economia_idf=economia_tidy %>% distinct(term, ID) %>% group_by(term) %>%
  summarise(n_documentos = n())

# Cálculo del idf
economia_idf <- economia_idf %>% mutate(idf = log10(total_documentos/n_documentos) ) %>%
  arrange(desc(idf))
head(economia_idf)

#tfidf
economia_tf_idf <- left_join(x = economia_tf, y = economia_idf, by = "term") %>% ungroup()
economia_tf_idf <- economia_tf_idf %>% mutate(tf_idf = tf * idf)
head(economia_tf_idf)

economia_tf_idwc=economia_tf_idf %>% group_by(term) %>% summarise(zu = sum(tf_idf))

wordcloud(words = economia_tf_idwc$term, freq = economia_tf_idwc$zu,
          random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))


