# loading packages

library(lidR)
library(rgdal)

# Set output dir for downloading the files
outdir="D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/"
setwd(outdir)

#download.file(paste("https://download.pdok.nl/rws/ahn3/v1_0/laz/","C_69GN2",".LAZ",sep=''),paste("C_69GN2",".LAZ",sep=""))
#if the file is corrupt please download it manually from https://geodata.nationaalgeoregister.nl/ahn3/extract/ahn3_laz/C_69GN2.LAZ

# read GEDI shp
areaofint=readOGR(dsn="bbox_nl.shp")

# extract ALS of area of interest
ctg = catalog(outdir)
opt_output_files(ctg) <- paste0(outdir,"bbox_nl")

new_ctg = clip_roi(ctg, areaofint)



