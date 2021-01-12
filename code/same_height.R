# Argumentations
library(optparse)

option_list = list(
  make_option(c("-p", "--path"), type="character", default=NULL, 
              help="file path where GEDI and ALS files are located", metavar="character"),
  make_option(c("-i", "--index"), type="character", default="1", 
              help="output file name [default= %default]", metavar="character")); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# loading packages

library(lidR)
library(rGEDI)
library(plot3D)
library(rgdal)

# Set output dir for downloading the files
outdir=opt$path
#outdir="D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/"

setwd(outdir)
#i=2
i=as.numeric(opt$index)
error=0

# GEDI
gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir, "level1b_clip_nl.h5"))
gedilevel2a<-readLevel2A(level2Apath = file.path(outdir, "level2a_clip_nl.h5"))

#select pulse of interest
level1bGeo_nl_spdf=readOGR(dsn="level1b_clip_nl_shp.shp")
level1bGeo_nl_df <- as(level1bGeo_nl_spdf, "data.frame")

# get ALS data for GEDI footprint (diameter=25m) 
#(here we assume that the pulse location is correct (but it has min. +-8 m error horizontal positioning))

# Extracting plot center geolocations (dutch coord)

xcenter = level1bGeo_nl_df$coords.x1[i]+error
ycenter = level1bGeo_nl_df$coords.x2[i]+error

# extract ALS
lasfile <- file.path(outdir, paste("sub_",as.character(level1bGeo_nl_df$sht_nmb[i]),".las",sep=""))

if (file.exists(lasfile)==FALSE){
  ctg = catalog(outdir)
  opt_output_files(ctg) <- paste0(outdir,paste("sub_",as.character(level1bGeo_nl_df$sht_nmb[i]),sep=""))
  
  new_ctg = clip_circle(ctg, xcenter, ycenter, 12.5)
}

# Simulating GEDI full-waveform
lasfile <- file.path(outdir, paste("sub_",as.character(level1bGeo_nl_df$sht_nmb[i]),".las",sep=""))

wf<-gediWFSimulator(
  input  = lasfile,
  output = file.path(outdir,paste("gediWF_simulation_",as.character(level1bGeo_nl_df$sht_nmb[i]),".h5",sep="")),
  coords = c(xcenter, ycenter))

wf_gedi <- getLevel1BWF(gedilevel1b, shot_number=as.character(level1bGeo_nl_df$sht_nmb[i]))

# ALS visualization (waveform)+ GEDI in same format
png(paste(outdir,"gediWF_simWF_",as.character(level1bGeo_nl_df$sht_nmb[i]),"pic.png"))
par(mfrow=c(1,2), cex.axis = 1.2)
plot(wf, relative=TRUE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="", ylab="Elevation (m)",ylim=c(min(wf_gedi@dt$elevation),max(wf_gedi@dt$elevation)))
plot(wf_gedi, relative=TRUE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="", ylab="Elevation (m)")
dev.off()

# GEDI visualization (waveform)
png(paste(outdir,"gediWF",as.character(level1bGeo_nl_df$sht_nmb[i]),"pic.png"))
par(mfrow=c(1,1), cex.axis = 1.2)
plotWFMetrics(gedilevel1b, gedilevel2a, as.character(level1bGeo_nl_spdf@data$sht_nmb[i]), rh=c(25, 50, 75, 90))
dev.off()

# calculate max height metrics
gedi_metrics<-getLevel2AM(gedilevel2a)

als_metrics<-gediWFMetrics(
  input   = wf,
  outRoot = file.path(outdir, paste("sim",level1bGeo_nl_spdf@data$sht_nmb[i]),sep=""))

print(paste("GEDI measured:",gedi_metrics$rh100[i]))
print(paste("ALS measured:",als_metrics$`rhMax 100`))

close(wf)
close(gedilevel1b)
close(gedilevel2a)
