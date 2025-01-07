# This program makes a variogram for total biomass in all strata, across all three macroplots
# the variogram will populate in the same folder as the script
# this has been adjusted for clip plot centers

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

## combine high and low strata into one value for each biomass type
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

## add a column for total.biomass by summing together all of the other biomass types
all_strata_data$total.biomass <- all_strata_data$X1000hr + all_strata_data$X100hr + all_strata_data$X10hr + all_strata_data$X1hr + all_strata_data$CL + all_strata_data$ETE + all_strata_data$FL + all_strata_data$PC + all_strata_data$PN + all_strata_data$Wlit.BL + all_strata_data$Wlive.BL

## we are only interested in the total.boimass column, but we put it in a list 
## because this script is adapted from a script where we were interested in more than one
biomass_types <- c("total.biomass")
# print(biomass_types)

## loop through the "list" of just one item
## in other words, run this code for "total.biomass"
for (type in biomass_types) {
  
  biomass_type = type
  
  ## make a spatial data frame with x, y, and biomass values
  spatial <- SpatialPointsDataFrame(
    coords = all_strata_data[, c("multiplot_x", "multiplot_y")],
    data = subset(all_strata_data, select = biomass_type)
  )
  
  ## we are only interested in one data frame, but we put its variables in lists
  ## because this script is adapted from another one where we were interested in several
  plot_layers = c(spatial)
  plot_layer_names = c("all_strata_")
  
  ## this code runs for just one data frame
  for (i in 1:1) {

    ## make a formula like "total.biomass ~ 1" for the variogram model to use    
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    ## make a name for the png file
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    
    ## start a device for wrigint png files
    png(filename = paste(clean_data_name, ".png", sep = ''))
    
    ## calculate a variogram
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))

    ## tryCatch is used here in case there is no data
    ## if there is no data, the "error" function will run
    tryCatch({
      
      the_plot <- plot(variogram, multipanel = TRUE)
      ## customize the title of the variogram
      the_plot$main = clean_data_name
      ## save the plot to the png file
      plot(the_plot)
      
    }, error = function(e) {
      
      ## make a "plot" that says that biomass data was not found
      plot(1, 1, main = clean_data_name, type = 'n', ylab = "", xlab = "")
      text(x = 1, y = 1, labels = "biomass not found for this category", col = 'darkgrey')
      
    })
    
    ## exit the device that writes png files
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




