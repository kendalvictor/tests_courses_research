library(tidyverse)
library(tidytext)
library(naivebayes)
library(tm)
library(caret)
library(dplyr)

#Usaremos un conjunto de datos sencillo de Twitter, que consta de 1349 tuits acompañados 
#de su nombre de usuario e identificador de tuit. Estos tuits fueron obtenidos el 9 de Abril
#del 2018.
#Nuestro objetivo será determinar si un tuit en particular fue hecho por un usuario 
#específico o no, a partir de su contenido. Los datos que usaremos contienen tuits que 
#pertenecen a cuatro cuentas, mezclados con tuits de multiples usuarios.
#@lopezobrador - Andrés Manuel Lopez Obrador, candidato a la presidencia de México.
#@UNAM_MX - Universidad Nacional Autónoma de México, cuenta institucional.
#@CMLL_OFICIAL - Consejo Mundial de Lucha Libre, promoción de lucha libre de México.
#@MSFTMexico - Microsoft México, cuenta corporativa.
#Además, veremos cómo podemos sistematizar la implementación de este algoritmo en R.

#download.file(url = "https://raw.githubusercontent.com/jboscomendoza/rpubs/master/bayes_twitter/tuits_bayes.csv", destfile = "tuits.csv")


###carga de los tuits###
tuits_df_descrip =
  read.csv("tuits.csv", stringsAsFactors = F, fileEncoding = "latin1") %>%
  tbl_df

tuits_df_descrip$ID <- seq.int(nrow(tuits_df_descrip))

###tabla por screnn_name###
ta=as.data.frame(table(tuits_df_descrip$screen_name))
###creacion de 5 etiquetas###
tuits_df_descrip$autor=ifelse(tuits_df_descrip$screen_name == "MSFTMexico"|
                              tuits_df_descrip$screen_name == "lopezobrador_"|
                              tuits_df_descrip$screen_name == "UNAM_MX"|
                              tuits_df_descrip$screen_name == "CMLL_OFICIAL",
                              tuits_df_descrip$screen_name, "Otro")
###tabla por autor#####
table(tuits_df_descrip$autor)

####vista preliminar#####
head(tuits_df_descrip)

######frecuencias########
tuits_df_descrip %>% group_by(autor) %>% summarise(numero_label = n())

tuits_df_descrip %>%  ggplot(aes(x = autor,fill=autor)) + geom_bar() + coord_flip() + 
  labs(x="Autor")+labs(y="Cantidad de tuits")+
  ggtitle("Cantidad de tuits por autor")+theme_bw()+theme(legend.position = "none")

######limpieza y tokenizacion de las palabras##############
##seleccion de columnas
tweets <- tuits_df_descrip %>% select(autor, ID,text)
tweets <- tweets %>% rename(texto = text)
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

tweets <- tweets %>% mutate(texto_tokenizado = map(.x = texto,
                                                   .f = limpiar_tokenizar))
tweets %>% select(texto_tokenizado) %>% head()

###vista previa del tuits 100##
tweets %>% slice(100) %>% select(texto_tokenizado) %>% pull()
###transformacion del archivo##
tweets_tidy <- tweets %>% select(-texto) %>% unnest()
tweets_tidy <- tweets_tidy %>% rename(token = texto_tokenizado)
###se creo la matriz donde cada palabra de cada tuit sera una fila
head(tweets_tidy) 
####total de palabras usadas por autor
tweets_tidy %>% group_by(autor) %>% summarise(n = n()) 
library(plotly)
tweets_tidy %>% ggplot(aes(x = autor,fill=autor)) + geom_bar() + coord_flip() + theme_bw()
ggplotly(tweets_tidy %>% ggplot(aes(x = autor,fill=autor)) + geom_bar() + coord_flip() + theme_bw())
####longitud media por tuits#########
tweets_tidy %>% group_by(autor, ID) %>% summarise(longitud = n()) %>%                       
  group_by(autor) %>% summarise(media_longitud = mean(longitud),
                      sd_longitud = sd(longitud))

tweets_tidy %>% group_by(autor, ID) %>% summarise(longitud = n()) %>%                      
  group_by(autor) %>%
  summarise(media_longitud = mean(longitud),
            sd_longitud = sd(longitud)) %>%
  ggplot(aes(x = autor, y = media_longitud,fill=autor)) +
  geom_col() +
  geom_errorbar(aes(ymin = media_longitud - sd_longitud,
                    ymax = media_longitud + sd_longitud)) +
  coord_flip() + theme_bw()

