library(gstat)
library(sp)
library(automap)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)
library(ggplot2)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv'
file_data <- read.csv(input.csv)

file_data$X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

macroplot1_low <- subset(file_data, Macroplot == 1 & Stratum == '0-30')
macroplot2_low <- subset(file_data, Macroplot == 2 & Stratum == '0-30')
macroplot3_low <- subset(file_data, Macroplot == 3 & Stratum == '0-30')
macroplot1_high <- subset(file_data, Macroplot == 1 & Stratum == '30-100')
macroplot2_high <- subset(file_data, Macroplot == 2 & Stratum == '30-100')
macroplot3_high <- subset(file_data, Macroplot == 3 & Stratum == '30-100')

biomass_types <- names(file_data)[5:15]
print(biomass_types)

for (type in biomass_types) {
  
  biomass_type = type
  
  spatial_df1_low <- SpatialPointsDataFrame(
    coords = macroplot1_low[, c("X", "Y")],
    data = subset(macroplot1_low, select = biomass_type)
  )
  
  spatial_df2_low <- SpatialPointsDataFrame(
    coords = macroplot2_low[, c("X", "Y")],
    data = subset(macroplot2_low, select = biomass_type)
  )
  
  spatial_df3_low <- SpatialPointsDataFrame(
    coords = macroplot3_low[, c("X", "Y")],
    data = subset(macroplot3_low, select = biomass_type)
  )
  
  spatial_df1_high <- SpatialPointsDataFrame(
    coords = macroplot1_high[, c("X", "Y")],
    data = subset(macroplot1_high, select = biomass_type)
  )
  
  spatial_df2_high <- SpatialPointsDataFrame(
    coords = macroplot2_high[, c("X", "Y")],
    data = subset(macroplot2_high, select = biomass_type)
  )
  
  spatial_df3_high <- SpatialPointsDataFrame(
    coords = macroplot3_high[, c("X", "Y")],
    data = subset(macroplot3_high, select = biomass_type)
  )
  
  low_plot_layers = c(spatial_df1_low, spatial_df2_low, spatial_df3_low)
  high_plot_layers = c(spatial_df1_high, spatial_df2_high, spatial_df3_high)
  low_plot_layer_names = c("macroplot1_low_", "macroplot2_low_", "macroplot3_low_")
  high_plot_layer_names = c("macroplot1_high_", "macroplot2_high_", "macroplot3_high_")
  
  origin <- c(x0 = 0, y0 = 0)
  radius <- 10
  grid_points <- expand.grid(
    x = seq(-radius, radius, by = 0.1),
    y = seq(-radius, radius, by = 0.1)
  )
  grid_points <- grid_points[
    (grid_points$x - origin[["x0"]])^2 + (grid_points$y - origin[["y0"]])^2 <= radius^2,
  ]
  coordinates(grid_points) <- ~x + y
    
  for (i in 1:3) {
    data_name <- names(low_plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    clean_data_name <- glue(low_plot_layer_names[[i]], gsub("\\.", "", data_name))
    variogram = autofitVariogram(formula = formula, input_data = low_plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
    kriged <- krige(formula, low_plot_layers[[i]], newdata=grid_points, model = variogram$var_model)
    kriging_df <- as.data.frame(kriged)
    print(ggplot(kriging_df, aes(x = x, y = y, fill = var1.pred)) + 
      geom_tile() + 
      coord_fixed() + 
      scale_fill_viridis_c() +
      labs(title = paste("Macroplot", i, '\n', data_name, sep = ' '), fill = "Prediction")
    )
  }
}