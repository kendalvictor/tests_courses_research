rm(list=ls())

#########################################################################
### -- STATISTICAL SCIENCE INTRODUCTION --## 
#########################################################################
### Autor: Jose Cardenas - Andre Chavez ## 
### Modelo III: ANALISIS DESCRIPTIVO ##

#########################################################################

# Temas a Tocar

# .	Medidas de Tendencia Central: Media, mediana, moda. 
# .	Medidas de Variabilidad: Rango, Rango Intercuartílico, Varianza, Desviación Estándar, 
# . Coeficiente de Variación. Coeficiente de asimetría y curtosis.  
# . Números Aleatorios y Muestreo Probabilístico.
# .	Medidas de Asociación. Correlación y Pruebas Chi Cuadrado. Pruebas Paramétricas 
#   y No Paramétricas. Ejemplos Aplicativos.

# DIRECCIONAR A CARPETA DE TRABAJO
#setwd("//fs4/Empresas CS/Josecardenas/curso de estadistica")

# CARGA DE LA DATA A UTILIZAR
data=read.csv("train.csv")

names(data)

library(mlr) 
summarizeColumns(data) # estadistica resumen por columnas
tabla <- summarizeColumns(data)

# VARIABLE A UTILIZAR PARA PUNTO 1
x=data$ApplicantIncome

# 1: Medidas de tendencia Central 

# media

mean(x)
length(x) # numero de elementos

# Mediana

median(x)

# moda

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

moda <- getmode(x)
print(moda)


# .	Medidas de Variabilidad: Rango, Rango Intercuartílico, Varianza, Desviación Estándar, 
# . Coeficiente de Variación. Coeficiente de asimetría y curtosis. Números Aleatorios y 
# . Muestreo Probabilístico.

# Rango

rango=max(x)-min(x)
rango

#Rango Intercuartílico

IQR(x) # q3 - q1 representa el 50% de los datos 

#Varianza
var(x) # no se interpreta puesto esta en unidades cuadraticas

# Desviación Estándar

sd(x) # aca se interpreta

# Coeficiente de Variación

cv<-function(x) { return(mean(x)/sd(x)) }
cv(x) # comparacion de grupos, ver grupos homogenios

# Coeficiente de asimetría

library(e1071) 
skewness(x) # coef es mayor a cero es una asimetrica positiva,
# si es negativo es asimetrica negartiva , si es cero es simetrica

# curtosis
kurtosis(x) # si es mayor a 3 es leptocurtica, si es <3 
#es platicurtica y es = 3 mesocurtica

# Números Aleatorios y  Muestreo Probabilístico.

#uniforme
set.seed(1234) # semilla aleatoria
a <- runif(1000) # 1000 numeros aleatorios entre 0 y 1 con dist uniforme
plot(a)

# Muestreo Probabilístico aleatorio simple
nn=max(dim(data)) # numero de filas
nn <- nrow(data) # numero de filas
nn

set.seed(12345)
sample<-sample.int(nn,round((0.7)*nn)) # parametros: (cantidad o el n,cuanto necesitas)
head(sample)

data1 <- data[sample,] # filtrando las observacion de mi muestra obtenida
data2 <- data[-sample,] # todas las demas

# es lo mismo colocar(sample.int(614,430))

# .	Medidas de Asociación. Correlación y Pruebas Chi Cuadrado. Pruebas Paramétricas 
#   y No Paramétricas. Ejemplos Aplicativos.

# CODIGO NORMAL
# cor(x, y = NULL,  method = c("pearson", "kendall", "spearman"))

attach(data) # nombres de las variables

# Numericas

# OBTENDREMOS LA CORRELACION POR DEFECTO DE PEARSON COLOCANDO EL TERMINO pairwise.complete.obs PARA DATOS INCOMPLETOS
cor(ApplicantIncome, Loan_Amount_Term,use="pairwise.complete.obs")

cor(ApplicantIncome, Loan_Amount_Term,use="pairwise.complete.obs",
    method = "spearman")

# Cualitativas

# transformacion de las variables
data$Gender=as.numeric(data$Gender)
data$Education=as.numeric(data$Education)

## CORRELACION DE SPEARMAN
cor(Gender, Education,use="pairwise.complete.obs",method = "spearman")

## sOLUCION DE LOS DATOS FALTANTES COLOCANDO POR DEFECTO CERO
data$ApplicantIncome[is.na(data$ApplicantIncome)] <- 0
data$Loan_Amount_Term[is.na(data$Loan_Amount_Term)] <- 0

data1 <- data
data2 <- data

data1$LoanAmount[is.na(data1$LoanAmount)] <- 0 # nulos colocando valor cero
data2$LoanAmount[is.na(data2$LoanAmount)] <- median(data2$LoanAmount[!is.na(data2$LoanAmount)]) # colocando el promedio

head(data1$LoanAmount)
head(data2$LoanAmount)

# veamos cuanto difiere cada imputacion

mean(data1$LoanAmount)
median(data1$LoanAmount)

mean(data2$LoanAmount)
median(data2$LoanAmount)

## TIPOS DE CORRELACION NO PARAMETRICOS

# polyserial (variable cuantitativa vs cualitativa)
library(CTT)
polyserial(ApplicantIncome, Education, ml = F)

# polycorica (variable cualitativa vs cualitativa)
library(polycor)
polychor(Gender, Married, ML=F)

# matriz de correlaciones no parametricas completas
data$Gender <- as.factor(data$Gender) # categorizando el genero

hetcor(data, use = "pairwise.complete.obs")

correlation <- hetcor(data, use = "pairwise.complete.obs")
correlacion <- correlation$correlations

## TIPOS DE CORRELACION PARAMETRICOS

## chi cuadrado funcion para utilizar en varios x

# calcula_chisq <- function(y,x)
# {
#   d=dim(x)[2]
#   pvalues=matrix(,d,1)
#   for(i in 1:d){
#     pvalues[i,] <- chisq.test(y,x[,i])$p.value
#   }
#   return(cbind(data.frame(names(x)),pvalues))
# }
# 
# calcula_chisq(y,x)

# de forma individual

y=as.numeric(Gender)
x=as.numeric(Married)

chisq.test(y,x)
