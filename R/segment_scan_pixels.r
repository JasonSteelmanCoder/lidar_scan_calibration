## This script takes in las scans of entire macroplots.
## It outputs las scans of single voxels within those macroplots
## The voxels are defined by pixel_dimensions.json, which is made by define_pixels_inside_macroplot_circle.py.

require(lidR)
library("rjson")
require(sf)

## USER: put the paths to your macroplot las scans here
input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot2.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot3.las"

## USER: put the paths to your output folders here
output.folder1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las1"
output.folder2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las2"
output.folder3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las3"

## USER: put the path to the pixel dimensions json file here
pixel.dimensions <- fromJSON(file = "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json")

## create vectors to loop through
las.list <- c(input.las1, input.las2, input.las3)
output.folders <- c(output.folder1, output.folder2, output.folder3)

#print(pixel.dimensions)

## loop through the lists above
for (i in 1:3) {
  
  ## read in the macroplot lidar scan
  las <- readLAS(las.list[[i]])

  ## loop through the voxels defined in the .json file  
  for (k in 1:length(pixel.dimensions)) {

    ## cut out the voxel from the macroplot scan    
    pixel.las <- clip_rectangle(las, pixel.dimensions[[k]][["right_top_left_bottom"]][3], pixel.dimensions[[k]][["right_top_left_bottom"]][4], pixel.dimensions[[k]][["right_top_left_bottom"]][1], pixel.dimensions[[k]][["right_top_left_bottom"]][2])
    
    ## write the voxel as a new .las scan file
    writeLAS(pixel.las, file.path(output.folders[[i]], paste('pixel_', k, '.las', sep = '')))
    
  }  
}

