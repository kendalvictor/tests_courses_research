######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################
###################################################
# ANÁLISIS DE CLUSTER O CONGLOMERADOS #############
###################################################

# Cargamos las librerias a utilizar

library("cluster")
library("fpc")
library("mclust")
library("dbscan")
library("readxl")

# Preparar los datos: normalizar y estandarizar ? Es necesario ?

carros<-read.csv("carros2011imputado2.csv", header=TRUE, sep=",", dec=".")
numericos <- sapply(carros, is.numeric) # Le aplicamos el 
# argumento2 a el argumento1.

# Me quedo solo con las numericas
carrosnum<- carros[ , numericos]

# Necesitamos las variables de identificacion
carroslabel<-paste(carros$fabricante,carros$modelo)

# Estandarizamos
carrosnormal<-scale(carrosnum[,-1])  # retiramos el ID

# Conocer/guardar las medias y desviaciones
medias<-attr(carrosnormal,"scaled:center")
desviaciones<-attr(carrosnormal,"scaled:scale")

# Metricas de distancia: usar dist() o libreria philentropy
ejemploeuclid <- dist(carrosnormal[2:3,], method="euclidean")
carrosdist<-dist(carrosnormal, method="euclidean")

# Aplicamos el cluster no jerarquico KMeans
set.seed(100) # Semilla aleatoria
carroskmcluster<-kmeans(carrosnormal, centers=3, iter.max=100)
carroskmcluster$iter # Ver numero de iteraciones

# Cluster de pertenencia
carroskmcluster$cluster

# Centroides o centros de gravedad
carroskmcluster$centers

# Tamaño de los clusters
carroskmcluster$size
par(mfrow=c(1,1))
library(ggplot2)
clusplot(carros,carroskmcluster$cluster, color=TRUE)

# Podriamos usar un método mas elaborado como PAM o CLARA
set.seed(100)
carrosmedoid<-pam(carrosnormal,k=3,stand=FALSE)
clusplot(carrosmedoid)
# Ver los valores y casos del medoide
carrosmedoid$medoids
carrosmedoid$id.med
carrosmedoid$clusinfo

# Resumen del Modelo de Medoides
summary(carrosmedoid)
#los valores para guardarlos
carrosmedoid$clustering

# Cluster Jerarquico: Aglomerativo hclust() o agnes() , diana() es divisive
carrosjerarq <- hclust(carrosdist,method="ward.D")

# Mostrarlo con etiquetas
plot(carrosjerarq, labels=carroslabel)

##############################################
# Seleccionar el numero optimo de clusters####
##############################################

# Calcula la suma total de cuadrados
wss <- (nrow(carrosnormal)-1)*sum(apply(carrosnormal,2,var))

# La calcula por clusters
for (i in 2:15) wss[i] <- sum(kmeans(carrosnormal,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Nummero de Clusters",
     ylab="Suma de cuadrados within") 

##############################################
#Metodos Avanzados de Eleccion de Clusters####
##############################################

# Evaluar usando el criterio CH Indice Calinski Harabasz
#es un indice basado/cercano a una F de anova
set.seed(26935) 
clustering.ch <- kmeansruns(carrosnormal,krange=2:60,
                            criterion="asw",iter.max=100, 
                            runs= 100,critout=TRUE)
clustering.ch$bestk

# Evaluar usando el criterio ASW (average sillouethe width)
set.seed(2) #Para evitar aleatoriedad en los resultados
clustering.asw <- kmeansruns(carrosnormal,krange=2:10,criterion="asw",iter.max=100, runs= 100,critout=TRUE)
clustering.asw$bestk
clustering.asw$crit

#Evaluar con gap statistic
#mira el minimo k tal que el gap sea mayor que el gap de k+1 restado de su desviacion
gscar<-clusGap(carrosnormal,FUN=kmeans,K.max=20,B=60)
gscar

#validar resultados- consistencia
kclusters <- clusterboot(carrosnormal,B=10,clustermethod=kmeansCBI,k=5,seed=5)
#la validacion del resultado. <0.75 o .85 muy bueno; <.6 malo
kclusters$bootmean
#el grupo de pertenencia
hgroups <- kclusters$result$partition

### FIN ####
