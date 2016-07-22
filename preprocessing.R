library(dplyr)
library(tidyr)
library(rgdal)
library(maptools)
library(ggplot2)
library(leaflet)
library(geosphere)
library(readr)
gpclibPermit()

# http://www.inee.edu.mx/bie/mapa_indica/2005/PanoramaEducativoDeMexico/CS/CS05/2005_CS05__.pdf
# Urbana, una localidad es urbana si su población es de
# 15,000 o más habitantes
# • Semiurbana, una localidad es semiurbana si su población
# es de 2,500 a 14,999 habitantes
# • Rural, una localidad es rural si su población es de 1 a
# 2,499 habitantes

catalogo_entidades <- readr::read_csv("data/catalogo_entidades.csv")
# catalogo_municipios <- readr::read_csv("data/catalogo_municipios.csv") %>% 
#   left_join(catalogo_entidades)

pob_loc <- read.table("data/poblacion_localidades.txt", header = T, 
                      colClasses = c("character", "character", "character", "integer")) %>% 
  filter(MUN != "000", LOC != "0000") %>% 
  mutate(Tipo = ifelse(POBTOT < 2500, "Rural", 
                       ifelse(POBTOT >= 2500 & POBTOT <15000, "Semiurbana",
                              "Urbana")))

pob_mun0 <- pob_loc %>% 
  mutate(CVE_ENT_MUN = paste0(ENTIDAD, MUN)) %>% 
  group_by(CVE_ENT_MUN, Tipo) %>% 
  summarise(POBTOT = sum(POBTOT),
            num_loc = n()) %>% 
  ungroup() 

# pob_mun_num_loc <- pob_mun0 %>% 
#   select(-POBTOT) %>% 
#   spread(Tipo, num_loc, fill = 0) %>% 
#   rename(NUM_Loc_Rurales = Rural,
#          NUM_Loc_Semiurbanas = Semiurbana,
#          NUM_Loc_Urbanas = Urbana) %>% 
#   mutate(NUM_Loc = NUM_Loc_Rurales + NUM_Loc_Semiurbanas + NUM_Loc_Urbanas)

pob_mun <- pob_mun0 %>% 
  select(-num_loc) %>% 
  spread(Tipo, POBTOT, fill = 0) %>% 
  rename(POB_Rural = Rural,
         POB_Semiurbana = Semiurbana,
         POB_Urbana = Urbana) %>% 
  mutate(POBTOT = POB_Rural + POB_Semiurbana + POB_Urbana) %>% 
  left_join(
    pob_mun0 %>% 
      select(-POBTOT) %>% 
      spread(Tipo, num_loc, fill = 0) %>% 
      rename(NUM_Loc_Rurales = Rural,
             NUM_Loc_Semiurbanas = Semiurbana,
             NUM_Loc_Urbanas = Urbana) %>% 
      mutate(NUM_Loc = NUM_Loc_Rurales + NUM_Loc_Semiurbanas + NUM_Loc_Urbanas)
  ) %>% 
  mutate(POB_Prom_Loc = POBTOT/NUM_Loc)

# pob_mun <- pob_loc %>% 
#   mutate(CVE_ENT_MUN = paste0(ENTIDAD, MUN)) %>% 
#   group_by(CVE_ENT_MUN, Tipo) %>% 
#   summarise(POBTOT = sum(POBTOT),
#             num_loc = n()) %>% 
#   ungroup() %>% 
#   spread(Tipo, POBTOT, fill = 0) %>% 
#   rename(POB_Rural = Rural,
#          POB_Semiurbana = Semiurbana,
#          POB_Urbana = Urbana) %>% 
#   mutate(POBTOT = POB_Rural + POB_Semiurbana + POB_Urbana)

entidades <- readOGR(dsn = "data/Entidades_2010_5A//", layer = "Entidades_2010_5A") %>% 
  spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))

municipios <- readOGR("data/Municipios_2013/", layer = "Municipios_2013") %>% 
  spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))

catalogo_municipios <- readr::read_csv("data/catalogo_municipios.csv") 

municipios@data <- municipios@data %>% 
  select(-NOM_MUN) %>% 
  left_join(catalogo_municipios)

#########################################
### Data frame de municipios con la información de población y áreas verdes
#########################################

municipios$CVE_ENT_MUN <- paste0(as.character(municipios$CVE_ENT), as.character(municipios$CVE_MUN))
municipios$AREA <- areaPolygon(municipios)

municipios@data <- municipios@data %>% 
  left_join(pob_mun)


archivos <- list.files("data/Cartografia_geoestadistica_urbana_y_rural_amanzanada", full.names = T)

