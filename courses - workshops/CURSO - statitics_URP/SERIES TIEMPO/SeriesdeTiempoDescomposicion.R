rm(list=ls())

######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################

library(ggplot2)
library(TSA)
library(forecast)
library(scales)
library(stats)
#library(arima)

# Carga de datos
Yt<-read.delim("datatesisaereo.txt",header=T)
Yt<-ts(Yt,start=c(2000,1),freq=12)

# Grafico de la serie
plot(Yt)

# Agrupacion de meses
boxplot(Yt ~ cycle(Yt))
cycle(Yt)

## descomposicion
Yt.ts.desc = decompose(Yt,type="multiplicative")
plot(Yt.ts.desc, xlab='A?o')
Yt.ts.desc 

tendencia=data.frame(Yt.ts.desc$trend)

tendencia$Yt.ts.desc.trend[is.na(tendencia$Yt.ts.desc.trend)]=0

tendencia$x=seq(1:nrow(tendencia))
modelo=lm(Yt.ts.desc.trend~x,data=tendencia)
tendencia_estimada=modelo$fitted.values


estacional=data.frame(Yt.ts.desc$seasonal)

# estimacion de la serie

dataf=data.frame(tendencia_estimada,estacional);colnames(dataf)=c('tend_est','estacionalidad')
dataf$Yt_est=dataf$tend_est*dataf$estacionalidad

## Grafico del modelo final

plot(Yt,col="red")
points(dataf$Yt_est,type='l',col="blue")

