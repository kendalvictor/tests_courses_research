######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################
# ANALISIS DE CORRESPONDENCIAS SIMPLES #

library("factoextra")
library("FactoMineR")

# Ahora leemos los datos

#--- datos provitos en los paquetes: {FactoMineR}, {factoextra} y {ade4}
data("housetasks")

# Los datos están en una matriz tipo tabla de contigencia: Primera fila con los nombres de 
# las columnas. Primera columna con los nombres de las filas. Las celdas 
# son el conteo que corresponde a cada caso.

# Se hace el Análisis de Correspondencias:

res.ca <- CA(housetasks, graph = FALSE)

#--- para las variables en las filas:
get_ca_row(res.ca)


#--- para las variables en las columnas:
get_ca_col(res.ca)

# Podemos ver las contribuciones en el eje 1
#--- para las filas:
windows()
fviz_contrib(res.ca, choice = "row", axes = 2)

#--- para las columnas:
windows()
fviz_contrib(res.ca, choice = "col", axes = 1)


# Podemos graficar los resultados

#--- para las variables en las filas:
windows()
fviz_ca_row(res.ca, repel = TRUE)

#--- para las variables en las columnas:
windows()
fviz_ca_col(res.ca)


#--- y la visualización conjunta:
windows()
fviz_ca_biplot(res.ca, repel = TRUE)

# ANALISIS DE CORRESPONDENCIAS MULTIPLE #
library(FactoMineR)
library(factoextra)
data(poison)
res.mca <- MCA(poison, quanti.sup = 1:2,
               quali.sup = 3:4, graph=FALSE)

# Podemos observar los resultados para las variable e individuos
# Extraemos los resultados para las variables
get_mca_var(res.mca)
# Extraemos los resultados para los individuos
get_mca_ind(res.mca)



# Visualizamos la contribucion de las variables sobre el eje 1
fviz_contrib(res.mca, choice ="var", axes = 1)
# Visualizamos la contribucion de los individuos sobre el eje 1
# Top 20
fviz_contrib(res.mca, choice ="ind", axes = 1, top = 20)

# Graficos de los individuos
grp <- as.factor(poison[, "Vomiting"])
fviz_mca_ind(res.mca,  habillage = grp,
             addEllipses = TRUE, repel = TRUE)

# Grafico de las variables categoricas
fviz_mca_var(res.mca, repel = TRUE)

# Asociacion de individuos y variables
fviz_mca_biplot(res.mca, repel = TRUE)

# FIN