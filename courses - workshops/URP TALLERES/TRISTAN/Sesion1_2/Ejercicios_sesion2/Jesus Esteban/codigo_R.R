library(tokenizers)
options(max.print = 25)




noticia<- readLines("noticias.txt",encoding="UTF-8")

##############tokenizacion por oraciones#################
tokenize_sentences(noticia)

##############tokenizacion por palabras#################

tokenize_words(noticia)
tokenize_words(noticia[[2]])

##################limpieza##########
####forma 1#######

library(tm)

noticia<- readLines("noticia.txt",encoding="UTF-8")
#noticia= iconv(noticia, to="ASCII//TRANSLIT")
corpus <- VCorpus(VectorSource(noticia))
d  <- tm_map(corpus, content_transformer(tolower))
d  <- tm_map(d, stripWhitespace)
d <- tm_map(d, removePunctuation)
d <- tm_map(d,removeNumbers)

d[["3"]][["content"]]
noticia[[1]]

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

noticia=as.data.frame(noticia)
noticia<- noticia%>% mutate(texto_tokenizado = map(.x = noticia,
                                                             .f = limpiar_tokenizar))
noticia%>% select(texto_tokenizado) %>% head()
noticia%>% slice(1) %>% select(texto_tokenizado) %>% pull()
noticia$ID <- seq.int(nrow(noticia))

####################Stop Words#######################

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
noticia_tidy <- noticia%>% select(-noticia) %>% unnest()
head(noticia_tidy) 

# Se filtran las stopwords
noticia_tidy <- noticia_tidy %>% filter(!(texto_tokenizado %in% sw))
head(noticia_tidy)
  



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


####lemtizacion_español########
#############stemming y lemmantizacion########
library(SnowballC)
library(corpus)

tabes=read.delim("lemmatization-es.txt",header = FALSE, sep = "",
                 stringsAsFactors = FALSE,encoding="UTF-8")
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



names(noticia_tidy)[1] <- "term"
noticia_tidy=noticia_tidy %>%left_join(tabes, by = "term")
noticia_tidy$lemma=ifelse(is.na(noticia_tidy$stem ), noticia_tidy$term, noticia_tidy$stem)



######tagging#################
library(udpipe)
#cuando se descarga por primera vez el modelo
ud_model <- udpipe_download_model(language = "spanish")


ud_model <- udpipe_load_model(ud_model$file_model)
x <- udpipe_annotate(ud_model, x = noticia$noticia, doc_id = noticia$ID)
x <- as.data.frame(x)

head(cbind(x$token,x$upos,x$lemma))

library(lattice)
stats <- txt_freq(x$upos)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = stats, col = "cadetblue", 
         main = "UPOS (Universal Parts of Speech)\n frequency of occurrence", 
         xlab = "Freq")

#######Bag of words##############
noticia_tidy %>% group_by(term) %>% count(term)%>% 
  arrange(desc(n))


noticia_tidy %>% group_by(lemma) %>% count(lemma)%>% 
  arrange(desc(n))

head(noticia_tidy)




noticia_tidy %>% group_by(lemma) %>% filter(!(lemma %in% sw))%>%
  count(lemma)%>% filter(n >= 4) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(lemma,n), y = n)) +
  ggtitle("Frecuencia de palabras lemmatizadas sin stop words")+
  geom_col(fill="cadetblue") +
  theme_bw() +
  labs(y = "", x = "") 

##############################################################################

####TDM##############
d_tdm <- TermDocumentMatrix(d)
d_tdm
m <- as.matrix(d_tdm)
dim(m)
v <- sort(rowSums(m),decreasing=TRUE)
df <- data.frame(word = names(v),freq=v)
df

####DTM###########
d_dtm <- DocumentTermMatrix(d)
m2 <- as.matrix(d_dtm)



#######################tf#################################
# Número de veces que aparece cada término por tweet
noticia_tf <- noticia_tidy %>% group_by(ID,term) %>% summarise(n = n())

# Se añade una columna con el total de términos por tweet
noticia_tf <- noticia_tf %>% mutate(total_n = sum(n))

# Se calcula el tf
noticia_tf<- noticia_tf %>% mutate(tf = n / total_n )
head(noticia_tf)

####wordcloud###
noticia_wc=cbind.data.frame(noticia_tf$l,noticia_tf$n)
names(noticia_wc)[1] <- "term"
names(noticia_wc)[2] <- "n"
noticia_wc=noticia_wc %>% group_by(term) %>% summarise(n = sum(n)) %>%
  arrange(desc(n))

library(wordcloud)
wordcloud(words = noticia_wc$term, freq = noticia_wc$n,
          min.freq = 2, random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

wordcloud(words = noticia_wc$term, freq = noticia_wc$n,
          min.freq = 2,scale=c(2,.5), random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

dev.new(width = 1000, height = 1000, unit = "px")
wordcloud(words = noticia_wc$term, freq = noticia_wc$n,
          min.freq = 2, random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

dev.new(width = 1000, height = 1000, unit = "px")
library(wordcloud2)
wordcloud2(noticia_wc, 
           color = "random-light", 
           backgroundColor = "white")


###################tf-idf###################################
total_documentos = noticia_tidy$ID %>% unique() %>% length()
total_documentos

# Número de documentos en los que aparece cada término
noticia_idf=noticia_tidy %>% distinct(term, ID) %>% group_by(term) %>%
  summarise(n_documentos = n())

# Cálculo del idf
noticia_idf <- noticia_idf %>% mutate(idf = log10(total_documentos/n_documentos) ) %>%
  arrange(desc(idf))
head(noticia_idf)

#tfidf
noticia_tf_idf <- left_join(x = noticia_tf, y = noticia_idf, by = "term") %>% ungroup()
noticia_tf_idf <- noticia_tf_idf %>% mutate(tf_idf = tf * idf)
head(noticia_tf_idf)

#####word cloud tfidf##########
noticia_wc_tfidf=cbind.data.frame(noticia_tf_idf$term,noticia_tf_idf$tf_idf)
names(noticia_wc_tfidf)[1] <- "term"
names(noticia_wc_tfidf)[2] <- "n"
noticia_wc_tfidf=noticia_wc_tfidf %>% group_by(term) %>% summarise(n = sum(n)) %>%
  arrange(desc(n))

wordcloud2(noticia_wc_tfidf, 
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