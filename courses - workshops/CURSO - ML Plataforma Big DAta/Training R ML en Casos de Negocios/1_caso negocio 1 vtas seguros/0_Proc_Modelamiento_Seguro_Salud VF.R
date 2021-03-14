.libPaths()

#-----------------------------------------------
#-----------------------------------------------
# 0. Cargando los datos
#-----------------------------------------------
#-----------------------------------------------

### XLS: 0. DS_Seguros_Salud.xls

### XLS: 1. Analisis y modelamiento.xlsx

Seguros_Salud<-DS_Seguros_Salud

nrow(Seguros_Salud)
ncol(Seguros_Salud)
head(Seguros_Salud)
str(Seguros_Salud)
summary(Seguros_Salud)

1026/45798*100

  #Asignando el tipo de variables Categoricas
  Seguros_Salud$VENTA_SEGURO<-as.factor(Seguros_Salud$VENTA_SEGURO)
  Seguros_Salud$MES_T0<-as.factor(Seguros_Salud$MES_T0)
  Seguros_Salud$SEXO<-as.factor(Seguros_Salud$SEXO)
  Seguros_Salud$DEPARTAMENTO<-as.factor(Seguros_Salud$DEPARTAMENTO)

#--------------------------------------------
#--------------------------------------------
# 1. Exploracion de los datos cargado y sus valores nulos
#--------------------------------------------
#--------------------------------------------

    # Libreria de Exploracion
    #--------------------------
library(DescTools)
library(RDCOMClient)
    
  install.packages("RDCOMClient",repos = "http://www.omegahat.net")
  
  wrd<-GetNewWrd()
  Desc(Seguros_Salud,wrd=wrd)

  Desc(Seguros_Salud)
       
       
  ### WRD 1.1. Exploracion Describe Seguros.docx
  
   # Completando los valores nulos
   #------------------------

    Seguros_Salud$NUM_TC_TOTAL_T2[is.na(Seguros_Salud$NUM_TC_TOTAL_T2)]<-0
    Seguros_Salud$SALDO_BCO_T2[is.na(Seguros_Salud$SALDO_BCO_T2)]<-0
    Seguros_Salud$LINEA_BCO_T2[is.na(Seguros_Salud$LINEA_BCO_T2)]<-0
    Seguros_Salud$USO_LINEA_BCO_T2[is.na(Seguros_Salud$USO_LINEA_BCO_T2)]<-0
    Seguros_Salud$monto_ope_t2[is.na(Seguros_Salud$monto_ope_t2)]<-0
    Seguros_Salud$PROM_ANUAL_MTO_OPERA[is.na(Seguros_Salud$PROM_ANUAL_MTO_OPERA)]<-0
    Seguros_Salud$MAX_MTO_OPERA_Anual[is.na(Seguros_Salud$MAX_MTO_OPERA_Anual)]<-0
    Seguros_Salud$Ratio_HospvsMtoTotal_t2[is.na(Seguros_Salud$Ratio_HospvsMtoTotal_t2)]<-0
    Seguros_Salud$Nro_CTa_Ahorro_Bco_T1[is.na(Seguros_Salud$Nro_CTa_Ahorro_Bco_T1)]<-0
    Seguros_Salud$Ahorro_Sldo_Bco_T1[is.na(Seguros_Salud$Ahorro_Sldo_Bco_T1)]<-0

    ### WRD 1.2. Exploracion Describe Seguros.docx
        
  #https://stackoverflow.com/questions/13234005/filling-missing-values  

#------------------------------    
#------------------------------
# 2. Deficion de muestras
#------------------------------
#------------------------------
    
    # Se define 2 muestra, las que se denominan de aprendizaje y validación

   library(caret)
  library(randomForest)
    
    #-----------------------------------------------------
    DF<-Seguros_Salud
    
    splitIndex <- createDataPartition(DF$VENTA_SEGURO, p = .50,
                                      list = FALSE,
                                      times = 1)
    Data_train<- DF[ splitIndex,]
    Data_test<- DF[-splitIndex,]

    nrow(Data_train)    
    nrow(Data_test)

    str(Data_train)
    
#--------------------------------------
# 3. Seleccion de variables importantes  
#--------------------------------------
    # Cargando las librerias
    library(randomForest)
    #library(mlbench)
    library(caret)

    ### XLS: 2 Importancia de variables.xlsx
    
    # Exploracion de variables importantes con el algoritmo Random Forest
    results <- randomForest(VENTA_SEGURO~.,data=Data_train,na.action=na.omit,importance=TRUE,do.trace=FALSE,ntree=100)
    varImpPlot(results,type=2,main=paste("Relevancias de variables"),col="blue",n.var=15)
    
    # Revision variables importantes seleccionadas 
    #------------------------------------------
    # Antiguedad del cliente
    Desc(VENTA_SEGURO~ANTIGUEDAD_MES,data=Data_train, digits=2, breaks=5, margin=TRUE, conf.lel=0.9)
    quantile(Data_train$ANTIGUEDAD_MES, probs = c(0.2, 0.4,0.6,0.8))
             
    # %Mto en hospitales
    Desc(VENTA_SEGURO~Ratio_HospvsMtoTotal_t2,data=Data_train, digits=2, breaks=5, margin=TRUE, conf.lel=0.9)
    quantile(Data_train$Ratio_HospvsMtoTotal_t2, probs = c(0.2, 0.4,0.6,0.8))

    
