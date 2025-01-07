# This program makes single variograms for each biomass type that combine all strata and all macroplots.
# It has been adjusted for clip plot centers

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

## combine high and low strata into single values for each biomass type
all_strata_data <- file_data %>% 
  group_by(Macroplot, Clip.Plot, Coordinates, multiplot_x, multiplot_y) %>%
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
    .groups = "keep"
  )
print(all_strata_data)

## grab the names of all the biomass types
biomass_types <- names(file_data)[5:15]

## loop through all the boimass types
for (type in biomass_types) {
  
  biomass_type = type
  
  ## make a spatial data frame for the current biomass type
  ## the data frame will have columns for x, y, and biomass
  spatial <- SpatialPointsDataFrame(
    coords = all_strata_data[, c("multiplot_x", "multiplot_y")],
    data = subset(all_strata_data, select = biomass_type)
  )
  
  ## there is only one spatial data frame per iteration
  ## but we put them in a list because this program is adapted from 
  ## a program where there were several
  plot_layers = c(spatial)
  plot_layer_names = c("all_strata_")
  
  ## this loop is really just running the code once for the spatial data frame on this iteration
  for (i in 1:1) {
    
    ## make a formula like "ete ~ 1" for the variogram model to use
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    ## make a name for the png file
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    
    ## start a device that can write a png file
    png(filename = paste(clean_data_name, ".png", sep = ''))
    
    ## calculate a variogram
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
    
    ## tryCatch is used here in case there is no data for a certain biomass type
    ## the "error" function will run if there is no data
    tryCatch({
      
      the_plot <- plot(variogram, multipanel = TRUE)
      ## customize the name of the variogram plot
      the_plot$main = clean_data_name
      ## save the plot to png
      plot(the_plot)
      
    }, error = function(e) {
      
      ## make a "plot" that says that there is no data for this biomass type
      plot(1, 1, main = clean_data_name, type = 'n', ylab = "", xlab = "")
      text(x = 1, y = 1, labels = "biomass not found for this category", col = 'darkgrey')

    })

    ## exit from the device that writes png files    
    dev.off()
    
  }
  
  png_files <- list.files(pattern = "^low_stratum_\\w*.png$")
  images <- image_join(lapply(png_files, image_read))
  combined_low_image <- image_append(images)
  #image_write(combined_low_image, path = 'combined_low_plots.png')
  for (file in png_files) {
    file.remove(file)
  }
  
  #full_set <- image_append(c(combined_high_image, combined_low_image), stack = TRUE)
  #image_write(full_set, path = glue("multiplot_variograms_", biomass_type, ".png"))
  
}




