# loading packages

library(lidR)
library(rgdal)

# Set output dir for downloading the files
outdir=setwd("D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/")

download.file("https://download.pdok.nl/rws/ahn3/v1_0/laz/C_69GN2.LAZ","C_69GN2_2.LAZ")

# read GEDI shp
areaofint=readOGR(dsn="level1b_clip_nl_shp.shp")

# extract ALS

ctg = catalog(outdir)

for (i in seq(1,length(areaofint$sht_nmb),1)){ 
  print(i) 
  subset = lasclipCircle(ctg,areaofint@coords[i,1],areaofint@coords[i,2],25)
  
  if (subset@header@PHB[["Number of point records"]]>0) {
    writeLAS(subset,paste(areaofint$sht_nmb[i],".laz",sep=""))
  }
}
  