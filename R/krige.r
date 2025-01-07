# This script kriges each macroplot for each biomass type. 
# It outputs png images of kriged plots and a csv with apparent biomass, weighted biomass, and kriged biomass
# This script has been adjusted for clip plot centers.

library(gstat)
library(sp)
library(automap)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)
library(ggplot2)

## USER: put the paths to your input files here
input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv'
previous.estimations.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/macroplot_biomass_estimations.csv'
output.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/kriged_biomass_estimations.csv'
image.output.folder <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/kriged_images/'

## start grabbing the data
file_data <- read.csv(input.csv)

## extract the edge coordinates from the names of the clip plots
file_data$nominal_X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$nominal_Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

## make the edge coordinates into the center coordinates for each clip plot
file_data$magnitude <- sqrt(file_data$nominal_X^2 + file_data$nominal_Y^2)
file_data$multiples_of_quarter <- file_data$magnitude / 0.25
file_data$quarter_X <- file_data$nominal_X / file_data$multiples_of_quarter
file_data$quarter_Y <- file_data$nominal_Y / file_data$multiples_of_quarter
file_data$X <- file_data$nominal_X + file_data$quarter_X
file_data$Y <- file_data$nominal_Y + file_data$quarter_Y


## combine low and high strata into a single value for each biomass type
## and add columns for total biomass and fine dead fuels
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
    'fine_dead_fuels' = sum(CL) + sum(ETE) + sum(FL) + sum(PN) + sum(Wlit.BL),
    .groups = 'keep'
  )

## chunk the data into three different macroplots
macroplot1 <- subset(file_data, Macroplot == 1)
macroplot2 <- subset(file_data, Macroplot == 2)
macroplot3 <- subset(file_data, Macroplot == 3)

## grab a list of the biomass types
biomass_types <- names(file_data)[6:18]
print(biomass_types)

## grab the previous estimates from csv
biomass_estimates <- read.csv(previous.estimations.csv)
biomass_estimates["kriged_biomass"] <- NA

## loop through the biomass types
for (type in biomass_types) {
  
  biomass_type = type
  
  ## set up spatial data frames for each macroplot
  ## spatial data frames have columns for x, y, and biomass
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
  
  ## set up lists of variables to loop through
  plot_layers = c(spatial_df1, spatial_df2, spatial_df3)
  plot_layer_names = c("macroplot1_", "macroplot2_", "macroplot3_")

  ## set up a grid  
  origin <- c(x0 = 0, y0 = 0)
  radius <- 10
  grid_points <- expand.grid(
    x = seq(-radius, radius, by = 0.5),
    y = seq(-radius, radius, by = 0.5)
  )
  
  ## cut the grid into a (pixelated) circle the size of the macroplot
  grid_points <- grid_points[
    (grid_points$x - origin[["x0"]])^2 + (grid_points$y - origin[["y0"]])^2 <= radius^2,
  ]
  coordinates(grid_points) <- ~x + y
  
  ## loop through the macroplots  
  for (i in 1:3) {
    
    ## make a formula like "ete ~ 1" for the variogram model to use
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))

    ## make a name for the png file    
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    
    ## calculate a variogram
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
    
    ## perform krigeing using the variogram
    kriged <- krige(formula, plot_layers[[i]], newdata=grid_points, model = variogram$var_model)

    ## make a data frame from the krigeing results
    kriging_df <- as.data.frame(kriged)
    
    ## plot the krigeing results
    this_plot <- ggplot(kriging_df, aes(x = x, y = y, fill = var1.pred)) + 
      geom_tile() + 
      coord_fixed() + 
      scale_fill_viridis_c() +
      labs(title = paste("Macroplot", i, '\n', data_name, sep = ' '), fill = "Prediction")
    #print(this_plot)
    file_name <- paste(clean_data_name, '.png', sep = '')
    
    ## save plots to image file
    ggsave(file.path(image.output.folder, file_name), this_plot)
    
    #print(c(paste("Macroplot", i, data_name, sep = ' '), sum(kriged$var1.pred)))
    
    ## sum the kriged predictions to estimate biomass for the whole macroplot
    total <- sum(kriged$var1.pred)
    if (is.na(total)) {
      total = 0  
    } 

    ## put the estimated biomass predictions for the whole macroplot in a data frame    
    biomass_estimates$kriged_biomass[biomass_estimates$macroplot == i & biomass_estimates$biomass_type == data_name] = total

    }
}

print(biomass_estimates)

## uncomment to save the results to a csv file
#write.csv(biomass_estimates, output.csv, row.names = FALSE)




