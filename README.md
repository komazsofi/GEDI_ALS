## **Aim**
These scripts download GEDI and ALS data related to the Vijlenerbos area in the Netherlands and calculate the maximum height (RH100) where the two sensors have geographical intersection.

The aim of this script is to derive and compare the same height value which was extracted from small footprint Airborne Laser Scanning (ALS) data and large footprint spaceborne LiDAR (GEDI) data. Small footprint ALS data measurement scheme is similar to the large footprint LiDAR data, where the used scanner emits a laser pulse which is reflected back from different parts of the vegetation or from the ground. Because small footprint ALS data has a cm accuracy in representing the 3D structure it can be used well for validate and assess the accuracy of the GEDI mission. However, in the case of small footprint ALS data the returned signal to the sensor is processed with proprietary algorithms to extract a number of discrete returns (1-20) from the returned energy. This results a 3D point cloud in the end. Compared to that large footprint LiDAR systems store digitized waveforms. As it was suggested by Silva et al., 2018 and Hancock et al., 2019 small footprint ALS data needs to be simulated as a GEDI waveform to be able to use in calibration and assessment of the accuracy of GEDI derived waveform metrics such as RH100.

Hancock, S. et al. (2019) ‘The GEDI Simulator: A Large‐Footprint Waveform Lidar Simulator for Calibration and Validation of Spaceborne Missions’, Earth and Space Science. Wiley-Blackwell Publishing Ltd, 6(2), pp. 294–310. doi: 10.1029/2018EA000506.

Silva, C. A. et al. (2018) ‘Comparison of Small-and Large-Footprint Lidar Characterization of Tropical Forest Aboveground Structure and Biomass: A Case Study from Central Gabon’, IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing. Institute of Electrical and Electronics Engineers, 11(10), pp. 3512–3526. doi: 10.1109/JSTARS.2018.2816962.

## **Workflow**

The developed workflow has three main step: 
  a.)	download the GEDI data based on selected coordinates (upper left and lower right) and spatially cut for the selected area of interest. Generate a shape file which stores the position of the GEDI pulses and convert into the local Dutch coordinate system (RD_New). (download_gedi.R)
  b.)	Extract the ALS data point cloud data related to the pulse positions using a 12.5 radius (25 m diameter) around the pulse position. (download_ALS.R)
  c.)	According to pulse position simulate the GEDI waveform from the corresponding ALS dataset and then compare to the actual GEDI dataset for the same location. (same_height.R)


## **R packages**

I used version R 3.5.1.. The required packages are the following:

```{r}
install.packages(c("lidR", "rGEDI", "optparse", "rgdal","sp"))
```

## **Instructions for executing the scripts**

The R scripts are written that it is possible to run from command line. The required data for small demo can be downloaded from the following [link](https://drive.google.com/drive/folders/1Hg3Ig3FvjxNiMC-TNPxDCcBEVOIqvlkz?usp=sharing)

From command line (the D./Sync/data/ path needs to be changed according where the data was downloaded):
Currently rGEDI function gediWFMetrics() in same_height.R gives an error due to most posisbly a bug because during reading back the extracted txt file it expects one more "." in the filename. For example extracted txt: sim 24250500400127557.metric.txt, expected by the software: sim 24250500400127557..metric.txt.

```
Rscript download_gedi.R D:/Sync/data/
Rscript download_ALS.R -p D:/Sync/data/ -s level1b_clip_nl_shp.shp
Rscript same_height.R -d D:/Sync/data/ -p 2425050040012755
```

With the command.txt it is possible to use GNU parallel package to parallel process several pulses related data to simulate the waveform and extract height and compare to the original GEDI waveform.