areas_municipios <- lapply(archivos, function(archivo) {
  layer <- list.files(paste0(archivo, "/conjunto_de_datos")) %>% 
    grep("sia", ., value = T) %>% 
    .[1] %>% 
    substr(1, 5)
  mapa_inegi <- readOGR(dsn = paste0(archivo, "/conjunto_de_datos/"), layer = layer) %>% 
    spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))
  
  mapa_inegi$CVE_ENT_MUN <- substr(mapa_inegi$CVEGEO, 1, 5)
  
  mapa_av <- mapa_inegi[mapa_inegi$GEOGRAFICO == "Área Verde",]
  mapa_av$AREA <- areaPolygon(mapa_av)
  
  municipios_area <- mapa_av@data %>% 
    group_by(CVE_ENT_MUN) %>% 
    summarise(Area_Verde_Total = sum(AREA), Num_Areas_Verdes = n())
  
  return(municipios_area)
}) %>% 
  rbind_all() %>% 
  left_join(municipios@data) 

municipios_todo <- municipios@data %>% 
  left_join(areas_municipios) %>% 
  mutate_each(funs(ifelse(is.na(.), 0, .))) %>% 
  left_join(catalogo_entidades) %>% 
  select(-OID)

saveRDS(municipios_todo, file = "output/municipios_info.rds")
saveRDS(municipios, file = "output/municipios.rds")


#########################################
### Lista de polígonos de áreas verdes
#########################################


municipios_areas_verdes <- lapply(archivos, function(archivo) {
  layer <- list.files(paste0(archivo, "/conjunto_de_datos")) %>% 
    grep("sia", ., value = T) %>% 
    .[1] %>% 
    substr(1, 5)
  mapa_inegi <- readOGR(dsn = paste0(archivo, "/conjunto_de_datos/"), layer = layer) %>% 
    spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))
  
  mapa_inegi$CVE_ENT_MUN <- substr(mapa_inegi$CVEGEO, 1, 5)
  
  mapa_av <- mapa_inegi[mapa_inegi$GEOGRAFICO == "Área Verde",]
  mapa_av$AREA <- areaPolygon(mapa_av)
  
  return(mapa_av)
})

names(municipios_areas_verdes) <- sapply(
  seq_along(municipios_areas_verdes), 
  function(i) {
    substr(municipios_areas_verdes[[i]]@data$CVE_ENT_MUN[1], 1, 2)
    })

saveRDS(municipios_areas_verdes, "output/municipios_areas_verdes.rds")


#########################################
### Índices de desarrollo humano y de marginación
#########################################




indice_marg <- read_csv("data/marginacion_municipal_90-15.csv", na = c("-", "N. D.")) %>% 
  filter(AÑO == 2015) %>% 
  select(CVE_ENT, CVE_MUN = CVEE_MUN, IM, GM)
  
idh <- read_csv("data/IDH_municipios.csv")
names(idh) <- make.names(names(idh))
idh <- idh %>% 
  mutate(CVE_ENT = sprintf("%02d", Clave.entidad),
         CVE_MUN = sprintf("%03d", Clave.municipio)) %>% 
  select(CVE_ENT, CVE_MUN, IDH = Valor.del.Índice.de.Desarrollo.Humano..IDH.)

saveRDS(idh, "output/IDH_municipios.rds")
saveRDS(indice_marg, "output/IM_municipios.rds")

# # Los que no tienen info
# municipios_todo %>% filter(is.na(Area_Verde_Total)) %>% View
# 
# 
# ####################################
# ### CDMX
# ####################################
# 
# mapa_inegi <- readOGR(dsn = "./shapefiles_inegi/Distrito_Federal_FILES/conjunto_de_datos/", layer = "09sia") %>% 
#   spTransform(., CRS("+init=epsg:26978 +proj=longlat +datum=WGS84"))
# mapa_inegi$CVE_ENT_MUN <- substr(mapa_inegi$CVEGEO, 1, 5)
# 
# mapa_av <- mapa_inegi[mapa_inegi$GEOGRAFICO == "Área Verde",]
# mapa_av$AREA <- areaPolygon(mapa_av)
# 
# municipios_area <- mapa_av@data %>% 
#   group_by(CVE_ENT_MUN) %>% 
#   summarise(Area_Verde_Total = sum(AREA), Num_Areas_Verdes = n()) %>% 
#   left_join(municipios@data)
# 
# 
# mapa_av_gg <- broom::tidy(mapa_av, region = "CVE_ENT_MUN")
# 
# ###################
# # Delegación Miguel Hidalgo
# ###################
# 
# mapa_miguel_hidalgo <- municipios[municipios$CVE_ENT_MUN == "09016",]
# av_miguel_hidalgo <- mapa_av[mapa_av$CVE_ENT_MUN == "09016",]
# 
# leaflet(mapa_miguel_hidalgo) %>% 
#   addTiles() %>% 
#   addPolygons(color = "black", fillOpacity = 0.1) %>% 
#   addPolygons(data = av_miguel_hidalgo, color = "green", fillOpacity = 0.8, stroke = T, smoothFactor = 0.5,
#               popup = ~paste0(
#                 "Nombre: ",
#                 NOMBRE,
#                 "<br>",
#                 "Área: ",
#                 round(AREA, 2),
#                 "<br>",
#                 "Geográfico: ",
#                 GEOGRAFICO,
#                 "<br>",
#                 "Tipo: ",
#                 TIPO
#               ))
