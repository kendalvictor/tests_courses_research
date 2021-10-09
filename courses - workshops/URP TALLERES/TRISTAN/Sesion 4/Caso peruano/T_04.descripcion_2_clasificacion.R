library(tidyverse)
library(tidytext)
library(naivebayes)
library(tm)
library(caret)
library(dplyr)

ejercicio_tuits <- read.csv("ejercicio_tuits.csv")
View(ejercicio_tuits)

ejercicio_tuits2=ejercicio_tuits[,c(1,2,6,12)]
###tabla por screnn_name###
table(ejercicio_tuits2$screenName)

names(ejercicio_tuits2)[1] <- "ID"
names(ejercicio_tuits2)[2] <- "TEXTO"
names(ejercicio_tuits2)[3] <- "FECHA"
names(ejercicio_tuits2)[4] <- "AUTOR"

str(ejercicio_tuits2)

ejercicio_tuits2$FECHA=as.Date(ejercicio_tuits2$FECHA)
ejercicio_tuits2$TEXTO=as.character(ejercicio_tuits2$TEXTO)

####descripcion#####
######frecuencias########
ejercicio_tuits2 %>% group_by(AUTOR) %>% summarise(numero_label = n())

ejercicio_tuits2 %>%  ggplot(aes(x = AUTOR,fill=AUTOR)) + geom_bar() + coord_flip() + 
  labs(x="Autor")+labs(y="Cantidad de tuits")+
  ggtitle("Cantidad de tuits por autor")+theme_bw()+theme(legend.position = "none")

######frecuencias por fecha########
library(lubridate)

ggplot(ejercicio_tuits2, aes(x = as.Date(FECHA), fill = AUTOR)) +
  geom_histogram(position = "identity", bins = 20, show.legend = FALSE) +
  labs(x = "fecha de publicación", y = "número de tweets") +
  facet_wrap(~ AUTOR, ncol = 1) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90))


######limpieza y tokenizacion de las palabras##############
##seleccion de columnas
ejercicio_tuits2 <- ejercicio_tuits2 %>% select(AUTOR, ID,TEXTO)
##limpieza##
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

ejercicio_tuits2 <- ejercicio_tuits2 %>% mutate(texto_tokenizado = map(.x = TEXTO,
                                                   .f = limpiar_tokenizar))
ejercicio_tuits2 %>% select(texto_tokenizado) %>% head()

###vista previa del tuits 100##
ejercicio_tuits2 %>% slice(100) %>% select(texto_tokenizado) %>% pull()

###transformacion del archivo##
tweets_tidy <- ejercicio_tuits2 %>% select(-TEXTO) %>% unnest()
tweets_tidy <- tweets_tidy %>% rename(token = texto_tokenizado)
###se creo la matriz donde cada palabra de cada tuit sera una fila
head(tweets_tidy) 
####total de palabras usadas por autor
tweets_tidy %>% group_by(AUTOR) %>% summarise(n = n()) 
library(plotly)
tweets_tidy %>% ggplot(aes(x = AUTOR,fill=AUTOR)) + geom_bar() + coord_flip() + theme_bw()
ggplotly(tweets_tidy %>% ggplot(aes(x = AUTOR,fill=AUTOR)) + geom_bar() + coord_flip() + theme_bw())

####longitud media por tuits#########
tweets_tidy %>% group_by(AUTOR, ID) %>% summarise(longitud = n()) %>%                       
  group_by(AUTOR) %>% summarise(media_longitud = mean(longitud),
                                sd_longitud = sd(longitud))

tweets_tidy %>% group_by(AUTOR, ID) %>% summarise(longitud = n()) %>%                      
  group_by(AUTOR) %>%
  summarise(media_longitud = mean(longitud),
            sd_longitud = sd(longitud)) %>%
  ggplot(aes(x = AUTOR, y = media_longitud,fill=AUTOR)) +
  geom_col() +
  geom_errorbar(aes(ymin = media_longitud - sd_longitud,
                    ymax = media_longitud + sd_longitud)) +
  coord_flip() + theme_bw()

####palabras mas usadas por autor###
tweets_tidy %>% group_by(AUTOR, token) %>% count(token) %>% group_by(AUTOR) %>%
  top_n(8, n) %>% arrange(AUTOR, desc(n)) %>% print(n=40)