####palabras mas usadas por autor###
tweets_tidy %>% group_by(autor, token) %>% count(token) %>% group_by(autor) %>%
  top_n(8, n) %>% arrange(autor, desc(n)) %>% print(n=40)

# Se filtran las stopwords
sw <- readLines("D:/URP/MATERIAL_CLASES/CURSO_TEXT_MINING/stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
tweets_tidy <- tweets_tidy %>% filter(!(token %in% sw))

####palabras mas usadas por autor###
tweets_tidy %>% group_by(autor, token) %>% count(token) %>% group_by(autor) %>%
  top_n(8, n) %>% arrange(autor, desc(n)) %>% print(n=40)

###grafica por palabras mas usadas por autor###

tweets_tidy %>% group_by(autor, token) %>% count(token) %>% group_by(autor) %>%
  top_n(5, n) %>% arrange(autor, desc(n)) %>%
  ggplot(aes(x = reorder(token,n), y = n, fill = autor)) +
  geom_col() +
  theme_bw() +
  labs(y = "", x = "") +
  theme(legend.position = "none") +
  coord_flip() +
  facet_wrap(~autor,scales = "free", ncol = 1, drop = TRUE)

#####word cloud: frecuencia de palabras####
library(wordcloud)
library(RColorBrewer)
library(wordcloud2)
###tabla de frecuencias por autor##
tabla_autor=tweets_tidy %>% group_by(autor, token) %>% count(token) %>% group_by(autor)%>%
             arrange(autor, desc(n))
##tabla de CMLL OFICIAL##
tablar_autor_CMLL_OFICIAL=tabla_autor%>% filter((autor %in% "CMLL_OFICIAL"))
tablar_autor_CMLL_OFICIAL=tablar_autor_CMLL_OFICIAL[,2:3]
tablar_autor_CMLL_OFICIAL=subset(tablar_autor_CMLL_OFICIAL, n>6)
##nube de palabras CMLL_OFICIAL##
wordcloud2(tablar_autor_CMLL_OFICIAL, fontFamily = "serif", 
           backgroundColor = "white", shape = 'star', size = 0.8)
###palabras comunes###
palabras_comunes <- dplyr::intersect(tweets_tidy %>% filter(autor=="lopezobrador_") %>%
                           select(token), tweets_tidy %>% filter(autor=="UNAM_MX") %>%
                           select(token)) %>% nrow()
paste("Número de palabras comunes entre Lopez Obrador y UNAM_MX", palabras_comunes)
######grafico de piramide####################
t_lo=tweets_tidy %>% group_by(autor, token) %>% count(token) %>% group_by(autor)%>%
  arrange(autor, desc(n))%>% filter(autor=="lopezobrador_")


t_UNAM=tweets_tidy %>% group_by(autor, token) %>% count(token) %>% group_by(autor)%>%
  arrange(autor, desc(n))%>% filter(autor=="UNAM_MX")

w_comunes=inner_join(t_lo, t_UNAM, by = "token")
w_comunes=w_comunes%>%select(token,n.x,n.y)
w_comunes=w_comunes[,2:4]
names(w_comunes)[2]="lopezobrador_"
names(w_comunes)[3]="UNAM_MX"

library(plotrix)
tail(w_comunes)
w_comunes$diferen=w_comunes$lopezobrador_ - w_comunes$UNAM_MX
top25=head(w_comunes,25)

pyramid.plot(top25$lopezobrador_,top25$UNAM_MX,labels=top25$token,
             gap=14,top.labels = c("lopezobrador_","token","UNAM_MX"),
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

library(tidytext)

bigramas <- tweets %>% mutate(texto = limpiar(texto)) %>%
  select(texto) %>%
  unnest_tokens(input = texto, output = "bigrama",
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
bigramas  %>% count(bigrama, sort = TRUE) %>% print(n = 20)

library(igraph)
library(ggraph)
library(tidygraph)
graph <- bigramas %>%
  separate(bigrama, c("palabra1", "palabra2"), sep = " ") %>% 
  count(palabra1, palabra2, sort = TRUE) %>%
  filter(n > 10) %>% graph_from_data_frame(directed = FALSE)
set.seed(123)

plot(graph, vertex.label.font = 2,
     vertex.label.color = "black",
     vertex.label.cex = 0.7, edge.color = "gray85")



