######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################
############################################
# ANÁLISIS DE VARIANZA - ANOVA #############
############################################
#####################################
## Laboratorio de Aplicación N° 02 ##
#####################################

# Objetivos del taller:
# 1.- Aplicar lo desarrollado en las clases teórico prácticas
# 2.- Plantearse interrogantes respecto al Analisis de Varianza.

# Trabajo :
# Desarrolle un análisis de regresión lineal simple con la siguiente data,como mínimo 
# debe tener lo siguiente:

#a) Análisis exploratorio previo, es decir justificación del Analisis de Varianza.
#b) Realizar el ANOVA. Interprete los resultados.
#c) Compruebe los supuestos del ANOVA.


## Data de Analisis ##
# La respuesta es la longitud de los odontoblastos (células responsables del crecimiento de los dientes) en 60 cuyes.
# Cada animal recibió uno de los tres niveles de dosis de vitamina C (0.5, 1 y 2 mg / día) mediante uno de los dos métodos
# de administración: jugo de naranja o ácido ascórbico (una forma de vitamina C y codificada como VC).

# Elegir una de las 2 variables referidas como factores o tratamientos y realizar el ANOVA.
data(ToothGrowth)
str(ToothGrowth) #Tenemos dos variables numericas y un factor


