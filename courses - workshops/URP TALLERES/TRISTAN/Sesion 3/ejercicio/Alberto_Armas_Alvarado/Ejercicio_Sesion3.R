
library(tidyverse)
library(dplyr)
library(tm)


# Cambiar el directorio de trabajo
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


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

sw <- readLines("stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")

###nuevo documento#####
economia <- readLines("economia.txt",encoding="UTF-8")
economia=as.data.frame(economia)
economia$ID <- seq.int(nrow(economia))
economia <- economia %>% mutate(texto_tokenizado = map(.x = economia,
                                                       .f = limpiar_tokenizar))
economia_tidy <- economia %>% select(-economia) %>% unnest(cols = c(texto_tokenizado))
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

library(wordcloud)
library(wordcloud2)

###########nuevo texto####################
economia_wc=economia_tidy %>% group_by(texto_tokenizado) %>% filter(!(texto_tokenizado %in% sw))%>% 
  count(texto_tokenizado)%>% arrange(desc(n))

wordcloud(words = economia_wc$texto_tokenizado, freq = economia_wc$n,
          min.freq = 2, random.order = FALSE, rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))

##########idf2#####################################

total_documentos1 = economia_tidy$ID %>% unique() %>% length()
total_documentos1

economia_tidy = economia_tidy %>% filter(!(texto_tokenizado %in% sw))

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
economia_idf <- economia_idf %>% mutate(idf = log10(total_documentos1/n_documentos) ) %>%
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
