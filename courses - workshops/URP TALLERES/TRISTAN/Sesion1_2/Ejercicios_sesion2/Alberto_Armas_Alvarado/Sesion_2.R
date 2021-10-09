
################## Tokenizar oraciones y palabras ##################

# Cambiar el directorio de trabajo
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(tokenizers)

noticia <- readLines("noticias.txt",encoding="UTF-8")
tokenize_sentences(noticia)

tokenize_words(noticia[[8]])

################## Limpieza ##################
################## Forma 1

library(tm)

noticia <- readLines("noticias.txt",encoding="UTF-8")

corpus <- VCorpus(VectorSource(noticia))
d <- tm_map(corpus, content_transformer(tolower))
d <- tm_map(d, stripWhitespace)
d <- tm_map(d, removePunctuation)
d <- tm_map(d, removeNumbers)

d[["8"]][["content"]]
noticia[[8]]

library(tidyverse)
library(dplyr)

limpiar_tokenizar <- function(texto){
  # El orden de la limpieza no es arbitrario
  
  # Se convierte todo el texto a minÃÂºsculas
  nuevo_texto <- tolower(texto)
  
  # EliminaciÃÂ³n de pÃÂ¡ginas web (palabras que empiezan por "http." seguidas 
  # de cualquier cosa que no sea un espacio)
  nuevo_texto <- str_replace_all(nuevo_texto,"http\\S*", "")
  
  # EliminaciÃÂ³n de signos de puntuaciÃÂ³n
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:punct:]]", " ")
  
  # EliminaciÃÂ³n de nÃÂºmeros
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:digit:]]", " ")
  
  # EliminaciÃÂ³n de espacios en blanco mÃÂºltiples
  nuevo_texto <- str_replace_all(nuevo_texto,"[\\s]+", " ")
  
  # Eliminacion de tildes
  nuevo_texto <- chartr('áéíóúñ','aeioun',nuevo_texto)
  
  # TokenizaciÃÂ³n por palabras individuales
  nuevo_texto <- str_split(nuevo_texto, " ")[[1]]
  
  # EliminaciÃÂ³n de tokens con una longitud < 2
  nuevo_texto <- keep(.x = nuevo_texto, .p = function(x){str_length(x) > 1})
  
  return(nuevo_texto)
}

limpiar_tokenizar(noticia[[8]])
noticia

noticia <- as.data.frame(noticia)
noticia <- noticia %>% mutate(texto_tokenizado=map(.x = noticia, 
                                                   .f = limpiar_tokenizar))
noticia %>% select(texto_tokenizado) %>% head() 
noticia %>% slice(1) %>% select(texto_tokenizado) %>% pull()
noticia$ID <- seq.int(nrow(noticia))

################## Stop Words ##################

########### espaÃ±ol #####################
####palabras por defecto de la libreria###

d <- tm_map(d, removeWords, stopwords("spanish"))
d[["1"]][["content"]]


##### Lista personalizada 1 ###############
sw <- readLines("stopwordses.txt", encoding="UTF-8")
sw <- iconv(sw, to="ASCII//TRANSLIT")

d <- tm_map(d, removeWords, sw)
d[["1"]][["content"]]

##### Lista personalizada 2 ###############
noticia_tidy <- noticia %>% select(-noticia) %>% unnest(cols = c(texto_tokenizado))
head(noticia_tidy)


##### Se filtran las stopwords ###############

noticia_tidy <- noticia_tidy %>% filter(!(texto_tokenizado %in% sw))
head(noticia_tidy)


####### Stemming################
library(pacman)
library(textstem)

####lemtizacion_espaÃ±ol########
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
  
  
  names(noticia_tidy)[1] <- "term"
  noticia_tidy=noticia_tidy %>%left_join(tabes, by = "term")
  noticia_tidy$lemma=ifelse(is.na(noticia_tidy$stem ), noticia_tidy$term, noticia_tidy$stem)
  

###### Tagging #################
library(udpipe)
ud_model <- udpipe_download_model(language = "spanish")
ud_model <- udpipe_load_model(ud_model$file_model)

noticia_tag <- udpipe_annotate(ud_model, x = noticia$noticia, doc_id = noticia$ID)
noticia_tag <- as.data.frame(noticia_tag)

library(lattice)
stats <- txt_freq(noticia_tag$upos)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = stats, col = "cadetblue", 
         main = "UPOS (Universal Parts of Speech) de noticia\n Frecuencia de Ocurrencia", 
         xlab = "Freq")



#######Bag of words##############
noticia_tidy %>% group_by(term) %>% count(term)%>% 
  arrange(desc(n))

###nuevo documento#####
noticia <- readLines("noticias.txt",encoding="UTF-8")
noticia=as.data.frame(noticia)
noticia$ID <- seq.int(nrow(noticia))
noticia <- noticia %>% mutate(texto_tokenizado = map(.x = noticia,
                                                       .f = limpiar_tokenizar))
noticia_tidy <- noticia %>% select(-noticia) %>% unnest(cols = c(texto_tokenizado))
head(noticia_tidy)

#b <- udpipe_annotate(ud_model, x = economia_tidy$texto_tokenizado)
#b <- as.data.frame(b)

####fecuencia#######
noticia_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  arrange(desc(n))
####frecuencia sin stop words##########
noticia_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>% 
  count(texto_tokenizado)%>% arrange(desc(n))
####graficos1####
noticia_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  filter(n >= 10) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras")+
  geom_col(fill="blue") +
  theme_bw() +
  labs(y = "", x = "") 

####graficos2####
noticia_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>%
  count(texto_tokenizado)%>% filter(n >= 5) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras sin stop words")+
  geom_col(fill="red") +
  theme_bw() +
  labs(y = "", x = "") 

noticia_tidy

####TDM##############
d_tdm <- TermDocumentMatrix(d)
m <- as.matrix(d_tdm)
dim(m)
v <- sort(rowSums(m),decreasing=TRUE)
df <- data.frame(word = names(v),freq=v)

####DTM###########
d_dtm <- DocumentTermMatrix(d)
m2 <- as.matrix(d_dtm)

d_dtm

