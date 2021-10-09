library(tidyverse)
library(tidytext)
library(naivebayes)
library(tm)
library(caret)

#Revisaremos como implementar Naïve Bayes (clasificador Bayesiano ingenuo) para clasificar
#texto usando R. 
#Naïve Bayes es un algoritmo de aprendizaje automático basado en el teorema de Bayes que 
#aunque es sencillo de implementar, nos otorga buenos resultados.

#download.file(url = "https://raw.githubusercontent.com/jboscomendoza/rpubs/master/bayes_twitter/tuits_bayes.csv", destfile = "tuits.csv")

tuits_df =
  read.csv("tuits.csv", stringsAsFactors = F, fileEncoding = "latin1") %>%
  tbl_df

#Procesamiento de los datos
#Ffunción para quitar URLs. En los datos todos los URLs han sido acortados, por lo que 
#dificilmente obtendremos información relevante de de ellos por ser series de caracteres
#sin mucho significado.
#La función siguiente usa regexp para detectar palabras que empiecen con "http" y las 
#eliminará.

quitar_url <- function(texto) {
  gsub("\\<http\\S*\\>|[0-9]", " ", texto)
}

###vista previa del archivo
tuits_df
##cantidad de usuarios del archivo
a=as.data.frame(table(tuits_df$screen_name))
a

tuits_df %>%
  unnest_tokens(input = "text", output = "palabra") %>%
  count(screen_name, status_id, palabra) %>%
  spread(key = palabra, value = n)

########creacion inicial de la matriz del archivo###################
crear_matriz <- function(tabla) {
  tabla %>%
    mutate(text = quitar_url(text)) %>%
    unnest_tokens(input = "text", output = "palabra") %>%
    count(screen_name, status_id, palabra) %>%
    spread(key = palabra, value = n) %>%
    select(-status_id)
}

ejemplo_matriz <-
  tuits_df %>%
  mutate(screen_name = ifelse(screen_name == "MSFTMexico", screen_name, "Otro"),
         screen_name = as.factor(screen_name)) %>%
  crear_matriz

dim(ejemplo_matriz)
ejemplo_matriz[234:240,450:455]

#write.table(ejemplo_matriz,"matriz.txt")

set.seed(123)
fact_entre <- sample(x = 1:nrow(ejemplo_matriz), size = 0.7 * nrow(ejemplo_matriz))
ejemplo_entrenamiento <- ejemplo_matriz[fact_entre, ]
ejemplo_prueba  <- ejemplo_matriz[-fact_entre, ]

#library(caTools)
#split <- sample.split(ejemplo_matriz$screen_name, SplitRatio = 0.70)
#ejemplo_entrenamiento <- subset(ejemplo_matriz, split == TRUE)
#ejemplo_prueba <- subset(ejemplo_matriz, split == FALSE)


ejemplo_modelo <- naive_bayes(formula = screen_name ~ .,  data = ejemplo_entrenamiento)
ejemplo_prediccion <- predict(ejemplo_modelo, ejemplo_prueba)
confusionMatrix(ejemplo_prediccion, ejemplo_prueba$screen_name)

library(vcd)
tabla_t=table(ejemplo_prueba$screen_name,ejemplo_prediccion,dnn = c("observaciones", "predicciones"))
mosaic(tabla_t, shade = T, colorize = T,
       gp = gpar(fill = matrix(c("green3", "red2", "red2", "green3"), 2, 2)))

#####svm con corpus limpio y tdidf#######################
#####creacion de la matriz del archivo con limpieza###############
tuits_df$text=as.character(tuits_df$text)

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

tuits_df <- tuits_df %>% mutate(texto_tokenizado = map(.x = text,
                                                       .f = limpiar_tokenizar))

tuits_df$screen_name2=ifelse(tuits_df$screen_name == "MSFTMexico", tuits_df$screen_name, "Otro")
set.seed(123)
##set.seed(369)
trainl <- sample(x = 1:nrow(tuits_df), size = 0.7 * nrow(tuits_df))
tuits_df_train <- tuits_df[trainl, ]
str(tuits_df_train)
tuits_df_test  <- tuits_df[-trainl, ]

table(tuits_df_train$screen_name2) / length(tuits_df_train$screen_name2)

table(tuits_df_test$screen_name2) / length(tuits_df_test$screen_name2)

# Limpieza y tokenización de los documentos de entrenamiento
tuits_df_train$text <- tuits_df_train$text %>% map(.f = limpiar_tokenizar) %>%
  map(.f = paste, collapse = " ") %>% unlist()

# Creación de la matriz documento-término
library(tidyverse)
library(knitr)
library(quanteda)
library(tm)
sw <- readLines("D:/URP/MATERIAL_CLASES/CURSO_TEXT_MINING/stopwordses.txt",encoding="UTF-8")
matriz_df_train <- dfm(x = tuits_df_train$text, remove = sw)
dim(matriz_df_train)
# Se reduce la dimensión de la matriz eliminando aquellos términos que 
# aparecen en menos de 2 documentos. Con esto se consigue eliminar ruido.
matriz_df_train <- dfm_trim(x = matriz_df_train, min_docfreq = 2)
dim(matriz_df_train)

# Conversión de los valores de la matriz a tf-idf
matriz_df_train <- dfm_tfidf(matriz_df_train, scheme_tf = "prop",
                               scheme_df = "inverse")

matriz_df_train

# Limpieza y tokenización de los documentos de test
tuits_df_test$text <- tuits_df_test $text %>% map(.f = limpiar_tokenizar) %>%
  map(.f = paste, collapse = " ") %>% unlist()

# Identificación de las dimensiones de la matriz de entrenamiento
# Los objetos dm() son de clase S4, se accede a sus elementos mediante @
dimensiones_tl_matriz_train <- matriz_df_train@Dimnames$features

# Conversión de vector a diccionario pasando por lista
dimensiones_tl_matriz_train <- as.list(dimensiones_tl_matriz_train)
names(dimensiones_tl_matriz_train) <- unlist(dimensiones_tl_matriz_train)
dimensiones_tl_matriz_train <- dictionary(dimensiones_tl_matriz_train)

# Proyección de los documentos de test
matriz_df_test <- dfm(x = tuits_df_test$text,
                            dictionary = dimensiones_tl_matriz_train)

matriz_df_test <- dfm_tfidf(matriz_df_test , scheme_tf = "prop",
                              scheme_df = "inverse")

matriz_df_test 

all(colnames(matriz_df_train) == colnames(matriz_df_test))


library(e1071)
modelo_tl_svm <- svm(x = matriz_df_train, y = as.factor(tuits_df_train$screen_name2),
                     kernel = "linear", cost = 1, scale = TRUE,
                     type = "C-classification")
modelo_tl_svm


predicciones_tl <- predict(object = modelo_tl_svm, newdata = matriz_df_test)

tablesvm=table(predicho = predicciones_tl, observado = tuits_df_test$screen_name2)
tablesvm

tuits_df_test$screen_name2=as.factor(tuits_df_test$screen_name2)
confusionMatrix(predicciones_tl, tuits_df_test$screen_name2)

