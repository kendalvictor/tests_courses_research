library(tokenizers)
options(max.print = 25)

###############tokenizacion por oraciones#######################
coronavirus <- readLines("noticia.txt",encoding="UTF-8")
tokenize_sentences(coronavirus)

##############tokenizacion por palarbas#################
tokenize_words(coronavirus)
tokenize_words(coronavirus[[2]])

##################limpieza##########
####forma 1#######
install.packages("koRpus")
install.packages("tm")
install.packages("NLP", dependencies = TRUE)
library(tm)

coronavirus <- readLines("noticia.txt",encoding="UTF-8")
#Se construye un vector de caracteres
corpus <- VCorpus(VectorSource(coronavirus))
#Convierte el texto a minúsculas
d  <- tm_map(corpus, content_transformer(tolower))
#Elimina espacios en blanco adicionales de un documento de texto
d  <- tm_map(d, stripWhitespace)
#Elimina puntuación
d <- tm_map(d, removePunctuation)
#Elimina números
d <- tm_map(d,removeNumbers)

d[["1"]][["content"]]
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

limpiar_tokenizar(coronavirus)


coronavirus=as.data.frame(coronavirus)
coronavirus <- coronavirus %>% mutate(texto_tokenizado = map(.x = coronavirus,
                                                   .f = limpiar_tokenizar))
coronavirus %>% select(texto_tokenizado) %>% head()
coronavirus %>% slice(1) %>% select(texto_tokenizado) %>% pull()
coronavirus$ID <- seq.int(nrow(coronavirus))

####################Stop Words#######################
library(tokenizers)
library(tm)
library(tidyverse)
library(dplyr)
install.packages("stopwords")
library(stopwords)
###########español#####################

####palabras por defecto de la libreria###
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

#######stemming################
install.packages("koRpus")
install.packages("koRpus.lang.en")
install.packages("sylly")
#install.koRpus.lang("en")
library(pacman)
library(textstem)

####lemtizacion_español########
#############stemming y lemmantizacion########
library(SnowballC)
library(corpus)

tabes=read.delim("lemmatization-es.txt",header = FALSE, sep = "",stringsAsFactors = FALSE)
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

names(coronavirus_tidy)[1] <- "term"
coronavirus_tidy=coronavirus_tidy %>%left_join(tabes, by = "term")
coronavirus_tidy$lemma=ifelse(is.na(coronavirus_tidy$stem ), coronavirus_tidy$term, coronavirus_tidy$stem)

######tagging#################
library(udpipe)
#cuando se descarga por primera vez el modelo
ud_model <- udpipe_download_model(language = "spanish")

data(brussels_reviews)
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
economia <- readLines("noticia.txt",encoding="UTF-8")
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
library(tm)

d_tdm <- TermDocumentMatrix(coronavirus_tidy)
d_tdm
m <- as.matrix(d_tdm)
dim(m)
v <- sort(rowSums(m),decreasing=TRUE)
v
df <- data.frame(word = names(v),freq=v)
df

####DTM###########
d_dtm <- DocumentTermMatrix(d)
d_dtm
m2 <- as.matrix(d_dtm)
m2

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


