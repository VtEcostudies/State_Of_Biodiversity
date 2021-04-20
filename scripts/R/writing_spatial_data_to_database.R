library(raster)
library(sf)
library(gdalUtils)
library(DBI)
library(RPostgres)
# library(sqlpetr)
library(rpostgis)
library(dplyr)
library(dbplyr)
library(stars)

# States <- getData("GADM", country = "United States", level = 1)

# States_sf <- st_as_sf(States)

# VT <- States_sf %>% filter(NAME_1 == "Vermont")

# merge elev data 

#srtm_tiffs <- list.files("spatial_data",
#                         pattern = glob2rx('srtm*.tif$'),
#                         full.names = TRUE)

#srtm_rasts <- lapply(srtm_tiffs,raster)

#raster::mosaic(srtm_rasts[[1]], srtm_rasts[[2]], fun = min, na.rm = TRUE, 
#              filename = "spatial_data/srtm_merged.tif")


SpatialDb <- DBI::dbConnect(RPostgres::Postgres(),
                            dbname = 'vt-atlas-spatial',
                            host = 'localhost', # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'
                            port = 5432, # or any other port specified by your DBA
                            user = 'postgres',
                            password = 'Squirr3lNutk!n')

# check if the database has PostGIS
pgPostGIS(SpatialDb)

# Add VT border # 

# st_write(VT, dsn = SpatialDb, layer = "VT_boundary", append = FALSE)

# Add elevation_srtm # 

# srtm <- raster::raster("spatial_data/srtm_merged.tif")

boundary <- st_read(SpatialDb, "boundary")

Lakes <- list.files("G:/hydrography_l_rivers_v2", pattern = "*.shp$",
                    recursive = TRUE, full.names = TRUE)
Lakes_rivers <- st_read(Lakes)

boundary_L <- st_transform(boundary, st_crs(Lakes_rivers))

plot(st_geometry(boundary_L))
plot(st_geometry(Lakes_rivers), add = TRUE, lwd = 0.1, col = 'blue') 
# srtm_VT <- crop(srtm, boundary)

# pgWriteRast(conn = SpatialDb,
#            name = "SRTM_DEM", 
#            raster = srtm_VT,
#            overwrite = FALSE)







# VTtowns <- st_read("spatial_data/VTtownsWGS84.shp")

# st_write(VTtowns, dsn = SpatialDb, layer = "towns", append = FALSE)

# GMNF <- st_read("spatial_data/GMNF.shp")

# st_write(GMNF, dsn = SpatialDb, layer = "green_mountain_national_forest", append = FALSE)

#pgWriteRast(conn = SpatialDb,
#            name = "Elevation", 
#            raster = srtm,
#            overwrite = FALSE)

# world_clim current 
wc_files <- list.files("spatial_data/wc0.5", 
                        pattern = glob2rx('bio*.bil'),
                        full.names = TRUE)

wc <- lapply(wc_files, raster)

wc_current <- stack(wc[c(1,12:19,2:11)])
crs(wc_current) <- crs("+proj=longlat +datum=WGS84 +no_defs")

names(wc_current) <- c("AnnualMeanTemp","MeanDiurnalRange","Isothermality","TempSeasonality","MaxTempWarmestMonth",
                     "MinTempColdestMonth","TempAnnualRange","MeanTempWettestQtr", "MeanTempDriestQtr", 
                     "MeanTempWarmestQtr", "MeanTempColdestQtr", "AnnualPrecip", "PrecipWettestMonth",
                     "PrecipDriestMonth", "PrecipSeasonality", "PrecipWettestQtr", "PrecipDriestQtr",
                     "PrecipWarmestQtr", "PrecipColdestQtr")

wc_current <- crop(wc_current, VT)
wc_current <- mask(wc_current, VT)

pgWriteRast(conn = SpatialDb,
            name = "WorldClim_bio_current", 
            raster = wc_current,
            overwrite = FALSE)

## ---- cache = TRUE, message = FALSE, warning = FALSE, results='hide'----------
FutEnv <- getData("CMIP5", var="bio", 
                  rcp=85, year = 50, model = "AC",
                  res=2.5, lat = 43.79, lon = -72.63)

names(FutEnv) <- c("AnnualMeanTemp","MeanDiurnalRange","Isothermality","TempSeasonality","MaxTempWarmestMonth",
                     "MinTempColdestMonth","TempAnnualRange","MeanTempWettestQtr", "MeanTempDriestQtr", 
                     "MeanTempWarmestQtr", "MeanTempColdestQtr", "AnnualPrecip", "PrecipWettestMonth",
                     "PrecipDriestMonth", "PrecipSeasonality", "PrecipWettestQtr", "PrecipDriestQtr",
                     "PrecipWarmestQtr", "PrecipColdestQtr")

FutEnv <- crop(FutEnv, boundary)
FutEnv <- mask(FutEnv, boundary)

pgWriteRast(conn = SpatialDb,
            name = "WorldClim_bio_2050_AC_85", 
            raster = FutEnv,
            overwrite = FALSE)

## ---- cache = TRUE, message = FALSE, warning = FALSE, results='hide'----------
FutEnv <- getData("CMIP5", var="bio", 
                  rcp=85, year = 70, model = "AC",
                  res=2.5, lat = 43.79, lon = -72.63)

names(FutEnv) <- c("AnnualMeanTemp","MeanDiurnalRange","Isothermality","TempSeasonality","MaxTempWarmestMonth",
                     "MinTempColdestMonth","TempAnnualRange","MeanTempWettestQtr", "MeanTempDriestQtr", 
                     "MeanTempWarmestQtr", "MeanTempColdestQtr", "AnnualPrecip", "PrecipWettestMonth",
                     "PrecipDriestMonth", "PrecipSeasonality", "PrecipWettestQtr", "PrecipDriestQtr",
                     "PrecipWarmestQtr", "PrecipColdestQtr")

FutEnv <- crop(FutEnv, boundary)
FutEnv <- mask(FutEnv, boundary)

pgWriteRast(conn = SpatialDb,
            name = "WorldClim_bio_2070_AC_85", 
            raster = FutEnv,
            overwrite = FALSE)


prob_develop2030 <- raster("spatial_data/natures_network/Probability_of_Development_2030/DSL_probability_development_2030_v3.0_raster.tif")

VT_develop <- st_transform(VT, crs(prob_develop2030))
prob_develop2030 <- crop(prob_develop2030, VT_develop)
prob_develop2030 <- mask(prob_develop2030, VT_develop)

pgWriteRast(conn = SpatialDb,
            name = "probability_development_2030", 
            raster = prob_develop2030,
            overwrite = FALSE)


prob_develop2080 <- raster("spatial_data/natures_network/Probability_of_Development_2080/DSL_probability_development_2080_v3.0_raster.tif")

VT_develop <- st_transform(VT, crs(prob_develop2080))
prob_develop2080 <- crop(prob_develop2080, VT_develop)
prob_develop2080 <- mask(prob_develop2080, VT_develop)

pgWriteRast(conn = SpatialDb,
            name = "probability_development_2080", 
            raster = prob_develop2080,
            overwrite = FALSE)

VT_1 <- VTtowns %>% filter(TOWNNAME == "BENNINGTON") 
VT_1 <- st_transform(VT_1,st_crs('ESRI:102039'))
ha <- pgGetRast(conn = SpatialDb,
          name = "probability_development_2080")


plot(st_geometry(VT_1))
plot(ha, add = TRUE)


RPostgreSQL::dbDisconnect(SpatialDb)











