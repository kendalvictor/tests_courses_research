library(tokenizers)
options(max.print = 25)

###############tokenizacion por oraciones#######################
base_analisis <- readLines("noticia2.txt", encoding = "UTF-8")
tokenize_sentences(base_analisis)

##############tokenizacion por palarbas#################
tokenize_words(base_analisis)
tokenize_words(base_analisis[[2]])


##################limpieza##########
####forma 1#######

## install.packages("tm")
library(tm)
corpus <- VCorpus(VectorSource(base_analisis))
d  <- tm_map(corpus, content_transformer(tolower))
d  <- tm_map(d, stripWhitespace)
d <- tm_map(d, removePunctuation)
d <- tm_map(d,removeNumbers)

d[["1"]][["content"]]
base_analisis[[1]]

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

#test = "El presidente de Perú, Martin VIZCARRA nació en 1990 en cañete a las 12:00 del mediodia
#       según e'l portal l'limpieza de6 TEXTO  https://t.co/rnHPgyhx4Z usuario tRodrigo #text"

test = base_analisis[[1]]

limpiar_tokenizar(texto = test)

base_analisis=as.data.frame(base_analisis)
base_analisis <- base_analisis %>% mutate(texto_tokenizado = map(.x = base_analisis,
                                                             .f = limpiar_tokenizar))
base_analisis %>% select(texto_tokenizado) %>% head()
base_analisis %>% slice(1) %>% select(texto_tokenizado) %>% pull()
base_analisis$ID <- seq.int(nrow(base_analisis))

####################Stop Words#######################
##############ingles#######################
library(stopwords)
tokenize_words(base_analisis[[1]])
tokenize_words(base_analisis[[1]], stopwords = stopwords::stopwords("en"))

# length(stopwords(source = "smart"))
# length(stopwords(source = "snowball"))
# length(stopwords(source = "stopwords-iso"))
# stopwords(language = "en", source = "smart")

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
base_analisis_tidy <- base_analisis %>% dplyr::select(-base_analisis) %>% unnest()
head(base_analisis_tidy) 

# Se filtran las stopwords
base_analisis_tidy <- base_analisis_tidy %>% filter(!(texto_tokenizado %in% sw))
head(base_analisis_tidy) 











####lemtizacion_español########
#############stemming y lemmantizacion########
library(SnowballC)
## install.packages("corpus")
library(corpus)

tabes=read.delim("lemmatization-es.txt",header = FALSE, sep = "",
                 stringsAsFactors = FALSE ,encoding="UTF-8")
                 
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
text = (base_analisis[[1]])
text_tokens(text, stemmer = stem_liste)

names(base_analisis_tidy)[1] <- "term"
base_analisis_tidy=base_analisis_tidy %>%left_join(tabes, by = "term")
base_analisis_tidy$lemma=ifelse(is.na(base_analisis_tidy$stem ), base_analisis_tidy$term, base_analisis_tidy$stem)
base_analisis_tidy




######tagging#################
ud_model <- udpipe_download_model(language = "spanish")
ud_model <- udpipe_load_model(ud_model$file_model)

### TAGGING ejemplo Noticias ###
base_analisis_02 <- udpipe_annotate(ud_model, x = base_analisis$base_analisis, doc_id = base_analisis$ID)
base_analisis_02 <- as.data.frame(base_analisis_02)


stats <- txt_freq(base_analisis_02$upos)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = stats, col = "cadetblue", 
         main = "UPOS (Universal Parts of Speech)\n Frecuencia de Ocurrencia", 
         xlab = "Freq")




#######Bag of words##############



###nuevo documento#####
base_analisis_03 <- readLines("noticia2.txt", encoding = "UTF-8")
base_analisis_03=as.data.frame(base_analisis_03)
base_analisis_03$ID <- seq.int(nrow(base_analisis_03))
base_analisis_03 <- base_analisis_03 %>% mutate(texto_tokenizado = map(.x = base_analisis_03,
                                                       .f = limpiar_tokenizar))
base_analisis_03_tidy <- base_analisis_03 %>% select(-base_analisis_03) %>% unnest()
head(base_analisis_03_tidy)

#b <- udpipe_annotate(ud_model, x = base_analisis_03_tidy$texto_tokenizado)
#b <- as.data.frame(b)


####fecuencia#######
base_analisis_03_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  arrange(desc(n))
####frecuencia sin stop words##########
base_analisis_03_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>% 
  count(texto_tokenizado)%>% arrange(desc(n))


####graficos1####
base_analisis_03_tidy %>% group_by(texto_tokenizado) %>% count(texto_tokenizado)%>% 
  filter(n >= 10) %>%arrange(desc(n))%>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("frecuencia de palabras")+
  geom_col(fill="blue") +
  theme_bw() +
  labs(y = "", x = "") 
####graficos2####
base_analisis_03_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>%
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





