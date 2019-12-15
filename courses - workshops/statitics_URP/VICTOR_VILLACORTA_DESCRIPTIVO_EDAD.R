rm(list=ls())
library(mlr)
library(beanplot)
library(e1071)
library(MASS)

# CARGA DE LA DATA A UTILIZAR
data = read.csv("base_de_datos/bancomark.txt", sep="\t")

# ANALISIS DEL CUADRO RESUMEN DE LOS DATOS
summary <- summarizeColumns(data) 
summary

# Comenzamos con el análisis de la variable edad
edad = data$edad
mean(edad)
median(edad)

IQR(edad)
range_edad <- max(edad) - min(edad)
range_edad
# OBSERVACIONES:
# -> la media = 41 y la mediana 39, entonces tiene comportameinto simetrico
# -> el rango intercuartilico = 16 y la diferencia de max con minimo es 68, entonces
#    como hay un comportamiento normal quiere que poseemos casos atipicos a nivel
#    inferior y superiror

beanplot(edad, col="lightgray")
# Tras las visualizacion de confirmamos nuestras sospechas de la distribucion de nuestra data,
# Obteneiendo un poco mas de detalle a nivel de concentración de datos un poco abajo de la media.

hist(edad)
# El histograma termina por confirmar la concetracion un poco abajo de la media

boxplot(edad)

skewness(edad)
kurtosis(edad)
# Vemos un kurtosis = 0.34, como en R ya se le quita 3 a la formula, tenemos una forma mesocurtico


# VARIABELE MORA
data$mora_int = as.numeric(data$mora)
# observando la transformacion se asigno no=1, si=2

library(CTT)
polyserial(edad, data$mora_int)
# Podemos inferir un relacion inversa con grado 0.05506243, casi nulo















