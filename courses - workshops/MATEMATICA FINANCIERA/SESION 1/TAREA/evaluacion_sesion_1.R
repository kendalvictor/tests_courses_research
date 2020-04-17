#===========================================================================================
#
#                                 ECONOMETR?A FINANCIERA
#
#                               EVALUACION SESION 1
#
#===========================================================================================
#
#       Alumno Victor Villacorta
#
#===========================================================================================

library('tseries')
library(quantmod)
library(PerformanceAnalytics)
#BASIC
#===========================================================================================
#1
precio_msft = get.hist.quote(instrument = 'MSFT', quote = c("Open", "High", "Low", "Close"), start = '2020-01-01')
plot(precio_msft)
# ANALISIS: 

getSymbols.yahoo('MSFT', env = globalenv(), return.class = "xts", from = '2002-01-01', to = Sys.Date(), periodicity = 'daily')
plot(MSFT)


