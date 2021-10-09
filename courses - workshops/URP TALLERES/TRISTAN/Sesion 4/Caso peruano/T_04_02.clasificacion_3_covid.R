library(dplyr)
library(tidytext)
library(tidyverse)
library(naivebayes)
library(tm)
library(caret)

####comenzar con esta seccion para la clasificacion de comentarios desde este punto
ejercicio_tuits <- read.csv("ejercicio_tuits.csv", stringsAsFactors = F)%>%
  tbl_df

ejercicio_tuits2=ejercicio_tuits[,c(12,2,9)]

#Procesamiento de los datos
#Ffunción para quitar URLs. En los datos todos los URLs han sido acortados, por lo que 
#dificilmente obtendremos información relevante de de ellos por ser series de caracteres
#sin mucho significado.
#La función siguiente usa regexp para detectar palabras que empiecen con "http" y las 
#eliminará.

quitar_url <- function(texto) {
  gsub("\\<http\\S*\\>|[0-9]", " ", texto)
}

names(ejercicio_tuits2)[1] <- "screen_name"
names(ejercicio_tuits2)[2] <- "text"
names(ejercicio_tuits2)[3] <- "status_id"
str(ejercicio_tuits2)

########creacion inicial de la matriz del archivo###################
crear_matriz <- function(tabla) {
  tabla %>%
    mutate(text = quitar_url(text)) %>%
    unnest_tokens(input = "text", output = "palabra") %>%
    count(screen_name, status_id, palabra) %>%
    spread(key = palabra, value = n) %>%
    select(-status_id)
}

ejercicio_tuits3=subset(ejercicio_tuits2, screen_name=="Minsa_Peru" | screen_name=="MininterPeru")

ejemplo_matriz <-
  ejercicio_tuits3 %>%
  mutate(screen_name = as.factor(screen_name)) %>%
  crear_matriz

dim(ejemplo_matriz)


set.seed(123)
fact_entre <- sample(x = 1:nrow(ejemplo_matriz), size = 0.7 * nrow(ejemplo_matriz))
ejemplo_entrenamiento <- ejemplo_matriz[fact_entre, ]
ejemplo_prueba  <- ejemplo_matriz[-fact_entre, ]
######naive bayes sin normalizacion######
ejemplo_modelo <- naive_bayes(formula = screen_name ~ .,  data = ejemplo_entrenamiento)
ejemplo_prediccion <- predict(ejemplo_modelo, ejemplo_prueba)
confusionMatrix(ejemplo_prediccion, ejemplo_prueba$screen_name)

precisiona <- posPredValue(ejemplo_prediccion, ejemplo_prueba$screen_name, positive="MininterPeru")
recalla <- sensitivity(ejemplo_prediccion, ejemplo_prueba$screen_name, positive="MininterPeru")
F1a <- (2 * precisiona * recalla) / (precisiona + recalla)

#####svm con corpus limpio y tdidf#######################
#####creacion de la matriz del archivo con limpieza###############
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

ejercicio_tuits3 <- ejercicio_tuits3 %>% mutate(texto_tokenizado = map(.x = text,
                                                       .f = limpiar_tokenizar))

set.seed(123)
##set.seed(369)
trainl <- sample(x = 1:nrow(ejercicio_tuits3), size = 0.7 * nrow(ejercicio_tuits3))
###particion de la base#######
ejercicio_tuits3_train <- ejercicio_tuits3[trainl, ]
ejercicio_tuits3_test  <- ejercicio_tuits3[-trainl, ]
####proporcion de grupos#####
table(ejercicio_tuits3_train$screen_name) / length(ejercicio_tuits3_train$screen_name)
table(ejercicio_tuits3_test$screen_name) / length(ejercicio_tuits3_test$screen_name)

# Limpieza y tokenización de los documentos de entrenamiento
ejercicio_tuits3_train$text <- ejercicio_tuits3_train$text %>% map(.f = limpiar_tokenizar) %>%
  map(.f = paste, collapse = " ") %>% unlist()

# Creación de la matriz documento-término
library(tidyverse)
library(knitr)
library(quanteda)
library(tm)
sw <- readLines("D:/URP/MATERIAL_CLASES/CURSO_TEXT_MINING/stopwordses.txt",encoding="UTF-8")
matriz_df_train <- dfm(x = ejercicio_tuits3_train$text, remove = sw)
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
ejercicio_tuits3_test$text <- ejercicio_tuits3_test$text %>% map(.f = limpiar_tokenizar) %>%
  map(.f = paste, collapse = " ") %>% unlist()

# Identificación de las dimensiones de la matriz de entrenamiento
# Los objetos dm() son de clase S4, se accede a sus elementos mediante @
dimensiones_tl_matriz_train <- matriz_df_train@Dimnames$features

# Conversión de vector a diccionario pasando por lista
dimensiones_tl_matriz_train <- as.list(dimensiones_tl_matriz_train)
names(dimensiones_tl_matriz_train) <- unlist(dimensiones_tl_matriz_train)
dimensiones_tl_matriz_train <- dictionary(dimensiones_tl_matriz_train)

# Proyección de los documentos de test
matriz_df_test <- dfm(x = ejercicio_tuits3_test$text,
                      dictionary = dimensiones_tl_matriz_train)

matriz_df_test <- dfm_tfidf(matriz_df_test , scheme_tf = "prop",
                            scheme_df = "inverse")

