# This program makes a variogram for fine_dead_fuels in all strata, across all three macroplots
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

## sum the high and low strata into one value for each biomass type
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

## add a column for fine.dead.fuels by summing the relevant biomass types
all_strata_data$fine.dead.fuels <- all_strata_data$CL + all_strata_data$ETE + all_strata_data$FL + all_strata_data$PN + all_strata_data$Wlit.BL
print(all_strata_data$fine.dead.fuels)

## we are only interested in one biomass type: fine.dead.fuels
## however we put it in a list because this script was adapted from a script where we had multiple types
biomass_types <- c("fine.dead.fuels")

## looping through biomass types only results in the code running once: for fine.dead.fuels
for (type in biomass_types) {
  
  biomass_type = type
  
  ## build a spatial data frame. 
  ## the data frame will include columns for x, y, and biomass
  spatial <- SpatialPointsDataFrame(
    coords = all_strata_data[, c("multiplot_x", "multiplot_y")],
    data = subset(all_strata_data, select = biomass_type)
  )
  
  ## we only have one data frame, but we put it in a list because this script was adapted
  ## from a script where we had several
  plot_layers = c(spatial)
  plot_layer_names = c("all_strata_")
  
  ## run this code for the one spatial data frame that we have
  for (i in 1:1) {
    
    ## make a formula like "find.dead.fuels ~ 1" to be used by the variogram model
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    ## make a name for the png file
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    
    ## open a device that can write a png file
    png(filename = paste(clean_data_name, ".png", sep = ''))
    
    ## calculate a variogram
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))

    ## tryCatch is used here in case there is no data 
    ## if there is no data, the "error" function will run
    tryCatch({
      
      the_plot <- plot(variogram, multipanel = TRUE)
      ## customize the name of the plot
      the_plot$main = clean_data_name
      ## save the plot to png
      plot(the_plot)
      
    }, error = function(e) {
      
      ## make a "plot" that says there is no data
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




