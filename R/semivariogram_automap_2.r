# find variogram panels broken out by stratum and macroplot
# this has been adjusted for clip plot centers

library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv'
file_data <- read.csv(input.csv)

# extract the edge coordinates from the names of the clip plots
file_data$nominal_X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$nominal_Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

# make the edge coordinates into the center coordinates for each clip plot
file_data$magnitude <- sqrt(file_data$nominal_X^2 + file_data$nominal_Y^2)
file_data$multiples_of_quarter <- file_data$magnitude / 0.25
file_data$quarter_X <- file_data$nominal_X / file_data$multiples_of_quarter
file_data$quarter_Y <- file_data$nominal_Y / file_data$multiples_of_quarter
file_data$X <- file_data$nominal_X + file_data$quarter_X
file_data$Y <- file_data$nominal_Y + file_data$quarter_Y


macroplot1_low <- subset(file_data, Macroplot == 1 & Stratum == '0-30')
macroplot2_low <- subset(file_data, Macroplot == 2 & Stratum == '0-30')
macroplot3_low <- subset(file_data, Macroplot == 3 & Stratum == '0-30')
macroplot1_high <- subset(file_data, Macroplot == 1 & Stratum == '30-100')
macroplot2_high <- subset(file_data, Macroplot == 2 & Stratum == '30-100')
macroplot3_high <- subset(file_data, Macroplot == 3 & Stratum == '30-100')

biomass_types <- names(file_data)[5:15]
print(biomass_types)

k <- 1

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
  
  
  
  plot_layers = c(spatial_df1_low, spatial_df2_low, spatial_df3_low, spatial_df1_high, spatial_df2_high, spatial_df3_high)
  plot_layer_names = c("macroplot1_low_", "macroplot2_low_", "macroplot3_low_", "macroplot1_high_", "macroplot2_high_", "macroplot3_high_")
  
  for (i in 1:6) {
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
  
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    png(filename = paste(clean_data_name, ".png", sep = ''))
      variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
      tryCatch({
        the_plot <- plot(variogram, multipanel = TRUE)
        the_plot$main = clean_data_name
        plot(the_plot)
      }, error = function(e) {
        plot(1, 1, main = clean_data_name, type = 'n', ylab = "", xlab = "")
        text(x = 1, y = 1, labels = "biomass not found for this category", col = 'darkgrey')
        print(e)
      })
    dev.off()
    
  }
  
  low_png_files <- list.files(pattern = "^macroplot\\w*low\\w*.png$")
  low_images <- image_join(lapply(low_png_files, image_read))
  combined_low_image <- image_append(low_images)
  #image_write(combined_low_image, path = 'combined_low_plots.png')
  for (file in low_png_files) {
    file.remove(file)
  }
  
  high_png_files <- list.files(pattern = "^macroplot\\w*high\\w*\\.png$")
  high_images <- image_join(lapply(high_png_files, image_read))
  combined_high_image <- image_append(high_images)
  #image_write(combined_high_image, path = 'combined_high_plots.png')
  for (file in high_png_files) {
    file.remove(file)
  }
  
  full_set <- image_append(c(combined_high_image, combined_low_image), stack = TRUE)
  image_write(full_set, path = glue("variograms_", biomass_type, ".png"))
  k <- k + 1

}

#methods("plot")
#getAnywhere("plot.variogramMap")

#setwd("C:/Users/js81535/Desktop/lidar_scan_calibration/")
#getwd()
#dev.list()
#dev.new()
#dev.set(2)
#dev.off()


