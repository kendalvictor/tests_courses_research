rm(list = ls())
dev.off()

# Canilla <- "Base de datos a cargar"

#ordenamos de acuerdo a la Fecha, del mas antiguo al mas reciente
Canilla<-arrange(Canilla,FechaPublicacion)

#Eliminamos Canillas con Pauta cero(0)
Canilla<-subset(Canilla,Pauta>0)

#Limpieza de atipicos con "Estandarizacion Z"
library(plyr)

Canilla <- ddply(Canilla, .(DescripcionCanilla,DescripcionMaterial),
                 transform,Zscore = (VentaNeta - mean(VentaNeta)) / sd(VentaNeta))
Canilla <- subset(Canilla,Zscore<=2 & Zscore>=-2)

#Funcion para Proyectar Holt - Winter
ProyHolt<- function(x) 
{can<-ts(data = x$VentaNeta,start = c(2016,1), frequency = 52)
h1<-HoltWinters(can)
pred<-forecast(h1, h = 1)
return(pred$upper)
}

#Ejecutamos la funcion para proyectar por Canilla-Dia de semana
C<-ddply(Canilla, .(DescripcionCanilla,DescripcionMaterial),ProyHolt)