#----------------------------------------------
# 4. Evaluacion de modelo REGRESiON LOGISTICA
#----------------------------------------------

    ### 3 Analisis de Reg Logistica.xlsx
    
    
    # Listado de todas la variables
    "VENTA_SEGURO ~ ANTIGUEDAD_MES + PROM_ANUAL_MTO_OPERA + Ahorro_Sldo_Bco_T1 + monto_ope_t2 + DEPARTAMENTO + LINEA_BCO_T2 + SOW_BCO_SEMESTRAL"
    
    
      # Modelamiento de mediante la Reg. Logistica
      lr_model	<-	train(VENTA_SEGURO ~ ANTIGUEDAD_MES + PROM_ANUAL_MTO_OPERA + Ahorro_Sldo_Bco_T1 ,	data=Data_train,	method="glm", family="binomial")
      importance	<-	varImp(lr_model,	scale=FALSE) 
      plot(importance)
      
      # Validacion Aprendizaje  de pronsoticos
      library(Epi)
      pred_log <- predict(lr_model, Data_train,type="prob")
      ROC(pred_log[,2],Data_train$VENTA_SEGURO)
    
    # Exportando resultados
    DD<-cbind(Data_train[,c("ANTIGUEDAD_MES","PROM_ANUAL_MTO_OPERA","VENTA_SEGURO")],prob_1=pred_log[,2],rank=rank(pred_log[,2]))
    
    head(DD)
    
    setwd("E:/B_CURSOS PARA DICTAR/B_M1_INTRODUCCION_MARKETING_ANALYTICS/6. DS Sesion 6/1_Caso Seguros Salud")
    write.csv(DD, file = "Datos_Logist.csv")
    

#----------------------------------------------
# 4. Evaluacion de modelo ARBOL CLASIFICACION
#----------------------------------------------
    
    ### XLS 4. Analisis de Arbol.xlsx
    
   library(rpart)
   library(partykit)   
   library(rpart.plot)
    
    # Listado de todas las variables  
    "VENTA_SEGURO ~ ANTIGUEDAD_MES + PROM_ANUAL_MTO_OPERA + Ahorro_Sldo_Bco_T1 + monto_ope_t2 + DEPARTAMENTO + LINEA_BCO_T2 + SOW_BCO_SEMESTRAL"
    
    # min.split: El numero minimo de observacioines en cada nodo
    # cp alto -> pocos cortes
    # cp bajo -> muchos cortes
    tree_model	<-	rpart(VENTA_SEGURO ~ ANTIGUEDAD_MES + PROM_ANUAL_MTO_OPERA + Ahorro_Sldo_Bco_T1 + monto_ope_t2 +  LINEA_BCO_T2  ,	data=Data_train,	method="class", control=rpart.control(minsplit=20,cp=0.015))
    rpart.plot(tree_model, type = 3)  
    plot(as.party(tree_model))
    
    # todo cp=0.0015
      
    # Validacion Aprendizaje  
    library(Epi)
    pred_log <- predict(tree_model, Data_train,type="prob")
    ROC(pred_log[,2],Data_train$VENTA_SEGURO)
    

    # Exportando resultados
    DD_tree<-cbind(Data_train[,c("ANTIGUEDAD_MES","PROM_ANUAL_MTO_OPERA","VENTA_SEGURO")],prob_1=pred_log[,2],rango=rank(pred_log[,2]))
    head(DD_tree)
    setwd("E:/B_CURSOS PARA DICTAR/B_M1_INTRODUCCION_MARKETING_ANALYTICS/6. DS Sesion 6/1_Caso Seguros Salud")
    write.csv(DD_tree, file = "Datos_arbol.csv")
    
#----------------------------------    
# 5. Descrion de las variables
#----------------------------------
    
    library(DescTools)
    library(RDCOMClient)
    
    # Antiguedad del cliente
    Desc(VENTA_SEGURO~ANTIGUEDAD_MES,data=Data_train, digits=2, breaks=5, margin=TRUE, conf.lel=0.9)
    quantile(Data_train$ANTIGUEDAD_MES, probs = c(0.2, 0.4,0.6,0.8))
    
    Desc(VENTA_SEGURO~PROM_ANUAL_MTO_OPERA,data=Data_train, digits=2, breaks=5, margin=TRUE, conf.lel=0.9)
    quantile(Data_train$PROM_ANUAL_MTO_OPERA, probs = c(0.2, 0.4,0.6,0.8))
    
    Desc(VENTA_SEGURO~Ahorro_Sldo_Bco_T1,data=Data_train, digits=2, breaks=5, margin=TRUE, conf.lel=0.9)
    quantile(Data_train$Ahorro_Sldo_Bco_T1, probs = c(0.2, 0.4,0.6,0.8))
    
    Desc(VENTA_SEGURO~DEPARTAMENTO,data=Data_train, digits=2, breaks=5, margin=TRUE, conf.lel=0.9)
    quantile(Data_train$DEPARTAMENTO, probs = c(0.2, 0.4,0.6,0.8))
    
    table(Data_train$VENTA_SEGURO,Data_train$DEPARTAMENTO)
    
    Desc(VENTA_SEGURO~LINEA_BCO_T2,data=Data_train, digits=2, breaks=5, margin=TRUE, conf.lel=0.9)
    quantile(Data_train$LINEA_BCO_T2, probs = c(0.2, 0.4,0.6,0.8))

    #----------------------------------------- 
    #-----------------------------------------    
    # 6. Desarrollo de presentacion gerencial
    #-----------------------------------------
    #----------------------------------------- 
    
        