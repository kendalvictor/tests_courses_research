
#####RETO PROGRAMAZACIÓN
#############################################################################
##### lectura de datos ######################################################
#############################################################################

rutas<-read.table("rutas.txt")

#############################################################################
##### descriptivo ciudad origen y ciudad destino ############################
#############################################################################

table(rutas$V1)
table(rutas$V3)

# Se aprecia que tenemos 8 ciudades en evaluacion

#############################################################################
##### asignamos una id a cada ciudad##### ###################################
#############################################################################

## AlphaCentauri  = 1
## Faerun = 2
## Norrath = 3
## Snowdin = 4
## Straylight = 5
## Tambi = 6
## Tristram = 7
## Arbre = 8

head(rutas_2)
nrow(rutas)

origen<-rep(0,nrow(rutas))
destino<-rep(0,nrow(rutas))

rutas_2<-data.frame(rutas,origen,destino)

rutas_2$origen[rutas_2$V1=="AlphaCentauri"] <-1
rutas_2$origen[rutas_2$V1=="Faerun"] <-2
rutas_2$origen[rutas_2$V1=="Norrath"] <-3
rutas_2$origen[rutas_2$V1=="Snowdin"] <-4
rutas_2$origen[rutas_2$V1=="Straylight"] <-5
rutas_2$origen[rutas_2$V1=="Tambi"] <-6
rutas_2$origen[rutas_2$V1=="Tristram"] <-7
rutas_2$origen[rutas_2$V1=="Arbre"] <-8

rutas_2$destino[rutas_2$V3=="AlphaCentauri"] <-1
rutas_2$destino[rutas_2$V3=="Faerun"] <-2
rutas_2$destino[rutas_2$V3=="Norrath"] <-3
rutas_2$destino[rutas_2$V3=="Snowdin"] <-4
rutas_2$destino[rutas_2$V3=="Straylight"] <-5
rutas_2$destino[rutas_2$V3=="Tambi"] <-6
rutas_2$destino[rutas_2$V3=="Tristram"] <-7
rutas_2$destino[rutas_2$V3=="Arbre"] <-8


#############################################################################
##### Matriz de distancias entre ciudades ###################################
#############################################################################

matriz_distancias <- matrix(0, 8, 8)

for(i in 1:8)
{
    for(j in 1:8)
    {
        fila<-subset(rutas_2,origen==i & destino==j)
        distancia<-fila[1,5]
        if(!is.na(distancia))
        {
        matriz_distancias[i,j]<-distancia
        matriz_distancias[j,i]<-distancia
        }   
    }
}



#############################################################################
##### Generamos matriz con las posibles combinaciones de visita #############
#############################################################################

library(gtools)
ciudades<-c(1:8)

N <- 8  # Número de ciudaes
n <- 8 # grupos 8 eb 8
rutas_final <- as.data.frame(permutations(N, n, ciudades))
d1<-rep(0,nrow(rutas_final))
d2<-rep(0,nrow(rutas_final))
d3<-rep(0,nrow(rutas_final))
d4<-rep(0,nrow(rutas_final))
d5<-rep(0,nrow(rutas_final))
d6<-rep(0,nrow(rutas_final))
d7<-rep(0,nrow(rutas_final))
recorrido<-rep(0,nrow(rutas_final))

rutas_distancia<-data.frame(rutas_final,d1,d2,d3,d4,d5,d6,d7,recorrido)

#############################################################################
##### Comppletado de distancias #############################################
#############################################################################

for(i in 1:(nrow(rutas_distancia)))
{
    for(j in 1:7)
    {
        rutas_distancia[i,j+8]<-matriz_distancias[rutas_distancia[i,j],rutas_distancia[i,j+1]]
    }

        rutas_distancia[i,16]<-rutas_distancia[i,9]+rutas_distancia[i,10]+rutas_distancia[i,11]+rutas_distancia[i,12]+rutas_distancia[i,13]+rutas_distancia[i,14]+rutas_distancia[i,15]

}

head(rutas_distancia)


#############################################################################
##### Seleccionando rutas ###################################################
#############################################################################
summary(rutas_distancia)
min(rutas_distancia$recorrido)

recorridos_minimos<-subset(rutas_distancia,recorrido==min(rutas_distancia$recorrido))

for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==1) {recorridos_minimos[i,j]<-"AlphaCentauri"}}
}
for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==2) {recorridos_minimos[i,j]<-"Faerun"}}
}
for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==3) {recorridos_minimos[i,j]<-"Norrath"}}
}
for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==4) {recorridos_minimos[i,j]<-"Snowdin"}}
}
for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==5) {recorridos_minimos[i,j]<-"Straylight"}}
}
for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==6) {recorridos_minimos[i,j]<-"Tambi"}}
}
for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==7) {recorridos_minimos[i,j]<-"Tristram"}}
}
for(i in 1:(nrow(recorridos_minimos)))
{    
    for(j in 1:8) {if(recorridos_minimos[i,j]==8) {recorridos_minimos[i,j]<-"Arbre"}}
}

#############################################################################
##### Resultado final ### ###################################################
#############################################################################

recorridos_minimos

## Se tiene el siguiente recorrido 
## Tristram->AlphaCentauri->Norrath->Straylight->Faerun->SnowdinTambi->Arbre
## con una distancia de 141




