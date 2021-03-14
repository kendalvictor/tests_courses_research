#===========================================================================================
#
#                                 ECONOMETRÍA FINANCIERA
#
#                               INTERACTUANDO CON RSTUDIO
#
#===========================================================================================
#
#       Autor: Abdel Arancibia
#
#===========================================================================================

# Librerías a utilizar
#
#   1) quantmod
#   2) PerformanceAnalytics

# Instalando librerías
  #install.packages("quantmod")
  #install.packages("PerformanceAnalytics")
  
# Llamando librerías
  library(quantmod)
  library(PerformanceAnalytics)
  
# Descargando datos de Yahoo Finance
  getSymbols.yahoo('AAPL', env = globalenv(), return.class = "xts", from = '2002-01-01', to = Sys.Date(), periodicity = 'daily')

# Charting    
  chartSeries(AAPL, theme = "white")
  chartSeries(AAPL, type = "candlesticks", theme = "white", TA='addBBands(); addBBands(draw="p"); addVo(); addMACD(); addRSI(); addSMA()', subset = 'last 50 weeks')

# Utilizando librería Performance Analytics
  chart.TimeSeries(AAPL$AAPL.Adjusted, main = "APPLE")
  
  # Calculando retornos
    APPL_Ret = Return.calculate(AAPL$AAPL.Adjusted, method = "compound")
    APPL_Ret = APPL_Ret[-1,]
  
    chart.TimeSeries(APPL_Ret, main="Retornos de Apple")
  

    acf(APPL_Ret)
    pacf(APPL_Ret)
    
    