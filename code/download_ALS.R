# The script aim is to extract the ALS data related to the pulse positions from the GEDI data.
#
# Usage from command line:
#Rscript download_ALS.R -p [path] -s [shp file]

# Argumentations
library(optparse)

option_list = list(
  make_option(c("-p", "--path"), type="character", default=NULL, 
              help="file path where GEDI and ALS files are located", metavar="character"),
  make_option(c("-s", "--shapefile"), type="character", default="1", 
              help="shapefile with pulse points location", metavar="character"));  

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
# loading packages

library(lidR)
library(rgdal)

# Set output dir for downloading the files
#outdir="D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/data/"
outdir=opt$path
setwd(outdir)

# read GEDI pulse point shp 
#level1bGeo_nl_spdf=readOGR(dsn="level1b_clip_nl_shp.shp")
level1bGeo_nl_spdf=readOGR(dsn=opt$shapefile)

# get ALS data for GEDI footprint (diameter=25m) 
#(here we assume that the pulse location is correct (but it has min. +-8 m error horizontal positioning))
# this part is computationally ineffective - for loop over pulse points

ctg = catalog(outdir)

for (i in seq(1,length(level1bGeo_nl_spdf$sht_nmb),1)){ 
  print(i)
  
  if (file.exists(paste(level1bGeo_nl_spdf$sht_nmb[i],".las",sep=""))==FALSE){
    subset = clip_circle(ctg,level1bGeo_nl_spdf@coords[i,1],level1bGeo_nl_spdf@coords[i,2],12.5)
  }
  
  if (subset@header@PHB[["Number of point records"]]>0) {
    writeLAS(subset,paste(level1bGeo_nl_spdf$sht_nmb[i],".las",sep=""))
  }
}

