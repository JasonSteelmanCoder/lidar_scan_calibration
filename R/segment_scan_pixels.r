require(lidR)
library("rjson")
require(sf)

input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot2.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot3.las"

output.folder1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las1"
output.folder2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las2"
output.folder3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las3"

pixel.dimensions <- fromJSON(file = "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json")

las.list <- c(input.las1, input.las2, input.las3)
output.folders <- c(output.folder1, output.folder2, output.folder3)

#print(pixel.dimensions)

for (i in 1:3) {
  
  las <- readLAS(las.list[[i]])
  
  for (k in 1:length(pixel.dimensions)) {
    
    pixel.las <- clip_rectangle(las, pixel.dimensions[[k]][["right_top_left_bottom"]][3], pixel.dimensions[[k]][["right_top_left_bottom"]][4], pixel.dimensions[[k]][["right_top_left_bottom"]][1], pixel.dimensions[[k]][["right_top_left_bottom"]][2])
    
    writeLAS(pixel.las, file.path(output.folders[[i]], paste('pixel_', k, '.las', sep = '')))
    
  }  
}

