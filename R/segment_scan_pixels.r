require(lidR)
library("rjson")
require(sf)

input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0001_20231127_1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0002_20231127_1.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0003_20231127_1.las"

output.folder1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las1"
output.folder2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las2"
output.folder3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las3"

pixel.dimensions <- fromJSON(file = "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json")

las.list <- c(input.las1, input.las2, input.las3)
output.folders <- c(output.folder1, output.folder2, output.folder3)

#print(pixel.dimensions)

for (i in 1:3) {
  m <- 1        # m tracks the number of the pixel being saved to file
  
  las <- readLAS(las.list[[i]])
  
  for (k in 1:length(pixel.dimensions)) {
    
    pixel.las <- clip_rectangle(las, pixel.dimensions[[k]][3], pixel.dimensions[[k]][4], pixel.dimensions[[k]][1], pixel.dimensions[[k]][2])
    
    writeLAS(pixel.las, file.path(output.folders[[i]], paste('pixel', m, '.las', sep = '')))
    
    m <- m + 1
  }  
}

