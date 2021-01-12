# loading packages

library(rGEDI)
library(sp)
library(rgdal)

# Set output dir for downloading the files
outdir="D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/"
setwd(outdir)

# download GEDI for Vijlenerbos
ul_lat<- 50.7690
lr_lat<- 50.7624
ul_lon<- 5.9602
lr_lon<- 5.9717

# Specifying the date range
daterange=c("2019-05-17","2019-05-20")

# Get path to GEDI data
gLevel1B<-gedifinder(product="GEDI01_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)
gLevel2A<-gedifinder(product="GEDI02_A",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)
gLevel2B<-gedifinder(product="GEDI02_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)

# Downloading GEDI data
gediDownload(filepath=gLevel1B,outdir=outdir)
gediDownload(filepath=gLevel2A,outdir=outdir)
gediDownload(filepath=gLevel2B,outdir=outdir)

# Read into memory
gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir, "GEDI01_B_2019138001124_O02425_T02570_02_003_01.h5"))
gedilevel2a<-readLevel2A(level2Apath = file.path(outdir, "GEDI02_A_2019138001124_O02425_T02570_02_001_01.h5"))
gedilevel2b<-readLevel2B(level2Bpath = file.path(outdir, "GEDI02_B_2019138001124_O02425_T02570_02_001_01.h5"))

## clipping GEDI data within boundary box
level1b_clip_bb <- clipLevel1B(gedilevel1b, ul_lon, lr_lon, lr_lat, ul_lat,output=file.path(outdir, "level1b_clip_nl.h5"))
level2a_clip_bb <- clipLevel2A(gedilevel2a, ul_lon, lr_lon, lr_lat, ul_lat,output=file.path(outdir, "level2a_clip_nl.h5"))
level2b_clip_bb <- clipLevel2B(gedilevel2b, ul_lon, lr_lon, lr_lat, ul_lat,output=file.path(outdir, "level2b_clip_nl.h5"))

# generate a polygon and transform it into dutch coord system 
to_shp<-function(ul_lon, lr_lon, lr_lat, ul_lat){
  x_coord <- c(ul_lon,lr_lon,lr_lon,ul_lon,ul_lon)
  y_coord <- c(lr_lat,lr_lat,ul_lat,ul_lat,lr_lat)
  xy_box <- cbind(x_coord, y_coord)
  
  p = Polygon(xy_box)
  ps = Polygons(list(p),1)
  bbox = SpatialPolygons(list(ps))
  
  return(bbox)
}

bbox=to_shp(ul_lon, lr_lon, lr_lat, ul_lat)

proj4string(bbox) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
bbox_nl <- spTransform(bbox, CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs"))

raster::shapefile(bbox_nl,paste0(outdir,"\\bbox_nl"),overwrite=TRUE)

## create a shapefile from GEDI (just for visualization check)
to_shp_gedi<-function(level1b_clip_bb){
  level1bGeo_nl<-getLevel1BGeo(level1b=level1b_clip_bb,select=c("elevation_bin0"))
  level1bGeo_nl$shot_number<-paste0(level1bGeo_nl$shot_number)
  level1bGeo_nl_spdf<-SpatialPointsDataFrame(cbind(level1bGeo_nl$longitude_bin0, level1bGeo_nl$latitude_bin0),
                                             data=level1bGeo_nl)
  
  return(level1bGeo_nl_spdf)
}

level1bGeo_nl_spdf=to_shp_gedi(level1b_clip_bb)

proj4string(level1bGeo_nl_spdf) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
level1bGeo_nl_spdf_nl <- spTransform(level1bGeo_nl_spdf, CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs"))

raster::shapefile(level1bGeo_nl_spdf_nl,paste0(outdir,"\\level1b_clip_nl_shp"),overwrite=TRUE)