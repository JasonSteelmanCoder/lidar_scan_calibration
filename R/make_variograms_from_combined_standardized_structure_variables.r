library("rjson")
library("sp")
library("automap")
library(dplyr)

## grab the data
coordinates.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json"
structural.variables.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/standardized_structural_variables.csv"

coordinates <- fromJSON(file = coordinates.path)
structural.variables <- read.csv(structural.variables.path)

## add columns for the coordinates of voxel center
structural.variables$x <- NA
structural.variables$y <- NA

## set the offset for the different macroplots
## the origin of our coordinate system is macroplot 3's plot center.
macroplot1_x_offset <- 28.9245
macroplot1_y_offset <- -7.2117
macroplot2_x_offset <- 27.7773
macroplot2_y_offset <- 15.3972
  
## loop through the voxels in both data sources
for (i in 1:272) {
  
  ## assign each voxel an x and a y coordinate 
  ## note that for now, x and y represent the within-macroplot coordinates--not the final, combined coordinates
  structural.variables[structural.variables$voxel_number == i, "x"] <- coordinates[[i]]$centerpoint[[1]]
  structural.variables[structural.variables$voxel_number == i, "y"] <- coordinates[[i]]$centerpoint[[2]]
  
}

## translate the x and y coordinates to arrange all three plots using a unified coordinate system
structural.variables <- structural.variables %>%
    mutate(x = if_else(macroplot == 1, x + macroplot1_x_offset, x)) %>%
    mutate(x = if_else(macroplot == 2, x + macroplot2_x_offset, x)) %>%
    mutate(y = if_else(macroplot == 1, y + macroplot1_y_offset, y)) %>%
    mutate(y = if_else(macroplot == 2, y + macroplot2_y_offset, y))

## uncomment to see the resulting coordinates
#print(structural.variables)
#plot(structural.variables$x, structural.variables$y)

## set up a list of names for the structural variables
st_vars <- c(
  "standardized_point_density_in_stratum2", 
  "standardized_pct_points_in_stratum2", 
  "standardized_mean_height"
)

## loop through the structural variables
for (var in st_vars) {
  
  ## make spatial data frames with the data and coordinates
  spatial_df <- SpatialPointsDataFrame(
    
    coords = structural.variables[ , c("x", "y")],
    data = as.data.frame(structural.variables[var])
    
  )
  
  ## make a variogram 
  variogram = autofitVariogram(
    
    formula = as.formula(paste(var, "~ 1")), 
    input_data = spatial_df, 
    verbose = FALSE, 
    miscFitOptions = list(merge.small.bins = TRUE)
    
  )
  
  ## change the title of the variogram  
  ## note: this will plot the variogram twice: once with a generic title and once with the desired title
  the_plot <- plot(variogram)
  the_plot$main = paste(var, "across combined macroplots")
  plot(the_plot)
  
}






