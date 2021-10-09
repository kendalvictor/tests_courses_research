library(tokenizers)
options(max.print=250)

######### Tokenizacion ##########
noticia2 <- readLines("noticia.txt",encoding="UTF-8")
tokenize_sentences(noticia2)


tokenize_words(noticia2)

tokenize_words(noticia2[[1]])


library(tm)
corpus<-VCorpus(VectorSource(noticia2))
d<- tm_map(corpus,content_transformer(tolower))
d<- tm_map(d,stripWhitespace)
d<- tm_map(d,removePunctuation)
d<- tm_map(d,removeNumbers)

texto <- noticia2

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

nueva_noticia <- limpiar_tokenizar(noticia2)
nueva_noticia

noticia2=as.data.frame(noticia2)
noticia2 <- noticia2 %>% mutate(texto_tokenizado = map(.x = noticia2,
                                                             .f = limpiar_tokenizar))
noticia2 %>% select(texto_tokenizado) %>% head()
noticia2 %>% slice(1) %>% select(texto_tokenizado) %>% pull()
noticia2$ID <- seq.int(nrow(noticia2))


###########español#####################
####palabras por defecto de la libreria###
d <- tm_map(d, removeWords, stopwords("spanish"))
d[["1"]][["content"]]
####lista personalizada  1###############
sw <- readLines("D:/Maestría/Ciclo IV/Cursos/MCD-402_Análisis EstadisticoTexto/Sesion2/stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
d <- tm_map(d, removeWords, sw)
d[["1"]][["content"]]
####lista personalizada  2############
noticia2_tidy <- noticia2 %>% select(-noticia2) %>% unnest()
head(noticia2_tidy) 

# Se filtran las stopwords
noticia2_tidy <- noticia2_tidy %>% filter(!(texto_tokenizado %in% sw))
head(noticia2_tidy)


library(pacman)
library(textstem)


####lematizacion_español########
#############stemming y lemmantizacion########
library(SnowballC)
library(corpus)

tabes=read.delim("D:/Maestría/Ciclo IV/Cursos/MCD-402_Análisis EstadisticoTexto/Sesion2/lemmatization-es.txt",encoding="UTF-8",header = FALSE, sep = "",
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


names(noticia2_tidy)[1] <- "term"
noticia2_tidy=noticia2_tidy %>%left_join(tabes, by = "term")
noticia2_tidy$lemma=ifelse(is.na(noticia2_tidy$stem ), noticia2_tidy$term, noticia2_tidy$stem)




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

### TAGGING ejemplo Noticias ###
x_noticia <- udpipe_annotate(ud_model, x = noticia2$noticia2, doc_id = noticia2$ID)
x_noticia <- as.data.frame(x_noticia)

stats <- txt_freq(x_noticia$upos)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = stats, col = "cadetblue", 
         main = "UPOS (Universal Parts of Speech)\n Frecuencia de Ocurrencia", 
         xlab = "Freq")


########### Bag of Words ############3
noticia2_tidy %>% group_by(term) %>% count(term) %>% arrange(desc(n))

## nueva carga
noticia_bow <- readLines("noticia.txt",encoding="UTF-8")

noticia_bow=as.data.frame(noticia_bow)
noticia_bow$ID <- seq.int(nrow(noticia_bow))
noticia_bow <- noticia_bow %>% mutate(texto_tokenizado = map(.x = noticia_bow,
                                                       .f = limpiar_tokenizar))
noticia_bow_tidy <- noticia_bow %>% select(-noticia_bow) %>% unnest()
head(noticia_bow_tidy)


####fecuencia#######
noticia_bow_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  arrange(desc(n))
####frecuencia sin stop words##########
noticia_bow_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>% 
  count(texto_tokenizado)%>% arrange(desc(n))
####graficos1####
noticia_bow_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  filter(n >= 10) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras")+
  geom_col(fill="blue") +
  theme_bw() +
  labs(y = "", x = "") 

####graficos2####
noticia_bow_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>%
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



