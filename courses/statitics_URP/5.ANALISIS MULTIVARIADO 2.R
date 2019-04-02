rm(list=ls())

#########################################################################
### -- STATISTICAL SCIENCE INTRODUCTION --## 
#########################################################################
### Autor: Jose Cardenas - Andre Chavez ## 
### Modelo IV: ANALISIS MULTIVARIADO II ##

#########################################################################

# TEMAS A TOCAR

# .	Regresi?n Lineal Simple y M?ltiple. Modelo de Regresi?n, suposiciones 
#   del modelo. Estimaci?n y predicci?n. An?lisis de Residuos.
# .	Introducci?n a la Regresi?n Log?stica.
# .	Introducci?n a la Regresi?n con Regularizaci?n. Lasso. Elastic-Net.
# .	Introducci?n a la Regresi?n No Param?trica.


### regresion lineal y multiple #####

#  cargar datos
data<-read.table("base_de_datos/PrecioVivienda.txt",header=T)

# solo numericas
data1<-data[,2:6]
attach(data1)

# crear modelos
modelo <- lm(Precio ~ Piescuad + Cuartos + Ba?os + Ofertas)
anova(modelo)
summary(modelo)

# quitando el intercepto
modelo <- lm(Precio ~ Piescuad + Cuartos + Ba?os + Ofertas - 1)

# resumen del modelo
summary(modelo)

# analisis de residuos
windows()
opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(modelo,las = 1)      # Residuals, Fitted, ...
par(opar)

## Nuestro primer modelo de machine learning

data2=read.table("data2.txt",header=T)

set.seed(12345)
sample<-sample.int(nrow(data2),
                   0.7*nrow(data2))
length(sample)


data.train=data2[sample,2:min(dim(data2))]
data.test=data2[-sample,2:min(dim(data2))]

modelo <- lm(Precio ~ .,data=data.train)
yest=predict(modelo,data.test)
cor(yest,data.test$Precio)
sse=sum((yest-data.test$Precio)^2)

plot(data.test$Precio,type="l",col="blue")
points(yest,type="l",col="red")

####  REGRESI?N LOG?STICA SIMPLE #################

# cargar la data
data2=read.table("base_de_datos/VIVIENDA.txt", header=T)
table(data2$propietario)

# volver categoria 
data2$propietario = as.factor(data2$propietario)

# data train-test
set.seed(12345)
sample <- sample.int(
  nrow(data2), 0.7*nrow(data2)
)
length(sample)

data.train=data2[sample,1:min(dim(data2))]
data.test=data2[-sample,1:min(dim(data2))]

## modelo
modelo1 = glm(propietario~., data=data.train, family = binomial())
summary(modelo1)

proba = predict(modelo1, newdata=data.test, type="response")

## indicadores

library(ROCR)
pred=prediction(proba,data.test$propietario)
curvaroc1= performance(pred,measure = "tpr",x.measure = "fpr")##tpr: tasa verdaderos positivos fpr:tasa falsos positivos 
plot(curvaroc1)

# calcular el AUC
auc1=performance(pred,measure="auc")
auc_modelo1=(auc1@y.values[[1]])
gini1 <- 2*(auc_modelo1) -1
gini1

## calculo del ks

ks1=max(attr(curvaroc1,'y.values')[[1]]-attr(curvaroc1,'x.values')[[1]])
ks1

# Calcular Matriz confusion
library(caret)

PRED <-predict(modelo1,data.test,type="response")
PRED=ifelse(PRED<=mean(PRED),0,1)
PRED=as.factor(PRED)

tabla=confusionMatrix(PRED,data.test$propietario,positive = "1")
Sensitivity1=as.numeric(tabla$byClass[1])
# Calcular el error de mala clasificaci?n
error1=mean(PRED!=data.test$propietario)
acierto1=1-error1

# indicadores de comparacion

auc_modelo1
gini1
error1
acierto1
Sensitivity1

##  Regresi?n con Regularizaci?n. Lasso. Elastic-Net  ####

library(glmnet)
library(readxl)
library(ggplot2)

# data a utilizar
carros<-read.csv("carros2011imputado2.csv",header=TRUE)

## particion data train test

sample<-sample.int(nrow(carros),
                   round(.8*nrow(carros)))
carros.train<-carros[sample,]
carros.validation<-carros[-sample,]

