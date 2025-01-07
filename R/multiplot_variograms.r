# This script makes variogram panels that combine all macroplots, but are broken out by strata.
# multiplot variograms will populate to the folder that the script is in
# clip plot centers have been adjusted

library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)

## USER: put the path to your input csv here
input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024 multiplot.csv'

## grab the data and split it into high and low strata
file_data <- read.csv(input.csv)

low_stratum <- subset(file_data, Stratum == '0-30')
high_stratum <- subset(file_data, Stratum == '30-100')

## grab a list of the names of biomass types
biomass_types <- names(file_data)[5:15]

## loop through the different biomass types
for (type in biomass_types) {
  
  biomass_type = type
  
  ## make spatial data frames: one for the low stratum and one for the height stratum
  ## each spatial data frame contains an x column, a y column, and a column with biomass values for the current biomass type 
  spatial_low <- SpatialPointsDataFrame(
    coords = low_stratum[, c("multiplot_x", "multiplot_y")],
    data = subset(low_stratum, select = biomass_type)
  )
  
  spatial_high <- SpatialPointsDataFrame(
    coords = high_stratum[, c("multiplot_x", "multiplot_y")],
    data = subset(high_stratum, select = biomass_type)
  )
  
  ## set up variable names for low and high strata
  plot_layers = c(spatial_low, spatial_high)
  plot_layer_names = c("low_stratum_", "high_stratum_")

  ## do low stratum, then high stratum (denoted by 1, 2)   
  for (i in 1:2) {

    ## set up a formula like "ETE ~ 1" for the variogram model
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    ## make a name for the output image file
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    
    ## start a device that will make a png file
    png(filename = paste(clean_data_name, ".png", sep = ''))

    ## calculate a variogram
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))

    ## tryCatch is used in case there is no data for a particular biomass type
    ## if there is no data, the "error" function will run, creating a different plot that says there is no data
    tryCatch({
      
      the_plot <- plot(variogram, multipanel = TRUE)
      ## change the title of the variogram plot
      the_plot$main = clean_data_name
      ## save the plot to a png
      plot(the_plot)
      
    }, error = function(e) {
      
      ## make a "plot" that says there is no data
      plot(1, 1, main = clean_data_name, type = 'n', ylab = "", xlab = "")
      text(x = 1, y = 1, labels = "biomass not found for this category", col = 'darkgrey')

    })
    
    ## exit the device that writes png files
    dev.off()
    
  }
  
  ## combine the low and high stratum images for the current biomass type
  ## note: there is only one low and one high image for the current biomass type, 
  ## even though some of the variables suggest otherwise. This is because this script 
  ## was originally written to make a panel with a larger number of variograms, then modified
  ## to only make one per strata per biomass type
  
  low_png_files <- list.files(pattern = "^low_stratum_\\w*.png$")
  low_images <- image_join(lapply(low_png_files, image_read))
  combined_low_image <- image_append(low_images)
  #image_write(combined_low_image, path = 'combined_low_plots.png')
  ## the original image is not needed anymore, and can be deleted 
  for (file in low_png_files) {
    file.remove(file)
  }
  
  high_png_files <- list.files(pattern = "^high_stratum\\w*\\.png$")
  high_images <- image_join(lapply(high_png_files, image_read))
  combined_high_image <- image_append(high_images)
  #image_write(combined_high_image, path = 'combined_high_plots.png')
  ## the original image is not needed anymore, and can be deleted
  for (file in high_png_files) {
    file.remove(file)
  }
  
  ## write the two variograms into one combined image
  full_set <- image_append(c(combined_high_image, combined_low_image), stack = TRUE)
  image_write(full_set, path = glue("multiplot_variograms_", biomass_type, ".png"))
  
}

