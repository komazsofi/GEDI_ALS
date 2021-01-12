# Argumentations
library(optparse)

option_list = list(
  make_option(c("-p", "--path"), type="character", default=NULL, 
              help="file path where GEDI and ALS files are located", metavar="character")); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# loading packages

library(lidR)
library(rGEDI)
library(plot3D)
library(rgdal)

# Set output dir for downloading the files
#outdir="D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/"
outdir=opt$path
setwd(outdir)
i=5
error=0

# GEDI
gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir, "level1b_clip_nl.h5"))
gedilevel2a<-readLevel2A(level2Apath = file.path(outdir, "level2a_clip_nl.h5"))

#select pulse of interest
level1bGeo_nl_spdf=readOGR(dsn="level1b_clip_nl_shp.shp")

# get ALS data for GEDI footprint (diameter=25m) 
#(here we assume that the pulse location is correct (but it has min. +-8 m error horizontal positioning))

# Extracting plot center geolocations (dutch coord)

xcenter = level1bGeo_nl_spdf@coords[i,1]+error
ycenter = level1bGeo_nl_spdf@coords[i,2]+error

# extract ALS
ctg = catalog(outdir)
opt_output_files(ctg) <- paste0(outdir,paste("sub_",round(xcenter,2),"_",round(ycenter,2),sep=""))

new_ctg = clip_circle(ctg, xcenter, ycenter, 12.5)

# Simulating GEDI full-waveform
lasfile <- file.path(outdir, paste("sub_",round(xcenter,2),"_",round(ycenter,2),".las",sep=""))

wf<-gediWFSimulator(
  input  = lasfile,
  output = file.path(outdir,paste("gediWF_simulation_",i,".h5",sep="")),
  coords = c(xcenter, ycenter))

# read las for visualization
las=readLAS(lasfile)

png(paste(outdir,"gediWF_simulation_",round(xcenter,2),"_",round(ycenter,2),"pic.png"))
par(mfrow=c(1,1), cex.axis = 1.2)
plot(wf, relative=TRUE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="", ylab="Elevation (m)",ylim=c((min(las@data$Z)),max(las@data$Z)))
dev.off()

# visualization GEDI
png(paste(outdir,"gediWF",round(xcenter,2),"_",round(ycenter,2),"pic.png"))
par(mfrow=c(1,1), cex.axis = 1.2)
plotWFMetrics(gedilevel1b, gedilevel2a, as.character(level1bGeo_nl_spdf@data$sht_nmb[i]), rh=c(25, 50, 75, 90))
dev.off()

close(wf)
close(gedilevel1b)
close(gedilevel2a)
