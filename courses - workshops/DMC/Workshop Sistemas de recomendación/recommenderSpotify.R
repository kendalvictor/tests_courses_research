# author: Alex Rayón
# date: Marzo, 2020

# Antes de nada, limpiamos el workspace, por si hubiera algún dataset o información cargada
rm(list = ls())

# Cambiar el directorio de trabajo
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Cargamos las librerías que vamos a necesitar
library(Rspotify)
library(httr)
library(jsonlite)

# Por si no tenéis una cuenta:
#   https://developer.spotify.com/dashboard/applications
# No olvidéis poner http://localhost:1410/ en Redirect URIs
clientID = "b09f00c65d9a49c2a14dfad4cd45fd17"
secret = "c503b0756f8a4dfbbf4308be57cac5cf"

# Hacemos la petición para autenticarnos
response = POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(clientID, secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)

# Obtenemos el token para el resto del script
token = content(response)$access_token
authorization.header = paste0("Bearer ", token)

# https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/
# https://developer.spotify.com/console/get-recommendations/

# Seed tracks and artists: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids

# Vamos a obtener las características de una canción
caracteristicasCancion <- GET("https://api.spotify.com/v1/audio-features/3mlXNKuh6ijI4ZdhEp2sV6",
                              config = add_headers(authorization = authorization.header))
caracteristicasCancion$status_code
caracteristicasCancion
caracteristicas <-  fromJSON(content(caracteristicasCancion,"text"))
caracteristicas

url=paste0("https://api.spotify.com/v1/recommendations?market=ES&seed_artists=3heR1it0slFXjaa7E62zpw&min_energy=0.4&min_popularity=50")
# Hacemos la llamada a la API
llamada <- GET(url,config = add_headers(authorization = authorization.header))
llamada$status_code
llamada

# Lo convertimos a un dataframe
respuesta <-  fromJSON(content(llamada,"text"))
datos<-as.data.frame(respuesta$tracks)
