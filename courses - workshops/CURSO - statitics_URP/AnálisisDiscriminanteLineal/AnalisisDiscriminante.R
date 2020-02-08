######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################
############################################
# ANÁLISIS DISCRIMINANTE LINEAL ############
############################################

# Leemos la informacion de clientes #
data<-read.table("BancoCliente.csv",header=T,
                 sep=",",fill=T)
data<-data[,c(1,2,5,7,11,15,20)]
# La variable target o variable de prediccion siempre debe ser factor
str(data$Flg_TC)
data$Flg_TC<-as.factor(data$Flg_TC)
# Exploracion grafica de los datos
library(ggplot2)
library(ggpubr)

# Grafico la Variable respuesta con las covariables
windows()
ggplot(data = data, aes(x = data$Edad, fill = Flg_TC)) +
        geom_histogram(position = "identity", alpha = 0.5,bins = 30)

windows()
ggplot(data = data, aes(x = RFM_Score, fill = Flg_TC)) +
        geom_histogram(position = "identity", alpha = 0.5,bins = 30)

windows()
ggplot(data = data, aes(x = Meses_Cuenta_Sueldo, fill = Flg_TC)) +
        geom_histogram(position = "identity", alpha = 0.5,bins = 30)

windows()
ggplot(data = data, aes(x = Nro_Llamadas_CC, fill = Flg_TC)) +
        geom_histogram(position = "identity", alpha = 0.5,bins = 30)

windows()
ggplot(data = data, aes(x = IngresoReal, fill = Flg_TC)) +
        geom_histogram(position = "identity", alpha = 0.5)

# Analisis Bivariado de los datos
# Podemos visualizar que variables pueden discriminar las clases?
windows()
pairs(x = data[, c("Edad","RFM_Score","Meses_Cuenta_Sueldo","Nro_Llamadas_CC","IngresoReal")],
      col = c("firebrick", "green3")[data$Flg_TC], pch = 19)


library(scatterplot3d)
windows()
scatterplot3d(data$Edad, data$RFM_Score, data$IngresoReal,
              color = c("firebrick", "green3")[data$Flg_TC], pch = 19,
              grid = TRUE, xlab = "Edad", ylab = "RFM",
              zlab = "Ingreso", angle = 65, cex.axis = 0.6)
legend("topleft",
       bty = "n", cex = 0.8,
       title = "Estado de la TC",
       c("a", "b"), fill = c("firebrick", "green3"))

# Conclusiones ?

# Representación mediante Histograma de cada variable para cada estado
windows()
par(mfcol = c(2, 6))
for (k in 2:6) {
        j0 <- names(data)[k]
        x0 <- seq(min(data[, k]), max(data[, k]), le = 50)
        for (i in 1:2) {
                i0 <- levels(data$Flg_TC)[i]
                x <- data[data$Flg_TC == i0, j0]
                hist(x, proba = T, col = grey(0.8), main = paste("Estado TC", i0),
                     xlab = j0)
                lines(x0, dnorm(x0, mean(x), sd(x)), col = "red", lwd = 2)
        }
}

# Representación de cuantiles normales de cada variable para cada estado prestamo
windows()
par(mfcol = c(2, 6))
for (k in 2:6) {
        j0 <- names(data)[k]
        x0 <- seq(min(data[, k]), max(data[, k]), le = 50)
        for (i in 1:2) {
                i0 <- levels(data$Flg_TC)[i]
                x <- data[data$Flg_TC == i0, j0]
                qqnorm(x, main = paste("Estado TC", i0, j0), pch = 19, col = i + 1)
                qqline(x)
        }
}


# Aplicamos el LDA 

library(MASS)
modelo_lda <- lda(formula = Flg_TC ~ .,
                  data = data[,2:7])


# Resumen del Modelo LDA
modelo_lda

# Aplicamos el Modelo QDA
modelo_qda <- qda(formula = Flg_TC ~ .,
                  data = data[,2:7])

modelo_qda

# Debido a que el analisis discriminante lineal es un modelo de clasificacion,
# usamos una metodologia de ML

library(caret)

# Partimos la data total en entranamiento y test
sample <-caret::createDataPartition(data$Flg_TC, 
                              p = .70,list = FALSE, # porcentaje de train
                              times = 1)

data.train <- data[ sample,] # Data de Entrenamiento
data.test <- data[-sample,] # Data de Test

# Entrenamos un modelo con la data de entrenamiento !!
modelo.lda.caret <- caret::train(Flg_TC ~ ., 
                          method ='lda',data = data[,2:7] )
 
modelo.lda.caret

# Evaluación del modelo LDA con los datos de test
lda.pred <-  predict(modelo.lda.caret, newdata = data.test)

# Procedemos a realizar una matriz de clasificacion
table(data.test$Flg_TC, lda.pred , dnn = c("Clase Real", "Clase Predicha"))

# Podemos tambien usar la libreria caret
confusionMatrix(lda.pred,data.test$Flg_TC)

# LDA respecto a los datos de entrenamiento usados en el modelo

plot(modelo.lda.caret)

library(klaR)
# Representación del LDA respecto a los datos de test
partimat(formula = as.factor(Flg_TC) ~ Edad, 
         data = data.test, method = "lda", prec = 400, 
         image.colors = c("darkgoldenrod1", "skyblue2"), 
         col.mean = "firebrick", nplots.vert = 2)

###  FIN ####

