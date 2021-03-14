##################################################
##### Clusterización y reglas de asociacion ######
##### Instructor: Daniel Chávez Gallo       ######
##### Correo: dacg160381@gmail.com          ######
##################################################

## Elimna todos los objetos creados, limpia la memoria utilizada.
rm(list=ls())

## Limpia consola
cat("\014")

## Cambiar el directorio de trabajo, por defecto sera la 
# carpeta de donde se abrio el presente scrip.
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

## Importando datos
library(readxl)
data <- read_xlsx("Datos/BD_VENTAS_REGLAS.xlsx")
# estructura de la data importada
str(data)
# encabezado, 6 registros por defecto
head(data)

## Tratamiento de los datos
# transformar a formato de fecha
data$FECHA <- as.Date.factor(data$FECHA, format = "%Y-%m-%d")
# tipo de dato
class(data$FECHA)
# frecuencia de compras
table(data$COD_CLIENTE)
# cantidad de clientes
length(table(data$COD_CLIENTE))

##---------------------------- Agrupación RFM ------------------------------##
# dias trascurridos desde la ultima compra
data$Recencia <- round(as.numeric(difftime(Sys.Date(), data$FECHA, units = "days")))

# creando las variables de 'Monto_total', 'Frecuencia' y 'Recencia' 
dataM <- aggregate(data$MONTOS, list(data$COD_CLIENTE), sum) # tambien puede ser la mean
names(dataM) <- c("Cliente", "Monto")

dataF <- aggregate(data$MONTOS, list(data$COD_CLIENTE), length)
names(dataF) <- c("Cliente", "Frecuencia")

dataR <- aggregate(data$Recencia, list(data$COD_CLIENTE), min)
names(dataR) <- c("Cliente", "Recencia")

# formando la data R, F y M
dataRF  <- merge(dataR, dataF, "Cliente")
dataRFM <- merge(dataRF, dataM, "Cliente")
head(dataRFM)
# dimension del data frame
dim(dataRFM) # 173 clientes

# creando los niveles R, F y M por quintiles
#   donde 5 es el menos reciente y 1 el mas reciente
#   donde 5 es el más frecuente y 1 el menos frecuente
#   donde 5 es el más monto y 1 el menos monto gasto
dataRFM$rankR <- cut(-dataRFM$Recencia, 5, labels = F)  
dataRFM$rankF <- cut(dataRFM$Frecuencia, 5, labels = F)  
dataRFM$rankM <- cut(dataRFM$Monto, 5, labels = F)   

# mostrando top 10
dataRFM <- dataRFM[with(dataRFM, order(-rankR, -rankF, -rankM)), ]
head(dataRFM, n=10)

# agrupando, tomando como artificio (unidad, decena y centena)
groupRFM <- dataRFM$rankR*100 + dataRFM$rankF*10 + dataRFM$rankM
dataRFM <- cbind(dataRFM,groupRFM)
head(dataRFM, n=10)

# grafico de RFM
library(ggplot2)
ggplot(dataRFM, aes(factor(groupRFM))) + 
  geom_bar(fill = "white", colour = "blue") + 
  ggtitle('Segmentación de Clientes RFM') + 
  labs(x="RFM",y="#Clientes")

library(rgl)
plot3d(dataRFM$rankR, dataRFM$rankF, dataRFM$rankM, 
       xlab = "Recencia",  ylab = "Frecuencia", zlab = "Monto",
        col = dataRFM$groupRFM, type = "s", radius = 0.3 )

##---------------------------- Agrupación Kmeans ------------------------------##
# normalizar entre [0, 5]
normalize <- function(x){
  return (((x - min(x)) / (max(x) - min(x))))
  }

# data normalizada, sin unidades
dataRFM_n <- as.data.frame(lapply(dataRFM[, 2:4], normalize))
rownames(dataRFM_n) <- dataRFM[, 1]
summary(dataRFM_n)

# grafico de sedimentación, para elegir el numero de grupos
wss <- (nrow(dataRFM_n)-1)*sum(apply(dataRFM_n, 2, var))
for (i in 2:15) wss[i] <- sum(kmeans(dataRFM_n, centers = i)$withinss)
plot(2:15, wss[-1], type="b", xlab="numero de grupos", ylab="Dentro de los grupos, SS")

# Verificamnos la significancia del numero de grupos propuesto
#   si el indicador de cada grupo esta entre 70% y 90%, 
#   el numero de grupos es adecuado
#   de lo contraio, existe sobreajuste
library(fpc)
clusterboot(dataRFM_n, B = 100, clustermethod = kmeansCBI, k = 4, seed=5)$bootmean

# veamos los grupos
set.seed(537)
dataCluster <- kmeans(dataRFM_n, 3, nstart = 200)
dataCluster$centers

# grafico
library(cluster)
clusplot(dataRFM_n, dataCluster$cluster, color=TRUE)

# join con la tabla principal
dataRFM <- data.frame(dataRFM, clusterKM = as.factor(dataCluster$cluster))
head(dataRFM)

##---------------------------- Reglas de asociación ------------------------------##
library(arules)
# la data
dataRFM_2 <- dataRFM[, c(2:4, 9)]
rownames(dataRFM_2) <- dataRFM[,1]
head(dataRFM_2)

# el monto llevado a miles
dataRFM_2$Monto <- round(dataRFM_2$Monto/1000,0)

# discretizando por frecuencia
dataRFM_2$Monto       <- discretize(dataRFM_2$Monto, 
                                     method = "frequency", 5)
dataRFM_2$Frecuencia  <- discretize(dataRFM_2$Frecuencia, 
                                     method = "frequency",5)
dataRFM_2$Recencia    <- discretize(dataRFM_2$Recencia, 
                                     method = "frequency", 5)
head(dataRFM_2)
summary(dataRFM_2)

#  elegimos el segmento de analisis 
dataCluster$centers

# El patrón de los clientes dentro del mejor grupo, sera evaluado por:

# Soporte
#   Frecuencia con la cual se presenta el patrón dentro del clúster.
# Confianza
#   % de ocurrencias dentro del clúster con respecto al total de ocurrencias del patrón.
# Lift
#   Refleja cuanto veces mas probable es que el patrón represente al clúster.

rules <- apriori(dataRFM_2, parameter = list(minlen=2, supp=0.02, conf=0.2),
                 appearance = list(rhs = c("clusterKM=1"), default = "lhs"),
                 control = list(verbose = F))

rules.sorted <- sort(rules, by = "lift")
inspect(rules.sorted)











