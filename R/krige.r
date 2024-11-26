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

file_data <- file_data %>%
  group_by(Macroplot, Clip.Plot, Coordinates, X, Y) %>%
  summarize(
    'X1000hr' = sum(X1000hr),
    'X100hr' = sum(X100hr),
    'X10hr' = sum(X10hr),
    'X1hr' = sum(X1hr),
    'CL' = sum(CL),
    'ETE' = sum(ETE),
    'FL' = sum(FL),
    'PC' = sum(PC),
    'PN' = sum(PN),
    'Wlit.BL' = sum(Wlit.BL),
    'Wlive.BL' = sum(Wlive.BL),
    'total_biomass' = sum(X1000hr) + sum(X100hr) + sum(X10hr) + sum(X1hr) + sum(CL) + sum(ETE) + sum(FL) + sum(PC) + sum(PN) + sum(Wlit.BL) + sum(Wlive.BL),
    .groups = 'keep'
  )

macroplot1 <- subset(file_data, Macroplot == 1)
macroplot2 <- subset(file_data, Macroplot == 2)
macroplot3 <- subset(file_data, Macroplot == 3)

biomass_types <- names(file_data)[6:17]
print(biomass_types)

biomass_estimates <- data.frame(row.names = c("macroplot", "biomass_type", "kriged_biomass_estimate"))

for (type in biomass_types) {
  
  biomass_type = type
  
  spatial_df1 <- SpatialPointsDataFrame(
    coords = macroplot1[, c("X", "Y")],
    data = subset(macroplot1, select = biomass_type)
  )
  
  spatial_df2 <- SpatialPointsDataFrame(
    coords = macroplot2[, c("X", "Y")],
    data = subset(macroplot2, select = biomass_type)
  )
  
  spatial_df3 <- SpatialPointsDataFrame(
    coords = macroplot3[, c("X", "Y")],
    data = subset(macroplot3, select = biomass_type)
  )
  
  plot_layers = c(spatial_df1, spatial_df2, spatial_df3)
  plot_layer_names = c("macroplot1_", "macroplot2_", "macroplot3_")
  
  origin <- c(x0 = 0, y0 = 0)
  radius <- 10
  grid_points <- expand.grid(
    x = seq(-radius, radius, by = 0.5),
    y = seq(-radius, radius, by = 0.5)
  )
  grid_points <- grid_points[
    (grid_points$x - origin[["x0"]])^2 + (grid_points$y - origin[["y0"]])^2 <= radius^2,
  ]
  coordinates(grid_points) <- ~x + y
    
  for (i in 1:3) {
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
    kriged <- krige(formula, plot_layers[[i]], newdata=grid_points, model = variogram$var_model)
    kriging_df <- as.data.frame(kriged)
    print(ggplot(kriging_df, aes(x = x, y = y, fill = var1.pred)) + 
      geom_tile() + 
      coord_fixed() + 
      scale_fill_viridis_c() +
      labs(title = paste("Macroplot", i, '\n', data_name, sep = ' '), fill = "Prediction")
    )
    print(c(paste("Macroplot", i, data_name, sep = ' '), sum(kriged$var1.pred)))
    new_row <- data.frame(macroplot = i, biomass_type = data_name, kriged_biomass_estimate = sum(kriged$var1.pred))
    biomass_estimates <- rbind(biomass_estimates, new_row)
  }
}

print(biomass_estimates)


