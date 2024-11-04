library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024 multiplot.csv'
file_data <- read.csv(input.csv)

low_stratum <- subset(file_data, Stratum == '0-30')
high_stratum <- subset(file_data, Stratum == '30-100')

biomass_types <- names(file_data)[5:15]
# print(biomass_types)

k <- 1

for (type in biomass_types) {
  
  biomass_type = type
  
  spatial_low <- SpatialPointsDataFrame(
    coords = low_stratum[, c("multiplot_x", "multiplot_y")],
    data = subset(low_stratum, select = biomass_type)
  )
  
  spatial_high <- SpatialPointsDataFrame(
    coords = high_stratum[, c("multiplot_x", "multiplot_y")],
    data = subset(high_stratum, select = biomass_type)
  )
  
  
  plot_layers = c(spatial_low, spatial_high)
  plot_layer_names = c("low_stratum_", "high_stratum_")
  
  for (i in 1:2) {
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
      #print(e)
    })
    dev.off()
    
  }
  
  low_png_files <- list.files(pattern = "^low_stratum_\\w*.png$")
  low_images <- image_join(lapply(low_png_files, image_read))
  combined_low_image <- image_append(low_images)
  #image_write(combined_low_image, path = 'combined_low_plots.png')
  for (file in low_png_files) {
    file.remove(file)
  }
  
  high_png_files <- list.files(pattern = "^high_stratum\\w*\\.png$")
  high_images <- image_join(lapply(high_png_files, image_read))
  combined_high_image <- image_append(high_images)
  #image_write(combined_high_image, path = 'combined_high_plots.png')
  for (file in high_png_files) {
    file.remove(file)
  }
  
  full_set <- image_append(c(combined_high_image, combined_low_image), stack = TRUE)
  image_write(full_set, path = glue("multiplot_variograms_", biomass_type, ".png"))
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

