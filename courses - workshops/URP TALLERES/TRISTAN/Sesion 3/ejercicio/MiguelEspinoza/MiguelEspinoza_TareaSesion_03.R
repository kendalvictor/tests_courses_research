
#################################################################################
## Librerias
#################################################################################

library(tokenizers)
library(tidyverse)
library(dplyr)
library(tm)
library(wordcloud)
library(wordcloud2)

options(max.print = 25)



#################################################################################
## Funcion
#################################################################################

limpiar_tokenizar <- function(texto){
  # El orden de la limpieza no es arbitrario
  # Se convierte todo el texto a min?sculas
  nuevo_texto <- tolower(texto)
  # Eliminaci?n de p?ginas web (palabras que empiezan por "http." seguidas 
  # de cualquier cosa que no sea un espacio)
  nuevo_texto <- str_replace_all(nuevo_texto,"http\\S*", "")
  # Eliminaci?n de signos de puntuaci?n
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:punct:]]", " ")
  # Eliminaci?n de n?meros
  nuevo_texto <- str_replace_all(nuevo_texto,"[[:digit:]]", " ")
  # Eliminaci?n de espacios en blanco m?ltiples
  nuevo_texto <- str_replace_all(nuevo_texto,"[\\s]+", " ")
  # Eliminacion de tildes
  nuevo_texto <- chartr('??????','aeioun',nuevo_texto)
  # Tokenizaci?n por palabras individuales
  nuevo_texto <- str_split(nuevo_texto, " ")[[1]]
  # Eliminaci?n de tokens con una longitud < 2
  nuevo_texto <- keep(.x = nuevo_texto, .p = function(x){str_length(x) > 1})
  return(nuevo_texto)
}


#################################################################################
## StopWord
#################################################################################

sw <- readLines("stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")



#################################################################################
## Documento Analisis - Economia
#################################################################################

economia = readLines("economia.txt",encoding="UTF-8")
economia = as.data.frame(economia)
economia$ID = seq.int(nrow(economia))
economia    = economia %>% mutate(texto_tokenizado = map(.x = economia,
                                                         .f = limpiar_tokenizar))
economia_tidy = economia %>% select(-economia) %>% unnest()
head(economia_tidy)
 


## Frecuencia
economia_tidy %>% 
  group_by(texto_tokenizado) %>% 
  count(texto_tokenizado) %>% 
  arrange(desc(n))

## Frecuencia - Sin considerar StopWord
economia_tidy %>% 
  group_by(texto_tokenizado) %>% 
  filter(!(texto_tokenizado %in% sw)) %>%  ## Filtro de StopWord
  count(texto_tokenizado) %>% 
  arrange(desc(n))

## Grafico 1 - 
economia_tidy %>% 
  group_by(texto_tokenizado) %>% 
  count(texto_tokenizado) %>% 
  filter(n >= 10) %>%arrange(desc(n)) %>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
                 ggtitle("Frecuencia de palabras")+
                 geom_col(fill="blue") +
                  theme_bw() +
                  labs(y = "", x = "") 


## Grafico 2 -
economia_tidy %>% 
  group_by(texto_tokenizado) %>% 
  filter(!(texto_tokenizado %in% sw)) %>%
  count(texto_tokenizado) %>% 
  filter(n >= 5) %>%
  arrange(desc(n)) %>%
  ggplot(aes(x = reorder(texto_tokenizado,n), y = n)) +
  ggtitle("Frecuencia de palabras sin stop words")+
  geom_col(fill="red") +
  theme_bw() +
  labs(y = "", x = "") 






#################################################################################
## Nuevo Texto
#################################################################################
economia_wc = 
  economia_tidy %>% 
  group_by(texto_tokenizado) %>% 
  filter(!(texto_tokenizado %in% sw))%>% 
  count(texto_tokenizado)%>% 
  arrange(desc(n))

wordcloud(words = economia_wc$texto_tokenizado, 
          freq  = economia_wc$n,
          min.freq = 2, 
          random.order = FALSE, 
          rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))



#################################################################################
## IDF2
#################################################################################
total_documentos1 = 
  economia_tidy$ID %>% 
  unique() %>% 
  length()

total_documentos1

 
 
## NUmero de veces que aparece cada tErmino por tweet
names(economia_tidy)[2] <- "term"
economia_tf = 
  economia_tidy %>% 
  group_by(ID,term) %>% 
  summarise(n = n())

# Se anade una columna con el total de terminos por tweet
economia_tf = 
  economia_tf %>% 
  mutate(total_n = sum(n))

economia_tf =  
  economia_tf %>% 
  mutate(tf = n / total_n )

head(economia_tf)

# Numero de documentos en los que aparece cada termino
names(economia_tidy)[2] <- "term"
economia_idf=economia_tidy %>% 
  distinct(term, ID) %>% 
  group_by(term) %>%
  summarise(n_documentos = n())

# Calculo del idf
economia_idf = 
  economia_idf %>% 
  mutate(idf = log10(total_documentos1/n_documentos) ) %>%
  arrange(desc(idf))

head(economia_idf)


# tfidf
economia_tf_idf = 
  left_join(x = economia_tf, y = economia_idf, by = "term") %>% 
  ungroup()

economia_tf_idf = 
  economia_tf_idf %>% 
  mutate(tf_idf = tf * idf)

head(economia_tf_idf)

economia_tf_idwc =
  economia_tf_idf %>% 
  group_by(term) %>%
  summarise(zu = sum(tf_idf))

wordcloud(words = economia_tf_idwc$term, 
          freq = economia_tf_idwc$zu,
          random.order = FALSE, 
          rot.per = 0.35,
          colors = brewer.pal(8, "Dark2"))


