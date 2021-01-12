# loading packages

library(lidR)
library(rGEDI)
library(plot3D)

# Set output dir for downloading the files
outdir="D:/Sync/_Amsterdam/NextJob/LiDARPos_BangorU/interview/"
setwd(outdir)
i=2

# GEDI
gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir, "level1b_clip_nl.h5"))
gedilevel2a<-readLevel2A(level2Apath = file.path(outdir, "level2a_clip_nl.h5"))

#select the first shot number and transfer coords
to_shp_gedi<-function(level1b_clip_bb){
  level1bGeo_nl<-getLevel1BGeo(level1b=level1b_clip_bb,select=c("elevation_bin0"))
  level1bGeo_nl$shot_number<-paste0(level1bGeo_nl$shot_number)
  level1bGeo_nl_spdf<-SpatialPointsDataFrame(cbind(level1bGeo_nl$longitude_bin0, level1bGeo_nl$latitude_bin0),
                                             data=level1bGeo_nl)
  
  return(level1bGeo_nl_spdf)
}

level1bGeo_nl_spdf=to_shp_gedi(gedilevel1b)

proj4string(level1bGeo_nl_spdf) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
level1bGeo_nl_spdf_nl <- spTransform(level1bGeo_nl_spdf, CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs"))

plotWFMetrics(gedilevel1b, gedilevel2a, level1bGeo_nl_spdf@data$shot_number[i], rh=c(25, 50, 75, 90))

# get ALS data for GEDI footprint (diameter=25m) 
#(here we assume that the pulse location is correct (but it has min. +-8 m error horizontal positioning))

# Extracting plot center geolocations (dutch coord)

xcenter = level1bGeo_nl_spdf_nl@coords[i,1]
ycenter = level1bGeo_nl_spdf_nl@coords[i,2]

# extract ALS
ctg = catalog(outdir)
opt_output_files(ctg) <- paste0(outdir,paste("sub_",round(xcenter,2),"_",round(ycenter,2),sep=""))

new_ctg = clip_circle(ctg, xcenter, ycenter, 12.5)


# Simulating GEDI full-waveform
lasfile <- file.path(outdir, paste("sub_",round(xcenter,2),"_",round(ycenter,2),".las",sep=""))

wf<-gediWFSimulator(
  input  = lasfile,
  output = file.path(outdir,"gediWF_simulation.h5"),
  coords = c(xcenter, ycenter))

# read las for visualization
las=readLAS(lasfile)

par(mfrow=c(1,2), cex.axis = 1.2)
scatter3D(las@data$X,las@data$Y,las@data$Z,pch = 16,colkey = FALSE, main="",
          cex = 0.5,bty = "u",col.panel ="gray90",phi = 30,alpha=1,theta=45,
          col.grid = "gray50", xlab="Easting (m)", ylab="Northing (m)", zlab="Elevation (m)")

plot(wf, relative=TRUE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="", ylab="Elevation (m)",ylim=c((min(las@data$Z)),max(las@data$Z)))

# visualization
par(mfrow=c(1,1), cex.axis = 1.2)
plotWFMetrics(gedilevel1b, gedilevel2a, level1bGeo_nl_spdf@data$shot_number[1], rh=c(25, 50, 75, 90))

close(wf)
close(gedilevel1b)
close(gedilevel2a)
