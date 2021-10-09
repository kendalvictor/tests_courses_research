#Juan victor Gonzales Montoya

library(tokenizers)
options(max.print = 25)

###############tokenizacion por oraciones#######################
parrafo <- readLines("/home/juanvictor/Documentos/CIENCIA DE DATOS/CICLO IV/Analisis de Estadistico de Texto/Clase 02/Texto",encoding="UTF-8")

tokenize_sentences(parrafo) 

##############tokenizacion por palarbas#################
tokenize_words(parrafo)

##################limpieza##########
####forma 1#######

library(tm)

corpus <- VCorpus(VectorSource(parrafo))
d  <- tm_map(corpus, content_transformer(tolower))
d  <- tm_map(d, stripWhitespace)
d <- tm_map(d, removePunctuation)
d <- tm_map(d,removeNumbers)

d[["3"]][["content"]]
parrafo[[1]]

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

limpiar_tokenizar(texto = parrafo)

parrafo=as.data.frame(parrafo)
parrafo <- parrafo %>% mutate(texto_tokenizado = map(.x = parrafo,
                                                             .f = limpiar_tokenizar))
parrafo %>% select(texto_tokenizado) %>% head()
parrafo %>% slice(1) %>% select(texto_tokenizado) %>% pull()
parrafo$ID <- seq.int(nrow(parrafo))

####################Stop Words#######################
##############ingles#######################
install.packages("stopwords")
library(stopwords)
parrafo <- readLines("/home/juanvictor/Documentos/CIENCIA DE DATOS/CICLO IV/Analisis de Estadistico de Texto/Clase 02/Texto",encoding="UTF-8")
tokenize_words(parrafo)
tokenize_words(parrafo, stopwords = stopwords::stopwords("en"))

length(stopwords(source = "smart"))
length(stopwords(source = "snowball"))
length(stopwords(source = "stopwords-iso"))

stopwords(language = "en", source = "smart")

###########español#####################
####palabras por defecto de la libreria###
d <- tm_map(d, removeWords, stopwords("spanish"))
d[["1"]][["content"]]
####lista personalizada  1###############
sw <- readLines("/home/juanvictor/Documentos/CIENCIA DE DATOS/CICLO IV/Analisis de Estadistico de Texto/Clase 02/stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
d <- tm_map(d, removeWords, sw)
d[["1"]][["content"]]
####lista personalizada  2############
parrafo_tidy <- parrafo %>% select(-parrafo) %>% unnest()
head(parrafo_tidy) 

# Se filtran las stopwords
parrafo_tidy <- parrafo_tidy %>% filter(!(texto_tokenizado %in% sw))
head(parrafo_tidy) 

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

tabes=read.delim("/home/juanvictor/Documentos/CIENCIA DE DATOS/CICLO IV/Analisis de Estadistico de Texto/Clase 02/lemmatization-es.txt",header = FALSE, sep = "",
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


##text <- "los presidentes de las regiones tuvieron que aumentar los dias de cuarentena debido al incremento de nuevos casos"
text <- readLines("/home/juanvictor/Documentos/CIENCIA DE DATOS/CICLO IV/Analisis de Estadistico de Texto/Clase 02/Texto",encoding="UTF-8")

text_tokens(text, stemmer = stem_liste)

names(parrafo_tidy)[1] <- "term"
parrafo_tidy=parrafo_tidy %>%left_join(tabes, by = "term")
parrafo_tidy$lemma=ifelse(is.na(parrafo_tidy$stem ), parrafo_tidy$term, parrafo_tidy$stem)

######tagging#################
install.packages("udpipe")
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
parrafo_tidy %>% group_by(term) %>% count(term)%>% 
  arrange(desc(n))
###nuevo documento#####
economia <- readLines("/home/juanvictor/Documentos/CIENCIA DE DATOS/CICLO IV/Analisis de Estadistico de Texto/Clase 02/Texto",encoding="UTF-8")
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
  filter(n >= 3) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras")+
  geom_col(fill="blue") +
  theme_bw() +
  labs(y = "", x = "") 
####graficos2####
economia_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>%
  count(texto_tokenizado)%>% filter(n >= 2) %>%arrange(desc(n))%>%
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