precio.train<-as.matrix(carros.train$precio_promedio)
predictores.train<-as.matrix(carros.train[,2:17])

precio.validation<-as.matrix(carros.validation$precio_promedio)
predictores.validation<-as.matrix(carros.validation[,2:17])

## ridge

foundridge.train<-cv.glmnet(predictores.train,precio.train,alpha=0,nfolds=5)
plot(foundridge.train)

foundridge.train$lambda.1se
foundridge.train$lambda.min

coef(foundridge.train,s=foundridge$lambda.1se)
coef(foundridge.train,s=foundridge$lambda.min)

## lasso

foundlasso<-cv.glmnet(predictores.train,precio.train,alpha=1,nfolds=5)

plot(foundlasso)

foundlasso$lambda.1se
foundlasso$lambda.min
coef(foundlasso,s=foundlasso$lambda.1se)
coef(foundlasso,s=foundlasso$lambda.min)

## nnet

#cfreo modelos, general y de entrenamiento
foundnet.train<-cv.glmnet(predictores.train,precio.train,alpha=0.5,nfolds=5)

foundnet.train$lambda.1se
foundnet.train$lambda.min
plot(foundnet.train)

coef(foundnet.train,s=foundnet.train$lambda.1se)
coef(foundnet.train,s=foundnet.train$lambda.min)

#predigo en la base de validacion con los 3 modelos
predridge<-predict(foundridge.train,predictores.validation,s="lambda.min")
predlasso<-predict(foundlasso.train,predictores.validation,s="lambda.min")
prednet<-predict(foundnet.train,predictores.validation,s="lambda.min")

#calcular mse para los tres modelos
ridgemse<-sqrt(mean((predridge-precio.validation)^2))
lassomse<-sqrt(mean((predlasso-precio.validation)^2))
netmse<-sqrt(mean((prednet-precio.validation)^2))

ridgemse
lassomse
netmse

####### REGRESION NO PARAMETRICA #########

## REGRESORGRAMA

#Regresorgrama (Clima organizacional vs. satisfacci?n del usuario)
datos=read.table("SATISFACCION.txt", header=T)
attach(datos)
minimo=min(datos[,1])
maximo=max(datos[,1])
plot(datos,col='red',pch=19)
particion=c(minimo, 2, 2.2, 2.4, 4, 4.3, 4.6, 4.8, 5, maximo)
n1=dim(datos)
n2=length(particion)
s=rep(0,n2-1)
x1=rep(0,2)
y1=rep(0,2)

for (j in 1:(n2-1))
{
  suma=0
  cont=0
  for (i in 1:n1[1])
  {
    if (datos[i,1]>=particion[j]&datos[i,1]<particion[j+1])
    {
      suma=suma+datos[i,2]
      cont=cont+1
    }
  }
  s[j]=suma/cont
  x1[1]=particion[j]
  x1[2]=particion[j+1]
  y1[1]=s[j]
  y1[2]=s[j]
  lines(x1,y1,type="l",col="blue")
}

for (j in 2:(n2-1))
{
  x1[1]=particion[j]
  x1[2]=particion[j]
  y1[1]=s[j]
  y1[2]=s[j-1]
  lines(x1,y1,type="l",col="blue")
}  

#Running means
datos=read.table("SATISFACCION.txt",header=T)
k=30
n=dim(datos)
s=rep(0,n[1]-2*k)
for (i in (k+1):(n[1]-k))  
{
  j=seq(i-k, i+k)
  s[i]=mean(datos[j,2])
  
}
i = seq(k+1,n[1]-k)
plot(datos[i,1],s[i],type = "s", col = "blue")
points(datos, col = "red", pch = 19)

#Running lines 
datos=read.table("SATISFACCION.txt",header=T)
plot(datos, col="red", pch=19)
k=10
n=dim(datos)
cont=0
x1=rep(0,n[1]-2*k)
y1=rep(0,n[1]-2*k)
for (i in (k+1):(n[1]-k))
{
  j=seq(i-k,i+k)
  modelo=lm(datos[j,2]~datos[j,1])
  cont=cont+1
  x1[cont]=datos[i,1]
  y1[cont]=modelo[1]$coefficients[1]+modelo[1]$coefficients[2]*x1[cont]
}
lines(x1,y1,col="blue")