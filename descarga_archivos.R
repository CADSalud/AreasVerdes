# Mario Becerra
# 22 junio 2016
# Modificado el 13 de julio de 2016

#### Shapefiles de cartografía de estados

library(dplyr)

URLs <- c(
  'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Aguascalientes/702825209025_s.zip',
  'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Baja_California/702825209032_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Baja_California_Sur/702825209049_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Campeche/702825209056_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Chiapas/702825209063_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Chihuahua/702825209070_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Distrito_Federal/702825209100_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Coahuila_de_Zaragoza/702825209087_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Colima/702825209094_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Durango/702825209117_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Guanajuato/702825209124_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Guerrero/702825209131_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Hidalgo/702825209148_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Jalisco/702825209155_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Michoacan_de_Ocampo/702825209179_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Morelos/702825209186_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Mexico/702825209162_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Nayarit/702825209193_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Nuevo_Leon/702825209209_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Oaxaca/702825209216_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Puebla/702825209223_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Queretaro/702825209230_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Quintana_Roo/702825209247_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/San_Luis_Potosi/702825209254_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Sinaloa/702825209261_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Sonora/702825209278_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Tabasco/702825209285_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Tamaulipas/702825209292_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Tlaxcala/702825209308_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Veracruz_de_Ignacio_de_la_Llave/702825209315_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Yucatan/702825209322_s.zip',
          'http://internet.contenidos.inegi.org.mx/contenidos/productos//prod_serv/contenidos/espanol/bvinegi/productos/geografia/Cinter_2015/Zacatecas/702825209339_s.zip')

system("mkdir data/Cartografia_geoestadistica_urbana_y_rural_amanzanada")

for(url in URLs){
  nombre <- url %>% gsub('.*2015/', '', .) %>% gsub('/.*', '', .) %>% paste0('data/Cartografia_geoestadistica_urbana_y_rural_amanzanada/', .)
  print(nombre)
  download.file(url, nombre)  
}

## Modificación 13 de julio
### Población por AGEB

system("mkdir data/Población_AGEBs")

for(i in 1:32){
  num <- sprintf("%02d", i)
  url <- paste0(
    "http://www.inegi.org.mx/sistemas/consulta_resultados/zip/RESAGEBURB/RESAGEBURB_",
    num,
    "txt10.zip"
  )
  download.file(url, paste0("data/Población_AGEBs/", num))
}