matriz_df_test 

all(colnames(matriz_df_train) == colnames(matriz_df_test))
#####svm normalizado######################
library(e1071)
modelo_tl_svm <- svm(x = matriz_df_train, y = as.factor(ejercicio_tuits3_train$screen_name),
                     kernel = "linear", cost = 1, scale = TRUE,
                     type = "C-classification")
modelo_tl_svm


predicciones_tl <- predict(object = modelo_tl_svm, newdata = matriz_df_test)

tablesvm=table(predicho = predicciones_tl, observado = ejercicio_tuits3_test$screen_name)
tablesvm

ejercicio_tuits3_test$screen_name=as.factor(ejercicio_tuits3_test$screen_name)
confusionMatrix(predicciones_tl, ejercicio_tuits3_test$screen_name)

precisionb <- posPredValue(predicciones_tl, ejercicio_tuits3_test$screen_name, positive="MininterPeru")
recallb <- sensitivity(predicciones_tl, ejercicio_tuits3_test$screen_name, positive="MininterPeru")
F1b <- (2 * precisionb * recallb) / (precisionb + recallb)

######################naive bayes normalizado#########################

library(tidyverse)
library(tidytext)
library(naivebayes)
library(tm)
library(caret)

ejercicio_tuits4=ejercicio_tuits[,c(12,2,9)]
names(ejercicio_tuits4)[1] <- "screen_name"
ejercicio_tuits4=subset(ejercicio_tuits4, screen_name=="Minsa_Peru" | screen_name=="MininterPeru")

head(ejercicio_tuits4)

ejercicio_tuits4$screen_name=as.factor(ejercicio_tuits4$screen_name)

ejercicio_tuits4$text <- str_replace_all(ejercicio_tuits4$text,"http\\S*", "")
ejercicio_tuits4$text <- str_replace_all(ejercicio_tuits4$text,"[\\s]+", " ")
ejercicio_tuits4$text <- chartr('áéíóúñ','aeioun',ejercicio_tuits4$text)

ejercicio_tuits4$text=as.character(ejercicio_tuits4$text)
str(ejercicio_tuits4)

tuits_df_corpus <- VCorpus(VectorSource(ejercicio_tuits4$text))

tuits_df_clean <- tm_map(tuits_df_corpus, tolower)
tuits_df_clean <- tm_map(tuits_df_clean, removeNumbers)
sw <- readLines("D:/URP/MATERIAL_CLASES/CURSO_TEXT_MINING/stopwordses.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
tuits_df_clean <- tm_map(tuits_df_clean, removeWords, stopwords("spanish"))
tuits_df_clean <- tm_map(tuits_df_clean, removeWords, sw)
tuits_df_clean <- tm_map(tuits_df_clean, removePunctuation)
tuits_df_clean <- tm_map(tuits_df_clean, stripWhitespace)
inspect(tuits_df_clean[1:3])
tuits_df_clean <- tm_map(tuits_df_clean, PlainTextDocument)

tuits_df_dtm <- DocumentTermMatrix(tuits_df_clean,control = list(weighting = weightTfIdf))
tuits_df_dtm

set.seed(123)
trainl <- sample(x = 1:nrow(tuits_df_dtm), size = 0.7 * nrow(tuits_df_dtm))

tuits_df_train <- ejercicio_tuits4[trainl, ]
tuits_df_test  <- ejercicio_tuits4[-trainl, ]

tuits_df_corpus_train <- tuits_df_clean[trainl ]
tuits_df_corpus_test  <- tuits_df_clean[-trainl ]

tuits_df_dtm_train <- tuits_df_dtm[trainl, ]
tuits_df_dtm_test  <- tuits_df_dtm[-trainl, ]

prop.table(table(tuits_df_train$screen_name))
prop.table(table(tuits_df_test$screen_name))

tuits_df_dict <- findFreqTerms(tuits_df_dtm_train, 1)

tuits_df_md_train <- DocumentTermMatrix(tuits_df_corpus_train, list(dictionary = tuits_df_dict))
tuits_df_md_test  <- DocumentTermMatrix(tuits_df_corpus_test, list(dictionary = tuits_df_dict))

convert_counts <- function(x) {
  x <- ifelse(x > 0, 1, 0)
  x <- factor(x, levels = c(0, 1), labels = c("No", "Yes"))
}

tuits_df_md_train <- apply(tuits_df_md_train, MARGIN = 2, convert_counts)
tuits_df_md_test  <- apply(tuits_df_md_test, MARGIN = 2, convert_counts)

library(e1071)
library(gmodels)
realtextl2_classifier <- naiveBayes(tuits_df_md_train, tuits_df_train$screen_name)
realtextl2_test_pred <- predict(realtextl2_classifier, tuits_df_md_test)

CrossTable(realtextl2_test_pred,tuits_df_test$screen_name,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

library(caret)
confusionMatrix(realtextl2_test_pred, tuits_df_test$screen_name)

precisionc <- posPredValue(realtextl2_test_pred, tuits_df_test$screen_name, positive="MininterPeru")
recallc <- sensitivity(realtextl2_test_pred, tuits_df_test$screen_name, positive="MininterPeru")
F1c <- (2 * precisionc * recallc) / (precisionc + recallc)

cbind.data.frame(precisiona,precisionb,precisionc)
cbind.data.frame(recalla,recallb,recallc)
cbind.data.frame(F1a,F1b,F1c)
