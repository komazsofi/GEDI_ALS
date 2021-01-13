## **Aim**
This scripts are downloading GEDI and ALS data related to the Vijlenerbos area in the Netherlands and calculate the height where the two sensor has geographical intersection. 

## **R packages**

I used version R 3.5.1.. The required packages to install are the following:

```{r}
install.packages(c("lidR", "rGEDI", "optparse", "rgdal","sp"))
```

## **Instructions for executing the scripts**

The R scripts are written that it is posisble to run from command line. The required data for small demo can be downloaded from the following [link](https://drive.google.com/drive/folders/1Hg3Ig3FvjxNiMC-TNPxDCcBEVOIqvlkz?usp=sharing)

From command line:

```
Rscript download_gedi.R D:/Sync/data
Rscript download_ALS.R -p D:/Sync/data -s level1b_clip_nl_shp.shp
Rscript same_height.R -d D:/Sync/data -p 2425050040012755
```

With the command.txt it is possible to use GNU parallel package to parallel process several pulses related data parallel. 
