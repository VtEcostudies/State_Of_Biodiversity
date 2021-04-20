# This script was written by M. T. Hallworth for Vermont Center for Ecostudies
# Vermont Atlas of Life project. 

# The following script downloads WorldClim data and elevation data 
# for species distribution models.

library(raster)
library(rgdal)
library(dismo)

# retrieve current data 
EnvData <- getData("worldclim", var="bio", res=0.5, lat = 43.79, lon = -72.63)
Elev <- getData("SRTM", lat = 43.79, lon = -72.63)

# slightly further north because the very top of VT doesn't have SRTM in first file
Elev2 <- getData("SRTM", lat = 46.56, lon = -72.63)
# retrieve CMIP5 model results # 

# It was faster to just download the worldclim futures 
# https://www.worldclim.org/data/cmip6/cmip6_clim2.5m.html

