## This program takes in lidar scans of macroplots and the coordinates of clip plots in those macroplots.
## It outputs lidar scans of each clip plot, cut out of the larger macroplots.

require(lidR)
library("rjson")
require(sf)

## USER: put the paths to the lidar scans of the macroplots here (in .las format)
input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot2.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot3.las"

## USER: put the paths to the clip plot coordinates here (in .json format)
coordinates.path1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/coordinates_macroplot1.json"
coordinates.path2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/coordinates_macroplot2.json"
coordinates.path3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/coordinates_macroplot3.json"

## USER: put the paths to your output folders here
output.path1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las1"
output.path2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las2"
output.path3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las3"

## set up vectors of variables to loop through
las_list <- c(input.las1, input.las2, input.las3)
coordinates_list <- c(coordinates.path1, coordinates.path2, coordinates.path3)
output_list <- c(output.path1, output.path2, output.path3)

## loop through each of the three macroplots
for (i in 1:3) {

  ## read in the lidar scan and the coordinates
  las <- readLAS(las_list[[i]])
  coordinates <- fromJSON(file = coordinates_list[[i]])
  
  ## loop through the clip plots
  for (clip.plot in coordinates) {

    ## set variables for name and coordinates of the current clip plot
    name <- clip.plot$name
    
    outer_left_x <- clip.plot$outer_left_x
    outer_left_y <- clip.plot$outer_left_y
    inner_left_x <- clip.plot$inner_left_x
    inner_left_y <- clip.plot$inner_left_y
    inner_right_x <- clip.plot$inner_right_x
    inner_right_y <- clip.plot$inner_right_y
    outer_right_x <- clip.plot$outer_right_x
    outer_right_y <- clip.plot$outer_right_y

    ## use the coordinates to define a voxel in the lidar scan     
    coords <- matrix(c(outer_left_x, outer_left_y,
                       inner_left_x, inner_left_y,
                       inner_right_x, inner_right_y,
                       outer_right_x, outer_right_y,
                       outer_left_x, outer_left_y),
                     ncol = 2, byrow = TRUE)
    
    cp_polygon <- st_polygon(list(coords))
  
    ## cut out the voxel from the macroplot scan
    clip.plot.las <- clip_roi(las, cp_polygon)
  
    ## uncomment to plot the output (note that this will open a large number of windows)
    #plot(clip.plot.las)
  
    ## write the cropped scan of the clip plot to a new file
    writeLAS(clip.plot.las, file.path(output_list[[i]], paste(name, '.las', sep = '')))

    }
}

