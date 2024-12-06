require(lidR)
library("rjson")
require(sf)

input.las <- "C:/Users/js81535/Desktop/lidar_scan_calibration/third_modded_HEF_0001_20231127_1.las"
coordinates.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/coordinates.json"
output.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las"

las <- readLAS(input.las)
coordinates <- fromJSON(file = coordinates.path)

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

  writeLAS(clip.plot.las, file.path(output.path, paste(name, '.las')))
  
}

