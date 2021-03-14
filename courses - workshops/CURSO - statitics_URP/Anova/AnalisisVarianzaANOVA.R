######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################
############################################
# ANÁLISIS DE VARIANZA : ANOVA #############
############################################


#Los Análisis de Varianza (ANDEVA o ANOVA) permiten evidenciar la influencia de un determinado factor o grupo de 
#factores (variables nominales) sobre una variable respuesta (variable continua). Para ello, se comparan efectos 
#que las distintas dosis o niveles del factor producen en la respuesta.

# PRUEBAS PARAMETRICAS

#Para realizar un ANOVA con prueba F (de Fischer) se debe cumplir algunos supuestos fundamentales tales como:
        
#Aleatoriedad (dependiendo del Modelo)
#Homogeneidad de los residuos
#Normalidad de los residuos

#El ANOVA descompone la variabilidad de la variable de respuesta entre los diferentes factores. Dependiendo del tipo 
#de análisis, puede ser importante determinar: 
# (a) los factores que tienen un efecto significativo sobre la respuesta, 
# (b) la cantidad de la variabilidad en la variable de respuesta es atribuible a cada factor.

################
# Ejemplo 01####
################

#Introducimos nuestros datos
dieta1<-c(198,211,240,189,178)
dieta2<-c(214,200,259,194,188)
dieta3<-c(174,176,213,201,158)


#Agrupamos las dietas a un solo vector
dietas<- c(dieta1,dieta2,dieta3)
dietas

#Distribuimos los valores, segun los tratamientos
trats <- gl(3,5,label=c("dieta1","dieta2","dieta3")) #3 tratamientos, 5 valores que corresponden a la variabnle del "peso" de la dieta.
length(trats)==length(dietas) #verificamos que tanto los facores como variables dependientes sean del mismo tamaño.

is.numeric(trats)
is.factor(trats) #Confirmamos si tratamientos es un factor

anova1 <- aov(dietas~trats) #Aplicamos el ANOVA PARAMETRICO
summary(anova1) #Nos brinda un resumen del ANOVA

#para este grafica, se requiere los datos en un data.frame. Además, me permite renombrar los ejes. 
di<-data.frame(dietas, trats)
library(ggplot2)
windows()
p <- ggplot(di, aes(factor(trats), dietas))
p +scale_y_continuous(name = "Peso (libras)") + scale_x_discrete(name="Tratamientos")+ geom_boxplot()


# Supuestos en el ANOVA
windows()
par(mfrow=c(2,2)) #Particiona mi ventana grafica
plot(anova1) #Contrasta los supuestos del ANOVA, de forma grafica


# SUPUESTOS DEL  ANOVA

#NORMALIDAD DE LOS RESIDUALES O RESIDUOS

reg<-lm(dietas~trats) #permite obtener el modelo de regresión lineal
residuos<-residuals(reg) #Estima los residuos
shapiro.test(residuos) 


#HOMOGENEIDAD DE LAS VARIANZAS

## Bartlett Test de Homogeneidad de Varianzas
bartlett.test(dietas~trats)

# Otra prueba de Homogeneidad de Varianzas
# Figner-Killeen Test of Homogeneity of Variances, para datos no paramétricos
fligner.test(dietas~trats)


## Levene Test de Homogeneidad de Varianzas
library(car)
leveneTest(dietas~trats)


# TEST POST - HOC

TukeyHSD(anova1) #Calcula la prueba de Tukey

windows()
plot(TukeyHSD(anova1)) #Genera un plot para Tukey


# ANOVA NO PARAMETRICO

# Cuando no cumple con algún supuesto anterior. Aunque se recomienda utilizar la Prueba de Kruskall-Wallis.
#cuando las varianzas son homogéneas.

kruskal.test(dietas~trats)

###################
# Ejemplo 02#######
###################

data(InsectSprays)
attach(InsectSprays)
str(InsectSprays) #Permite ver las características de las variables

InsectSprays2 <- 
        InsectSprays[(InsectSprays$spray=="C"|
                      InsectSprays$spray=="D"|
                      InsectSprays$spray=="E"),]
str(InsectSprays2)
tapply(count, spray, mean) #Permite ver la media de los factores (Tratamientos)

tapply(count, spray, sd) #Permite ver la desviación estándar de los factores

tapply(count, spray, length) #Permite ver la cantidad de datos.

library(ggplot2)
windows()
boxplot(count ~ spray, data=InsectSprays2, col="16", xlab="Tipos de Spray", ylab="Cantidad de Insectos")

# El mismo grafico pero con diseño
windows()
ggplot(InsectSprays,aes(spray, count, colour = spray ))+geom_point() + geom_boxplot()

# Realizamos el Analisis de ANOVA

andeva3<-aov(count~spray, data=InsectSprays2)
summary(andeva3)

# COMPARACIONES POST HOC

# Cuando tenemos sospecha de un posible resultado del análisis, es decir que entre grupos esperamos encontrar 
# diferencias.

# Ejm: cuando en un experimento hay un grupo control, a otro se le aplica un medicamento y otro grupo se le suministra 
# mayor cantidad de un medicamento experimental. Posiblemente sospechemos que vamos a tener resultados diferentes 
# (esto es lo que se entiende en el diseño de muestreo como un Experimento Planeado


TukeyHSD(andeva3)

# Graficamos las diferencias entre los distintos niveles de Spray
windows()
plot(TukeyHSD(andeva2),  cex.axis=.7)

# Comprobamos los supuestos del modelo de ANOVA
windows()
par(mfrow=c(2,2)) #Particiona mi ventana grafica
plot(andeva2)

# Normalidad
shapiro.test(residuals(andeva2))


# Homogeneidad de Varianzas
#Homogeneidad de varianzas
library(car)
leveneTest(andeva2)

### FIN ####





