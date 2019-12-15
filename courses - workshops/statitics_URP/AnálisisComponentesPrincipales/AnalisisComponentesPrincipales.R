######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################
############################################
# ANÁLISIS DE COMPONENTES PRINCIPALES ######
############################################

# Comandos necesarios para el ACP o PCA

# La función de R que nos permite realizar el PCA se llama princomp:

princomp(dataset)

# Es importante que el conjunto de datos solo contenga variables numéricas, puesto que para el cálculo de 
# las componentes necesitamos estimar una matriz de correlación o de covarianzas. 
# Si hubiera variables NO numéricas en el conjunto de datos, debemos excluirlas con el comando [ , ].
# La función princomp nos mostrará las varianzas de cada una de las componentes. Sin embargo, 
# existen más resultados que involucran al PCA y no son visualizados por defecto, entre ellos las 
# cargas y los factores. Para organizar correctamente el output de este análisis podemos guadar todas 
# los elementos del output en un objeto como se muestra a continuación:
        
Mi.modelo.PCA<-princomp(dataset)

# Una vez guardado los resultados en un objeto, poderemos recuperar todos los outputs de manera 
# conveniente. Por ejemplo, puedes utilizar la función summary() para visualizar las varianzas de 
# cada componente, las cargas y los factores:

summary(Mi.modelo.PCA)

# Para visualizar solo las cargas: > Mi.modelo.PCA$loadings
# Para visualizar los scores: > Mi.modelo.PCA$scores


# Ejemplo I: PCA datos Económicos de Europa

Europa=read.csv("http://www.instantr.com/wp-content/uploads/2013/01/europe.csv", header=TRUE)
head(Europa, 3)


# Como podemos ver, este conjunto de datos tiene 1 variable categórica (Country) y las restantes numéricas. 
# Por ello deberíamos quitar la primera columna para poder llevar adelante el análisis:

Europa2=Europa[,c(2,3,4,5,6)]
head(Europa2, 3)

correlacion <- cor(Europa2)
# A continuación utilizamos la función prcomp() para obtener las componentes principales:       
pca.Europa2 <- prcomp(Europa[,2:8], scale=TRUE) 
# Scale = False -> utilizamos la matriz de COVARIANZA para obtener las componentes! Veamos que ocurre:

# Resumen
summary(pca.Europa2)

# Gráfico de la varianza explicada
plot(pca.Europa2)


# La primera componente captura ‘casi toda’ la variabilidad de los datos! Esto quiere decir que podríamos 
# reducir las 7 variables originales a una sola variable (componente principal) manteniendo (prácticamente) 
# constante la cantidad de información disponible con respecto al conjunto de datos originales.

# ¿PORQUE OCURRE ESTO?
# Por ello, en vez de utilizar la matriz de covarianzas para hacer PCA, se utiliza la matriz de 
# correlación:

pca.Europa2 <- prcomp(Europa2, scale=T) 
# Scale = True -> utilizamos la matriz de CORRELACIÓN para obtener las componentes! 
#Veamos que ocurre:
summary(pca.Europa2)

plot(pca.Europa2)

# Al homogeneizar la ‘escala’ en la que hemos medido las variables, la distribución de 
# la variabilidad entre las com ponentes parece más racional. Podemos ver más elementos 
# del output del PCA:

pca.Europa2$sdev # Criterio de Kasiser
pca.Europa2$rotation # cargas de cada componente.


head(pca.Europa2$x, 3) # Matriz de datos (solo primeras 3 filas) con las componentes 
# (en columnas las nuevas variables).
pca.Europa2$sdev # Autovalores de los Componentes
pca.Europa2$rotation
pca.Europa2$x # Puntuaciones factoriales

Componentes<-pca.Europa2$x[,1:3]
Europa3<-cbind(Europa,Componentes)

View(Europa3)

# Ejemplo II: PCA datos decathlon

# En este ejemplo vamos a utilizar (solo a modo informativo) otras librerias que complementan el 
# analisis PCA con los Biplots. El conjunto de datos hace referencia a los registros obtenidos 
# por diferentes deportistas (33 atletas) en los juegos olímpicos para diferentes disciplinas. 
# El conjunto de datos pertenece a la librería FactoMineR.

library(FactoMineR)
data(decathlon)
head(decathlon, 3)

res <- PCA(decathlon,quanti.sup=11:12,quali.sup=13)

plot(res,invisible="quali") # Grafico de variables cualitativas
plot(res,choix="var",invisible="quanti.sup") # Grafico de variables cuantitativas

plot(res,habillage=13)

aa=cbind.data.frame(decathlon[,13],res$ind$coord)
bb=coord.ellipse(aa,bary=TRUE)
plot.PCA(res,habillage=13,ellipse=bb)

# Que tipo de conclusiones podríamos sacar de este tipo de análisis? 

Compo_Princ<-PCA(Europa[,2:8],scale.unit = T,3)

# !! FIN