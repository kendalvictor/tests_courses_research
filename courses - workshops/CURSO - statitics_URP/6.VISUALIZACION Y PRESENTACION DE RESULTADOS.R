rm(list=ls())

#########################################################################
### -- STATISTICAL SCIENCE INTRODUCTION --## 
#########################################################################
### Autor: Jose Cardenas - Andre Chavez ## 
### Modelo VI: VISUALIZACIÓN Y PRESENTACIÓN DE RESULTADOS ##

#########################################################################

# TEMAS A TOCAR

# .	Barras. Gráficos de Pie. Gráficos Avanzados
# .	Gráficos Multivariados.

# librerias a usar
library(beanplot)
library(vioplot)
library(lattice)
library(MASS)
library(corrplot)
library(cwhmisc)
library(IDPmisc)
library(aplpack)

#DIAGRAMAS BEANPLOT

# Data a Utilizar
datos <- read.table("PrecioVivienda.txt",header=T)

# Utilizar nombres de variables
attach(datos)

# Graficos beanplot
beanplot(Precio~Barrio,col = "lightgray")

# graficos vioplot
vioplot(Precio[Barrio=='Este'],Precio[Barrio=='Norte'],Precio[Barrio=='Oeste'],
        col="tomato")

### multivariada

# El paquete lattice es muy ´util para describir gr´aficamente datos multivariantes.
# La idea consiste en que el gr´afico est´a formado por un cierto n´umero de paneles. Normalmente cada
# uno de ellos corresponde a alguno de los valores de una variable que condiciona. Es decir, un gr´afico
# diferente para cada nivel del factor utilizado como condici´on. Las funciones se escriben con la notaci´on
# de la f´ormula del modelo. En los gr´aficos univariantes como los histogramas, la variable respuesta, a la
# izquierda, se deja vac´ia.

histogram(~CW | sp, data = crabs)
bwplot(~CW | sp, data = crabs, layout = c(1, 2))
## Gr´aficos de caja para el sexo seg´un especie
bwplot(sex ~ CW | sp, data = crabs, layout = c(1, 2))

## Tambi´en disponemos de diagramas de dispersi´on. Con la funci´on xyplot en lugar de plot. En este caso
##se necesitan dos variables.

# Como se puede ver en la figura 5, el resultado de esta instrucci´on es un gr´afico con cuatro paneles donde
# podemos estudiar la relaci´on entre dos variables seg´un dos factores.
xyplot(CL ~ CW | sp * sex, data = crabs)

#MATRICES DE CORRELACIÓN

M = cor(datos[,2:6])
corrplot(M, method = "circle")
corrplot(M, method = "square")
corrplot(M, method = "ellipse")
corrplot(M, method = "number")
corrplot(M, method = "shade")
corrplot(M, method = "color")
corrplot(M, method = "pie")
corrplot(M, type = "upper")
corrplot(M, type = "lower")
corrplot.mixed(M)
corrplot.mixed(M, lower = "ellipse", upper = "circle")

#GRÁFICOS SPLOM

SplomT(datos[,2:6])
SplomT(datos[,2:6],mainL="",hist="d",cex.diag=0.6,hist.col="green")

#GRÁFICOS PARA GRANDES VOLÚMENES DE DATOS

iplot(Precio,Piescuad)
iplot(Precio,Piescuad,pixs=4)

ipairs(datos[,2:6],pixs=2)

require(stats)
mosaicplot(Titanic, main = "Sobrevivencia en el Titanic", color = TRUE)
#Fórmula de interface para datos tabulados:
mosaicplot(~ Sex + Age + Survived, data = Titanic, color = TRUE)

#GRÁFICOS DE ESTRELLAS
require(grDevices)
stars(mtcars[, 1:7], key.loc = c(14, 2),
      main = "Tendencia en Motores de Autos : stars(*, full = F)", full = FALSE)
#Diagrama de segmentos
palette(rainbow(12, s = 0.6, v = 0.75))
stars(mtcars[, 1:7], len = 0.8, key.loc = c(12, 1.5),
      main = "Tendencia en Motores de Autos", draw.segments = TRUE)

#CARAS DE CHERNOFF
data(longley)
faces(longley[1:9,],face.type=0)
faces(longley[1:9,],face.type=1)

plot(longley[1:16,2:3],bty="n")
a=faces(longley[1:16,],plot=FALSE)
plot.faces(a,longley[1:16,2],longley[1:16,3],width=35,height=30)

a=faces(rbind(1:3,5:3,3:5,5:7),plot.faces=FALSE)
plot(0:5,0:5,type="n")
plot(a,x.pos=1:4,y.pos=1:4,1.5,0.7)
#durante la temporada de navidad
faces(face.type=2)

#GRÁFICO SUMMARY

plotsummary(cars)
plotsummary(cars, types=c("ecdf", "density", "boxplot"),
            y.sizes = c(1,1,1), design ="stripes")


## Not run:
daten<-iris[,2:3]
slider.bootstrap.lm.plot(daten)

## Not run:
slider.hist(log(islands))

## Not run:
slider.lowess.plot(cars)

## Not run:
slider.split.plot.ts(as.vector(sunspots)[1:100])

## Not run:
slider.stem.leaf(islands)

## Not run:
slider.zoom.plot.ts(co2,2)

