# This script was written by M. T. Hallworth for Vermont Center for Ecostudies
# Vermont Atlas of Life project. 

# The following script grabs data from Google Earth Engine #

library(rgee)
library(sf)
# Run the following code - after a min or two a web page will open
# allowing Earth Engine and TidyVerse API to use accounts 
# ee_Initialize(email = "mhallworth@vtecostudies.org",
#               drive = TRUE)


# Load VT towns # 

VTtowns <- st_read("spatial_data/VTtownsWGS84.shp", quiet = TRUE)

VT <- st_combine(VTtowns)

VT <- st_buffer(

VT_ee <- sf_as_ee(VT)
# Grab the forest cover data set 

#// Load the forest loss dataset and select the bands of interest.
gfc2020 <- ee$Image("UMD/hansen/global_forest_change_2020_v1_8")$select(c('treecover2000','lossyear'))
           
fc2000vt <- gfc2020$select(c('treecover2000'))$clip(VT_ee)   

Map$setCenter(-73,43, 8)
Map$addLayer(fc2000vt,name = "TreeCover", 
             visParams = list(min = 0,
                              max = 100))

# // Import MODIS Global land cover classification - 500m resolution //

# // Clip Land Cover to each BBS buffer 
LandCoverType <- ee$ImageCollection("MODIS/006/MCD12Q1")$select('LC_Type1')#$first()$clip(VT_ee)
LandCoverType$getInfo()
forest <- ee_extract(x = LandCoverType, y = VT, sf = FALSE)

igbpLandCoverVis <- list(min= 1.0,
                         max= 17.0,
  palette=c(
    '05450a', '086a10', '54a708', '78d203', '009900', 'c6b044', 'dcd159',
    'dade48', 'fbff13', 'b6ff05', '27ff87', 'c24f44', 'a5a5a5', 'ff6d4c',
    '69fff8', 'f9ffa4', '1c0dff'))

Map$setCenter(-73,43,8)
Map$addLayer(LandCoverType, visParams = igbpLandCoverVis, name = "LandCover")