# Se filtran las stopwords
sw <- readLines("D:/URP/MATERIAL_CLASES/CURSO_TEXT_MINING/stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
tweets_tidy <- tweets_tidy %>% filter(!(token %in% sw))

####palabras mas usadas por autor###
tweets_tidy %>% group_by(AUTOR, token) %>% count(token) %>% group_by(AUTOR) %>%
  top_n(8, n) %>% arrange(AUTOR, desc(n)) %>% print(n=40)

###grafica por palabras mas usadas por autor###
tweets_tidy %>% group_by(AUTOR, token) %>% count(token) %>% group_by(AUTOR) %>%
  top_n(5, n) %>% arrange(AUTOR, desc(n)) %>%
  ggplot(aes(x = reorder(token,n), y = n, fill = AUTOR)) +
  geom_col() +
  theme_bw() +
  labs(y = "", x = "") +
  theme(legend.position = "none") +
  coord_flip() +
  facet_wrap(~AUTOR,scales = "free", ncol = 1, drop = TRUE)

#####word cloud: frecuencia de palabras####
library(wordcloud)
library(RColorBrewer)
library(wordcloud2)
###tabla de frecuencias por autor##
tabla_autor=tweets_tidy %>% group_by(AUTOR, token) %>% count(token) %>% group_by(AUTOR)%>%
  arrange(AUTOR, desc(n))
##tabla de MINISTERIO DE SALUD##
tabla_autor_DU=tabla_autor%>% filter((AUTOR %in% "DanielUrresti1"))
tabla_autor_DU=tabla_autor_DU[,2:3]
tabla_autor_DU=subset(tabla_autor_DU, n>4)
##nube de palabras CMLL_OFICIAL##
wordcloud2(tabla_autor_DU, fontFamily = "serif", 
           backgroundColor = "white", shape = 'pentagon', size = 0.4)
###palabras comunes###
palabras_comunes <- dplyr::intersect(tweets_tidy %>% filter(AUTOR=="Minsa_Peru") %>%
                                       select(token), tweets_tidy %>% filter(AUTOR=="MininterPeru") %>%
                                       select(token)) %>% nrow()
paste("Número de palabras comunes entre MINSA y MININTER", palabras_comunes)

######grafico de piramide####################
t_MIN=tweets_tidy %>% group_by(AUTOR, token) %>% count(token) %>% group_by(AUTOR)%>%
  arrange(AUTOR, desc(n))%>% filter(AUTOR=="Minsa_Peru")


t_MININ=tweets_tidy %>% group_by(AUTOR, token) %>% count(token) %>% group_by(AUTOR)%>%
  arrange(AUTOR, desc(n))%>% filter(AUTOR=="MininterPeru")

w_comunes=inner_join(t_MIN, t_MININ, by = "token")
w_comunes=w_comunes%>%select(token,n.x,n.y)
#w_comunes=w_comunes[,2:4]
names(w_comunes)[2]="Minsa_Peru"
names(w_comunes)[3]="MininterPeru"

library(plotrix)

tail(w_comunes)
w_comunes$diferen=w_comunes$Minsa_Peru - w_comunes$MininterPeru
top25=head(w_comunes,25)

pyramid.plot(top25$Minsa_Peru,top25$MininterPeru,labels=top25$token,
             gap=14,top.labels = c("MINSA","token","MININTER"),
             main ="Palabras en comun",laxlab = NULL, raxlab = NULL,
             unit= NULL)

###bigramas###

limpiar <- function(texto){
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
  return(nuevo_texto)
}

bigramas <- ejercicio_tuits2 %>% mutate(TEXTO = limpiar(TEXTO)) %>%
  select(TEXTO) %>%
  unnest_tokens(input = TEXTO, output = "bigrama",
                token = "ngrams",n = 2, drop = TRUE)

# Contaje de ocurrencias de cada bigrama
bigramas  %>% count(bigrama, sort = TRUE)

# Separación de los bigramas 
bigrams_separados <- bigramas %>% separate(bigrama, c("palabra1", "palabra2"),
                                           sep = " ")
head(bigrams_separados)

# Filtrado de los bigramas que contienen alguna stopword
bigrams_separados <- bigrams_separados  %>%
  filter(!palabra1 %in% sw) %>%
  filter(!palabra2 %in% sw)

# Unión de las palabras para formar de nuevo los bigramas
bigramas <- bigrams_separados %>%
  unite(bigrama, palabra1, palabra2, sep = " ")

# Nuevo contaje para identificar los bigramas más frecuentes
bigramas  %>% count(bigrama, sort = TRUE) ##%>% print(n = 20)

library(igraph)
library(ggraph)
library(tidygraph)

graph <- bigramas %>%
  separate(bigrama, c("palabra1", "palabra2"), sep = " ") %>% 
  count(palabra1, palabra2, sort = TRUE) %>%
  filter(n > 5) %>% graph_from_data_frame(directed = FALSE)

set.seed(123)

plot(graph, vertex.label.font = 2,
     vertex.label.color = "black",
     vertex.label.cex = 0.7, edge.color = "gray85")
