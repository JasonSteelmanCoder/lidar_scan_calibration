library("rjson")
library("sp")
library("automap")
library("png")

## grab the data
coordinates.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json"
structural.variables.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/standardized_structural_variables.csv"

coordinates <- fromJSON(file = coordinates.path)
structural.variables <- read.csv(structural.variables.path)

## add columns for the coordinates of voxel center
structural.variables$x <- NA
structural.variables$y <- NA

## loop through the voxels in both data sources
for (i in 1:272) {
  
  ## assign each voxel an x and a y coordinate 
  structural.variables[structural.variables$voxel_number == i, "x"] <- coordinates[[i]]$centerpoint[[1]]
  structural.variables[structural.variables$voxel_number == i, "y"] <- coordinates[[i]]$centerpoint[[2]]

}

## break the data frame up into individual macroplots
macroplot1 <- subset(structural.variables, macroplot == 1)
macroplot2 <- subset(structural.variables, macroplot == 2)
macroplot3 <- subset(structural.variables, macroplot == 3)

## loop through the macroplots
for (macroplot in list(macroplot1, macroplot2, macroplot3)) {
  
  
  ## make spatial data frames with the data and coordinates
  spatial_df <- SpatialPointsDataFrame(
    
    coords = macroplot[ , c("x", "y")],
    data = as.data.frame(macroplot["standardized_mean_height"])
    
  )
  
  print(spatial_df)
  
  variogram = autofitVariogram(

    formula = as.formula("standardized_mean_height ~ 1"), 
    input_data = spatial_df, 
    verbose = FALSE, 
    miscFitOptions = list(merge.small.bins = TRUE)
  
  )
  
  plot(variogram)
  
}



