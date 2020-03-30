# author: Alex Rayón
# date: Marzo, 2020

# Antes de nada, limpiamos el workspace, por si hubiera algún dataset o información cargada
rm(list = ls())

# Cambiar el directorio de trabajo
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Cargamos las librerías que vamos a necesitar
library(tidyverse)
library(recommenderlab)
library(readxl)
library(funModeling)
library(reshape2)
library(ggplot2)
library(plotly)

# Leemos los ratings de los libros
ratings<-read.csv("data/libros/BX-Book-Ratings.csv",sep=";")
libros<-read.csv("data/libros/BX-Books.csv",sep=";")
usuarios<-read.csv("data/libros/BX-Users.csv",sep=";")

# Vamos a cambiar los nombres de columnas
names(ratings)<-c("idUsuario","idLibro","rating")
names(libros)<-c("idLibro","titulo","autor","anyoPublicacion","editorial","imagen1","imagen2","imagen3")
names(usuarios)<-c("idUsuario","ubicacion","edad")

# Vamos a quitar las columnas que no vamos a necesitar
libros$imagen1=NULL
libros$imagen2=NULL
libros$imagen3=NULL

# Vamos a reducir el tamaño de la matriz para poder cargarla 
hist(ratings$rating)
summary(ratings$rating)
# Vamos a quitar primero aquellos que hayan valorado a 0 la película (sí, perdemos información, pero...)
ratings<-ratings[which(ratings$rating>0),]

# Primero vamos a sacar cuántas valoraciones han hecho los usuarios
numValoraciones<- ratings %>% 
  group_by(idUsuario) %>% count() 
hist(numValoraciones$n)
boxplot(numValoraciones$n)

# Y ahora vamos a quitar a usuarios que hayan valorado pocos libros
usuarios_excluidos <- ratings %>% filter(!is.na(rating)) %>%
  group_by(idUsuario) %>% count() %>% filter(n < 5) %>%
  pull(idUsuario)
ratings <- ratings %>% filter(!idUsuario %in% usuarios_excluidos)

unique(ratings$idUsuario)

##################################################################################
##################################################################################
# Estructura de un recomendador
##################################################################################
ratingsmat = dcast(ratings, idUsuario~idLibro, value.var = "rating", na.rm=FALSE)
# Lo convertimos a matriz
ratingsmat = as.matrix(ratingsmat[,-1])

# El paquete en R para hacer recomendaciones es "recommenderlab".
# Para calcular la similaridad entre los ratings, vamos a calcular la similaridad en función de los siguientes
#   métodos: 
#     * Jaccard 
#     * Coseno 
#     * Pearson

# Ahora vamos a reducir el tamaño de la matriz de ratings para hacer que se procese de manera más rápida. 
#   La matriz de ratings ahora mismo, una vez convertida a un objeto "matrix", tiene muchos ceros. Es una
#   matriz dispersa (sparse matrix). Vamos a hacerla densa, para que se procese más rápido. 
ratingsmat = as(ratingsmat, "realRatingMatrix")

# Vamos a crear el modelo de recomendación. Parámetros: 
#   * UBCF --> método
#   * Cosine --> cálculo distancia
#   * nn --> tomamos los 10 vecinos más cercanos
rec_mod = Recommender(ratingsmat, method = "UBCF", param=list(method="Cosine",nn=10))

# Vamos a hacer ahora el modelo de recomendación para el primer usuario: 
top5recomendaciones = predict(rec_mod, ratingsmat[16], n=5)

# Para poder ver las recomendaciones, vamos a convertir las mismas en una lista e imprimirlas en pantalla: 
top5recomendaciones = as(top5recomendaciones, "list")
top5recomendaciones

# Aquí tenemos los códigos de productos: pero, ¿qué productos son? 
# Vamos lo primero de todo a convertir la lista a un dataframe y cambiar el nombre de la columna
top5df=data.frame(top5recomendaciones)
colnames(top5df)="idLibro"

# Mezclamos este dato con el dataframe donde tenemos los detalles de las películas
nombreLibros=left_join(top5df, libros, by="idLibro")
nombreLibros
