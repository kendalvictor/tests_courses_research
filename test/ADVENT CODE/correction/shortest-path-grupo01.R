data <- edit(data.frame())
data
library("igraph")                            # Carga igraph

# Empezamos a usar igraph ---------------
g <- graph.data.frame(data, directed = FALSE)  # Crea igraph 
class(g)                                     # Clase del objeto
V(g)$name                                    # Nombres de los v�rtices
E(g)$weight                                  # Peso de las aristas
tkplot(g)                                    # Gr�fico din�mico
plot(g, edge.label = paste(E(g)$weight, sep = "")) # Gr�fico de abajo

# Camino m�s corto entre 1 y 5
sp <- shortest.paths(g, v = "p1", to = "p5")     
sp[]

# Distancia 
gsp <- get.shortest.paths(g, from = "p1", to = "p5")
V(g)[gsp$vpath[[1]]]                           # Secuencia de v�rtices 

# Matriz de adyacencia con ceros
adj <- get.adjacency(g, attr='weight', sparse = FALSE)
adj

distMatrix <- shortest.paths(g, weights = E(g)$weight)
distMatrix[1, 5] 

allsp <- get.all.shortest.paths(g, from = "p1")
str(allsp)


