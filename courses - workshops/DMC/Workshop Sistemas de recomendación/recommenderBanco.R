# author: Alex Rayón
# last modified: Noviembre, 2019

# Antes de nada, limpiamos el workspace, por si hubiera algún dataset o información cargada
rm(list = ls())

# Cambiar el directorio de trabajo
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Vamos a cargar las librerías que vamos a necesitar
library(recommenderlab)
library(clusterSim)

# Vamos a cargar los datos
activos<-read.csv("data/activos.csv")

####################################################################################################
# SISTEMA DE RECOMENDACIÓN
####################################################################################################
# ¿Por qué planteamos un Sistema de Recomendación?
# ¿Qué nos puede aportar?

# 1.Filtrado colaborativo para Recomendación 
###################################################################################
#   1.A. Item-based Collaborative Filtering (IBCF)
###################################################################################
# Cogemos solo los productos del banco para un filtrado item-a-item
bank.recom<-activos[,21:28]
summary(bank.recom)

# Nos creamos una función para calcular el coseno entre los dos vectores
#   De esta manera calculamos la "distancia": una forma de medir la disimilitud entre los ítems
calculoCoseno <- function(x,y){
  coseno <- sum(x*y) / (sqrt(sum(x*x)) * sqrt(sum(y*y)))
  return(coseno)
}

# Nos creamos la matriz de item-to-item
clientes <- matrix(NA, 
                 nrow=ncol(bank.recom),
                 ncol=ncol(bank.recom),
                 dimnames=list(colnames(bank.recom),colnames(bank.recom)))
similaridad <- as.data.frame(clientes)

# Calculamos la similaridad del coseno para esta matriz
for(i in 1:ncol(bank.recom)) {
  for(j in 1:ncol(bank.recom)) {
    similaridad[i,j]= calculoCoseno(bank.recom[i],bank.recom[j])
  }
}
# Lo convertimos a un dataframe
similaridad <- as.data.frame(similaridad)
head(similaridad)

# Cogemos los dos vecinos más cercanos para cada producto
#   ¿Por qué solo 2? Porque necesito solo recomendar un producto a cada usuario
vecinos <- matrix(NA, nrow=ncol(similaridad),ncol=2,dimnames=list(colnames(similaridad)))

# Y ahora localizamos a los vecinos
for(i in 1:ncol(bank.recom)){
  vecinos[i,] <- (t(head(n=2,rownames(similaridad[order(similaridad[,i],decreasing=TRUE),][i]))))
}
head(vecinos, n=8) #  Naturalmente, cada producto, será muy parecido a sí mismo

# Los productos a recomendar para cada usuario
recomendacionFinal<-cbind(activos[,1],vecinos[,2])

# Vamos a ver los productos a recomendar para los primeros 10 usuarios
colnames(recomendacionFinal)<-c("idCliente", "productoRecomendar")
head(recomendacionFinal, n=10)


###################################################################################
# 1.B. User-Based CF approach (UBCF)
###################################################################################
# En este caso, necesito tanto el código del cliente como los "ratings" de productos
bank.recomd<-cbind(activos[,1], activos[21:28])
colnames(bank.recomd)[1]<-"cliente"

# Dado que solo queremos ver cómo funciona, y dado que el UBCF es bastante "intenso", vamos 
#   a coger solo 5.000 clientes para probar
bank.recomd<-bank.recomd[1:5000,]
bank.recomd$cliente <- as.numeric(factor(bank.recomd$cliente))

# Transformamos para preparar la matriz
bank.reshaped <- transform(melt(bank.recomd, 
                                id.var='cliente', 
                                na.rm=TRUE), 
                              variable=match(variable, names(bank.recomd)[-1]))
head(bank.reshaped)

# Lo preparamos como una sparseMatrix
sparse_ratings<-with(bank.reshaped, sparseMatrix(cliente, variable, x=value)) 

# El paquete recommenderlab trabaja con objetos de tipo realRatingMatrix
real_ratings <- new("realRatingMatrix", data = sparse_ratings)
head(as(real_ratings, "matrix"))

# Creamos un modelo de recomendación sobre la base del rating de usuarios
bank.rec<-Recommender(real_ratings, method="UBCF", param=list(normalize = "center"))
getModel(bank.rec)

# Partimos los datos para hacer recomendaciones
set.seed(1)
e <- evaluationScheme(real_ratings, method="split", train=0.8, given=3)

# Predecir recomendaciones
bank.pred<-predict(bank.rec, getData(e, "known"), type="ratings", n=1)
head(as(bank.pred, "matrix"), n=10)

# Partimos los datos para construir el modelo
set.seed(1)
e <- evaluationScheme(real_ratings, method="split", train=0.8, given=3)

# Predecimos recomendaciones para los 10 primeros usuarios de la matriz
bank.pred<-predict(bank.rec, getData(e, "known"), type="ratings", n=1)
head(as(bank.pred, "matrix"), n=10)

