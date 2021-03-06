rm(list=ls())

#########################################################################
### -- STATISTICAL SCIENCE INTRODUCTION --## 
#########################################################################
### Autor: Jose Cardenas - Andre Chavez ## 
### Modelo II: FUENTE DE DATOS ##

#########################################################################

# TEMAS A TOCAR:
# .	Importaci�n de datos de diversas fuentes : Archivos de Texto, Access, 
#   Formatos Excel, Archivos No Estructurados Json, etc.
# .	Conexi�n de R y Python con SQL. Errores en la adquisici�n de datos.
# .	Tipos de Datos. Variables Categ�ricas, Num�ricas, Discretas, Continuas.


## Importaci�n de datos

## TIPOS DE DATOS CSV, TXT
datos <- read.table(file = "datos_ejemplos.csv",
                    header = TRUE,
                    col.names = c("fecha", "cliente", "producto", "precio"),
                    stringsAsFactors = FALSE,
                    sep = ",",
                    dec = ".")


# La funci�n read.table tiene muchas opciones al momento de leer archivos. Las m�s importantes son:
#   
# file: ubicaci�n del archivo.
# header: si posee o no una fila con los nombres de las columnas.
# col.names: indicamos manualmente el nombre de las columnas de nuestro data frame. Dado que en este caso el archivo ya lo incluye, resulta redundante.
# stringsAsFactors: por defecto, los campos de texto se los trata como factor. Si queremos que se los trate como cadenas ponemos este argumento a FALSE.
# sep: seleccionamos el s�mbolo que se utiliza para delimitar las columnas.
# dec: indicamos el s�mbolo que se utiliza para la representaci�n decimal.

datos <- read.table(file = "PrecioVivienda.txt",
                    header = TRUE)

## CARGA DE GRANDES VOLUMENES
library(data.table)
datos <- fread(input = "C:/Users/Mauricio/Desktop/datos_ejemplos.csv",
               header = TRUE, 
               col.names = c("fecha", "cliente", "producto", "precio"),
               data.table = FALSE,
               sep = ",",
               dec = ".",
               showProgress = TRUE)

datos <- fread(input = "carros2011imputado.csv",
               header = TRUE, 
               showProgress = TRUE)

# Luego, para ver el resto de opciones disponibles debemos ir a la documentaci�n ??? ?read.table.
# 
# Una alternativa que se puede emplear es la funci�n fread (del paquete data.table). 
# Esta funci�n es mucho m�s r�pida para cargar los datos que la primera, por lo que 
# se recomienda su utilizaci�n si el tama�o del archivo de datos es grande, mayor a 1Gb. 
# Para archivos m�s peque�os, la diferencia de velocidad es despreciable.

# La opci�n showProgress muestra en pantalla muestra el avance en la tarea de lectura del archivo.
# Por otro lado, la opci�n data.table la ponemos a FALSE para que el archivos sea tratado
# como un data frame. De otro modo, se carga en una estructura llamada data.table que no 
# hemos visto hasta el momento. Esta estructura es similar a un data frame, pero con varias
# mejoras mejoras. En alg�n post futuro hablar� m�s de ella.

## EXCEL
?read.xlsx # Ya esta sin uso
read.xlsx(file = "C:/Users/Mauricio2/Desktop/planilla_excel_ejemplo.xlsx", sheetIndex = 1)

library(readxl)
data <- read_excel("bostonvivienda.xlsx")

# JSON
library(jsonlite)
archivo <- "C:/Users/Mauricio2/Desktop/r_ejemplo_json.json"
con <- file(archivo, open="r")
ejemplo_json <- readLines(con)
close(con)
datos <- fromJSON(ejemplo_json)

fromJSON(ejemplo_json)

# SPSS
library(foreign)
datos=read.spss("RIESGO CREDITICIO.sav",use.value.labels=TRUE, max.value.labels=TRUE,to.data.frame=TRUE)
str(datos)


## CONEXION DE R - SQL

library(RODBC)
canal_bd <- odbcDriverConnect('driver={SQL Server};
                              server=(local);
                              database=BD_FINANCIERA;
                              trusted_connection=true')
resultado <- sqlQuery(canal_bd, 'select * from BD_FINANCIERA.dbo.BD_CLIENTE')  
odbcClose(canal_bd)
names(resultado)

# library(RODBC)
# canal_bd <- odbcDriverConnect('driver={SQL Server};
#                               server=localhost;
#                               database=master;
#                               trusted_connection=true')
# resultado <- sqlQuery(canal_bd, 'select * from master.dbo.spt_monitor')  
# odbcClose(canal_bd)
# names(resultado)

###  Tipos de Datos

# Numericas : cuantitativas: discretas - continuas
# categoricas: cualitativas: Nominal - Ordinal

library(mlr)
summarizeColumns(data_f)

tabla <- summarizeColumns(data_f)
write.csv(tabla , "Tabla_resumen.csv",row.names = F)


# CARGA DE LA DATA A UTILIZAR
data=read.csv("train.csv")

str(data)

?as.numeric
?as.factor
