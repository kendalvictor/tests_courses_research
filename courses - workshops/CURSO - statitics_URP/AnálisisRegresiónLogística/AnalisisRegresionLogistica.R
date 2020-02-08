rm(list=ls())
######################################################
# TALLER DE ESTADISTICA PARA CIENCIA DE DATOS ########
# PROFESOR : ANDRÉ CHÁVEZ - JOSE CARDENAS
######################################################
#### -- 1) Librerias a usar ####
library("ggplot2")
library(glmnet)
library(readxl)
library(caret)
library(pROC)
library(DMwR)
library(ggvis)
library(pROC)
library(caret)
library(ROCR)
library(mlr)
library(gmodels)
library(gplots)
library(DMwR)
library(class)

#### Modelo de Regresion Logistica

## Cargar la data


Train=read.csv("train_t.csv")
str(Train)
Train$Loan_Status<-as.factor(Train$Loan_Status)
## Observar aleatoriamente 3 valores de la data

sample_n(Train, 3)

## supuestos

cor(Train[,1:8])

## Particion Muestral

set.seed(123)
training.samples <- Train$Loan_Status %>% 
  createDataPartition(p = 0.8, list = FALSE)
train.data  <- Train[training.samples, ]
test.data <- Train[-training.samples, ]

## Modelado

modelo_logistica=glm(Loan_Status~.,data=train.data,family="binomial" )
summary(modelo_logistica)


## indicadores

proba1=predict(modelo_logistica, newdata=test.data,type="response")
AUC1 <- roc(test.data$Loan_Status, proba1)
## calcular el AUC
auc_modelo1=AUC1$auc
## calcular el GINI
gini1 <- 2*(AUC1$auc) -1
# Calcular los valores predichos
PRED <-predict(modelo_logistica,test.data,type="response")
PRED=ifelse(PRED<=0.5,0,1)
PRED=as.factor(PRED)
# Calcular la matriz de confusi?n
tabla=confusionMatrix(PRED,test.data$Loan_Status,positive = "1")
# sensibilidad
Sensitivity1=as.numeric(tabla$byClass[1])
# Precision
Accuracy1=tabla$overall[1]
# Calcular el error de mala clasificaci?n
error1=mean(PRED!=test.data$Loan_Status)

# indicadores
auc_modelo1
gini1
Accuracy1
error1
Sensitivity1


# FIN