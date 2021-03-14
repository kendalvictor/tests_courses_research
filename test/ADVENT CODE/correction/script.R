setwd("C:/Users/FIEECS/Desktop")
datos<-read.table("rutas.txt",sep=".",header=F)
i<-1
datos$V1<-as.character(datos$V1)
for(i in 1:nrow(datos)){
  datos[i,2]<-strsplit(datos[i,1]," ")[[1]][1]
  datos[i,3]<-strsplit(datos[i,1]," ")[[1]][3]
  datos[i,4]<-strsplit(datos[i,1]," ")[[1]][5]
  
}
head(datos)
datos<-datos[,-1]
head(datos)
install.´pac