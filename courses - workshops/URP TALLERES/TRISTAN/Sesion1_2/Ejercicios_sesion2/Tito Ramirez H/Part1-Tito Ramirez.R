library(tokenizers)
options(max.print = 25)

# Asignar espacio de trabajo
setwd(readClipboard())

# Cargar-Leer archivo de noticias.txt
noticias <- readLines("noticias.txt",encoding="UTF-8")

#tokenizacion por oraciones
tokenize_sentences(noticias)

#tokenizacion por palabras
tokenize_words(noticias)

#limpieza
library(tm)
corpus <- VCorpus(VectorSource(noticias))
d  <- tm_map(corpus, content_transformer(tolower))
d  <- tm_map(d, stripWhitespace)
d <- tm_map(d, removePunctuation)
d <- tm_map(d,removeNumbers)
d
d[["1"]][["content"]]

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

df.noticias=as.data.frame(noticias)
df.noticias <- df.noticias %>% mutate(texto_tokenizado = map(.x = df.noticias,
                                                             .f = limpiar_tokenizar))

df.noticias %>% select(texto_tokenizado) %>% head()
df.noticias %>% slice(1) %>% select(texto_tokenizado) %>% pull()
df.noticias$ID <- seq.int(nrow(df.noticias))
str(df.noticias)

# Limpieza- Stop Words - Spanish
#palabras por defecto de la libreria
d <- tm_map(d, removeWords, stopwords("spanish"))
d[["1"]][["content"]]

####lista personalizada  1###############
sw <- readLines("stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
d <- tm_map(d, removeWords, sw)
d[["1"]][["content"]]


####lista personalizada  2 
noticias.raw <- df.noticias %>% select(-noticias) %>% unnest()
head(noticias.raw) 

# Se filtran las stopwords
noticias_tidy <- noticias.raw %>% filter(!(texto_tokenizado %in% sw))
head(noticias_tidy) 

#######stemming################
library(pacman)
library(textstem)
dw <- c('terrorismo', 'terrorista')
stem_words(dw)

stem_strings(noticias)

#######lematization################
dw <- c('terrorismo', 'terrorista')
lemmatize_words(dw)

lemmatize_strings(noticias)

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

# text_tokens(noticias, stemmer = stem_liste)

names(noticias_tidy)[1] <- "term"
noticias_tidy=noticias_tidy %>%left_join(tabes, by = "term")
noticias_tidy$lemma=ifelse(is.na(noticias_tidy$stem ), noticias_tidy$term, noticias_tidy$stem)


noticias_tidy %>% group_by(term) %>% count(term)%>% 
  arrange(desc(n))
###nuevo documento#####
noticias.raw %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  filter(n >= 10) %>%arrange(desc(n)) %>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras sin realizar la limpieza") +
  theme(axis.text.x = element_text(angle=90,hjust=1))+
  geom_col(fill="blue") +
  #theme_bw() +
  labs(y = "", x = "") 

####graficos2####
noticias_tidy %>% group_by(term) %>% filter(!(term %in% sw))%>%
  count(term)%>% filter(n >= 5) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(term,n), y = n)) +
  ggtitle("frecuencia de palabras sin stop words")+
  geom_col(fill="red") +
  #theme_bw() +
  theme(axis.text.x = element_text(angle=90,hjust=1))+
  labs(y = "", x = "") 

####TDM##############
d_tdm <- TermDocumentMatrix(d)
d_tdm
m <- as.matrix(d_tdm)
dim(m)
v <- sort(rowSums(m),decreasing=TRUE)
df <- data.frame(word = names(v),freq=v)

####DTM###########
d_dtm <- DocumentTermMatrix(d)
d_dtm
m2 <- as.matrix(d_dtm)
