# The script aim is to simulate ALS data as waveform and compare the RH100 values from both dataset
#
# Usage from command line:
#Rscript same_height.R -d [path] -p 2425050040012755

# Argumentations
library(optparse)

option_list = list(
  make_option(c("-d", "--dir"), type="character", default=NULL, 
              help="file path where GEDI and ALS files are located", metavar="character"),
  make_option(c("-p", "--pulse"), type="character", default="1", 
              help="output file name [default= %default]", metavar="character")); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# loading packages

library(lidR)
library(rGEDI)
library(rgdal)

# Set output dir for downloading the files
outdir=opt$dir
#outdir="D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/data/"

setwd(outdir)
#pulse="24250500400127557"
pulse=opt$pulse

# read GEDI
gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir, "level1b_clip_nl.h5"))
gedilevel2a<-readLevel2A(level2Apath = file.path(outdir, "level2a_clip_nl.h5"))

# Extracting plot center geolocations (dutch coord) of ALS data
lasfile <- file.path(outdir, paste(pulse,".las",sep=""))
lasheader<- readLASheader(lasfile)

xcenter = ((lasheader@PHB$`Max X`-lasheader@PHB$`Min X`)/2)+lasheader@PHB$`Min X`
ycenter = ((lasheader@PHB$`Max Y`-lasheader@PHB$`Min Y`)/2)+lasheader@PHB$`Min Y`

# Simulating GEDI full-waveform

wf<-gediWFSimulator(
  input  = lasfile,
  output = file.path(outdir,paste("gediWF_simulation_",pulse,".h5",sep="")),
  coords = c(xcenter, ycenter))

wf_gedi <- getLevel1BWF(gedilevel1b, shot_number=pulse)

# ALS visualization (waveform)+ GEDI in same format
png(paste(outdir,"gediWF_simWF_",pulse,"pic.png"))
par(mfrow=c(1,2), cex.axis = 1.2)
plot(wf, relative=TRUE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="", ylab="Elevation (m)",ylim=c(min(wf_gedi@dt$elevation),max(wf_gedi@dt$elevation)))
plot(wf_gedi, relative=TRUE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="", ylab="Elevation (m)")
dev.off()

# GEDI visualization (waveform)
png(paste(outdir,"gediWF",pulse,"pic.png"))
par(mfrow=c(1,1), cex.axis = 1.2)
plotWFMetrics(gedilevel1b, gedilevel2a, pulse, rh=c(25, 50, 75, 90))
dev.off()

# calculate max height metrics
gedi_metrics<-getLevel2AM(gedilevel2a)

als_metrics<-gediWFMetrics(
  input   = wf,
  outRoot = file.path(outdir, paste("sim",pulse),sep=""))

print(paste("GEDI measured:",gedi_metrics[gedi_metrics$shot_number==pulse,112]))
print(paste("ALS measured:",als_metrics$`rhMax 100`))

close(wf)
close(gedilevel1b)
close(gedilevel2a)
