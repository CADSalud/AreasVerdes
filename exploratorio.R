library(dplyr)
library(rgdal)
library(maptools)
library(ggplot2)
library(leaflet)
library(geosphere)
gpclibPermit()

entidades <- readOGR(dsn = "Entidades_2010_5A/", layer = "Entidades_2010_5A") %>% 
  spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))

####################################
### CDMX
####################################

mapa_inegi <- readOGR(dsn = "./shapefiles_inegi/Distrito_Federal_FILES/conjunto_de_datos/", layer = "09sia") %>% 
  spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))

mapa_av <- mapa_inegi[(mapa_inegi$GEOGRAFICO == "Área Verde" | mapa_inegi$GEOGRAFICO == "Instalación Deportiva o Recreativa"),]

mapa_cdmx <- entidades[entidades$NOM_ENT == "Distrito Federal",]

mapa_inegi_gg <- broom::tidy(mapa_inegi)

mapa_av_gg <- broom::tidy(mapa_av)

mapa_cdmx_gg <- broom::tidy(mapa_cdmx, region = "NOM_ENT")



ggplot() +
  geom_polygon(data = mapa_cdmx_gg, aes(long, lat, group), fill = 'white', color = "black") +
  geom_polygon(data = mapa_av_gg, aes(long, lat, group), fill = "dark green") +
  theme_minimal() +
  coord_equal()


ggplot() +
  geom_polygon(data = mapa_cdmx_gg, aes(long, lat, group), fill = 'white', color = "black") +
  geom_polygon(data = mapa_inegi_gg, aes(long, lat, group), fill = "dark grey") +
  geom_polygon(data = mapa_av_gg, aes(long, lat, group), fill = "dark green") +
  theme_minimal() +
  coord_equal()

mapa_av$area <- areaPolygon(mapa_av)

leaflet(mapa_av) %>% 
  addTiles() %>% 
  addPolygons(color = "green", fillOpacity = 0.8, stroke = T, smoothFactor = 0.5,
              popup = ~paste0(
                "Nombre: ",
                NOMBRE,
                "<br>",
                "Área: ",
                round(area, 2),
                "<br>",
                "Geográfico: ",
                GEOGRAFICO,
                "<br>",
                "Tipo: ",
                TIPO
              ))


sum(areaPolygon(mapa_av))/sum(areaPolygon(mapa_cdmx))

####################################
### QUERÉTARO
####################################

mapa_inegi_qro <- readOGR(dsn = "./shapefiles_inegi/Queretaro_FILES/conjunto_de_datos/", layer = "22sia") %>% 
  spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))

mapa_av_qro <- mapa_inegi_qro[(mapa_inegi_qro$GEOGRAFICO == "Área Verde" | mapa_inegi_qro$GEOGRAFICO == "Instalación Deportiva o Recreativa"),]

mapa_qro <- entidades[entidades$NOM_ENT == "Quer\xe9taro",]

mapa_inegi_gg_qro <- broom::tidy(mapa_inegi_qro)

mapa_av_gg_qro <- broom::tidy(mapa_av_qro)

mapa_qro_gg <- broom::tidy(mapa_qro, region = "NOM_ENT")



ggplot() +
  geom_polygon(data = mapa_qro_gg, aes(long, lat, group), fill = 'white', color = "black") +
  geom_polygon(data = mapa_av_gg_qro, aes(long, lat, group), fill = "dark green") +
  theme_minimal() +
  coord_equal()


ggplot() +
  geom_polygon(data = mapa_qro_gg, aes(long, lat, group), fill = 'white', color = "black") +
  geom_polygon(data = mapa_inegi_gg_qro, aes(long, lat, group), fill = "dark grey") +
  geom_polygon(data = mapa_av_gg_qro, aes(long, lat, group), fill = "dark green") +
  theme_minimal() +
  coord_equal()

mapa_av_qro$area <- areaPolygon(mapa_av_qro)

leaflet(mapa_av_qro) %>% 
  addTiles() %>% 
  addPolygons(color = "green", fillOpacity = 0.8, stroke = T, smoothFactor = 0.5,
              popup = ~paste0(
                "Nombre: ",
                NOMBRE,
                "<br>",
                "Área: ",
                round(area, 2),
                "<br>",
                "Geográfico: ",
                GEOGRAFICO,
                "<br>",
                "Tipo: ",
                TIPO
              ))


sum(areaPolygon(mapa_av_qro))/sum(areaPolygon(mapa_qro))


