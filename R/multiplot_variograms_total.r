# this program makes a panel of two variograms--one for each stratum.
# the variograms represent total biomass for their strata across all three macroplots
# coordinates have been adjusted for clip plot centers

library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)

## USER: put the path to your input file here
input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024 multiplot.csv'
file_data <- read.csv(input.csv)

## add a column for total biomass, by summing together all of the other biomass columns
file_data$total.biomass <- file_data$X1000hr + file_data$X100hr + file_data$X10hr + file_data$X1hr + file_data$CL + file_data$ETE + file_data$FL + file_data$PC + file_data$PN + file_data$Wlit.BL + file_data$Wlive.BL
print(file_data)

## split the data into two strata
low_stratum <- subset(file_data, Stratum == '0-30')
high_stratum <- subset(file_data, Stratum == '30-100')

## we are only interested in the total biomass column
## however, we put it in a list, since this script is adapted from a script with many biomass types
biomass_types <- c("total.biomass")
# print(biomass_types)

## there is only one biomass type in the list, so looping through the types means just doing this for total.biomass
for (type in biomass_types) {
  
  biomass_type = type

  ## make spatial data frames for high and low strata
  ## the spatial data frames have an x column, a y column, and a column for total.biomass
  spatial_low <- SpatialPointsDataFrame(
    coords = low_stratum[, c("multiplot_x", "multiplot_y")],
    data = subset(low_stratum, select = biomass_type)
  )
  
  spatial_high <- SpatialPointsDataFrame(
    coords = high_stratum[, c("multiplot_x", "multiplot_y")],
    data = subset(high_stratum, select = biomass_type)
  )
  
  ## make lists of variables to loop through  
  plot_layers = c(spatial_low, spatial_high)
  plot_layer_names = c("low_stratum_", "high_stratum_")
  
  ## loop through the lists above
  for (i in 1:2) {

    ## make a formula like "total.biomass ~ 1" for the variogram model to use
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    ## make a name for the png file
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    
    ## start a device that will write a png file
    png(filename = paste(clean_data_name, ".png", sep = ''))
    
    ## calculate a variogram
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))

    ## tryCatch is used in case there is any missing data
    ## the "error" function will run if the data is missing
    tryCatch({
      
      the_plot <- plot(variogram, multipanel = TRUE)
      ## customize the name of the plot
      the_plot$main = clean_data_name
      ## save the plot to png
      plot(the_plot)
      
    }, error = function(e) {

      ## make a "plot" that says that biomass data is not found      
      plot(1, 1, main = clean_data_name, type = 'n', ylab = "", xlab = "")
      text(x = 1, y = 1, labels = "biomass not found for this category", col = 'darkgrey')
      
    })
    
    ## exit the device that writes a png
    dev.off()
    
  }

  ## combine the low and high strata variograms into one image
  ## note that there is only one high and one low in each iteration, 
  ## but we treat it as a list because this script is adapted from one 
  ## with multiple plots per iteration.
  low_png_files <- list.files(pattern = "^low_stratum_\\w*.png$")
  low_images <- image_join(lapply(low_png_files, image_read))
  combined_low_image <- image_append(low_images)
  #image_write(combined_low_image, path = 'combined_low_plots.png')
  ## original files can be deleted, since they will be combined into a new image
  for (file in low_png_files) {
    file.remove(file)
  }
  
  high_png_files <- list.files(pattern = "^high_stratum\\w*\\.png$")
  high_images <- image_join(lapply(high_png_files, image_read))
  combined_high_image <- image_append(high_images)
  #image_write(combined_high_image, path = 'combined_high_plots.png')
  ## original files can be deleted, since they will be combined into a new image
  for (file in high_png_files) {
    file.remove(file)
  }

  ## combine the low and high strata variograms into one image and save as png  
  full_set <- image_append(c(combined_high_image, combined_low_image), stack = TRUE)
  image_write(full_set, path = glue("multiplot_variograms_", biomass_type, ".png"))
  
}

