require(lidR)
library("rjson")
require(sf)

input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot2.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot3.las"

coordinates.path1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/coordinates_macroplot1.json"
coordinates.path2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/coordinates_macroplot2.json"
coordinates.path3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/coordinates_macroplot3.json"

output.path1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las1"
output.path2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las2"
output.path3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las3"

las_list <- c(input.las1, input.las2, input.las3)
coordinates_list <- c(coordinates.path1, coordinates.path2, coordinates.path3)
output_list <- c(output.path1, output.path2, output.path3)

for (i in 1:3) {
  las <- readLAS(las_list[[i]])
  coordinates <- fromJSON(file = coordinates_list[[i]])
  
  for (clip.plot in coordinates) {
    name <- clip.plot$name
    
    outer_left_x <- clip.plot$outer_left_x
    outer_left_y <- clip.plot$outer_left_y
    inner_left_x <- clip.plot$inner_left_x
    inner_left_y <- clip.plot$inner_left_y
    inner_right_x <- clip.plot$inner_right_x
    inner_right_y <- clip.plot$inner_right_y
    outer_right_x <- clip.plot$outer_right_x
    outer_right_y <- clip.plot$outer_right_y
    
    coords <- matrix(c(outer_left_x, outer_left_y,
                       inner_left_x, inner_left_y,
                       inner_right_x, inner_right_y,
                       outer_right_x, outer_right_y,
                       outer_left_x, outer_left_y),
                     ncol = 2, byrow = TRUE)
    
    cp_polygon <- st_polygon(list(coords))
  
    clip.plot.las <- clip_roi(las, cp_polygon)
  
    #plot(clip.plot.las)
  
    writeLAS(clip.plot.las, file.path(output_list[[i]], paste(name, '.las', sep = '')))
  }
}

