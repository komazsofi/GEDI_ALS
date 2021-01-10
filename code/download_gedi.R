# loading packages

library(rGEDI)
library(sp)
library(rgdal)

# Set output dir for downloading the files
outdir=setwd("D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/")

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

# clip to study area

ymin = 50.7624
ymax = 50.7690
xmin = 5.9602
xmax = 5.9717

## clipping GEDI data within boundary box
level1b_clip_bb <- clipLevel1B(gedilevel1b, xmin, xmax, ymin, ymax,output=file.path(outdir, "level1b_clip_nl.h5"))
level2a_clip_bb <- clipLevel2A(gedilevel2a, xmin, xmax, ymin, ymax, output=file.path(outdir, "level2a_clip_nl.h5"))
level2b_clip_bb <- clipLevel2B(gedilevel2b, xmin, xmax, ymin, ymax,output=file.path(outdir, "level2b_clip_nl.h5"))

## Create a shapefile
level1bGeo_nl<-getLevel1BGeo(level1b=level1b_clip_bb,select=c("elevation_bin0"))
level1bGeo_nl$shot_number<-paste0(level1bGeo_nl$shot_number)
level1bGeo_nl_spdf<-SpatialPointsDataFrame(cbind(level1bGeo_nl$longitude_bin0, level1bGeo_nl$latitude_bin0),
                                        data=level1bGeo_nl)

proj4string(level1bGeo_nl_spdf) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
level1bGeo_nl_spdf_nl <- spTransform(level1bGeo_nl_spdf, CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs"))

raster::shapefile(level1bGeo_nl_spdf_nl,paste0(outdir,"\\level1b_clip_nl_shp"))
