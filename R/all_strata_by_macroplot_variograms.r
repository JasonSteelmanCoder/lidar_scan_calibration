# This script makes one variogram for each unique combination of biomass type and macroplot.
# strata are combined
# variograms are also made for total biomass and fine_dead_fuels for each macroplot
# the figures populate to the same folder that the script is in
# this has been adjusted for clip plot centers

library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)

## USER: put the path to your input file here
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

## combine high and low strata into one value for each biomass type
## and add columns for total biomass and fine dead fuels by summing the other columns
all_strata_data <- file_data %>%
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

## split the data up into three macroplots
macroplot1_df <- subset(all_strata_data, Macroplot == 1)
macroplot2_df <- subset(all_strata_data, Macroplot == 2)
macroplot3_df <- subset(all_strata_data, Macroplot == 3)

## grab all of the different biomass types
biomass_types <- names(all_strata_data)[6:18]

## loop through the different biomass types
for (type in biomass_types) {
  
  biomass_type = type
  
  ## make a spatial data frame for each macroplot
  ## each data frame has columns for x, y, and the biomass for the current biomass type
  spatial_df1 <- SpatialPointsDataFrame(
    coords = macroplot1_df[, c("X", "Y")],
    data = subset(macroplot1_df, select = biomass_type)
  )
  
  spatial_df2 <- SpatialPointsDataFrame(
    coords = macroplot2_df[, c("X", "Y")],
    data = subset(macroplot2_df, select = biomass_type)
  )
  
  spatial_df3 <- SpatialPointsDataFrame(
    coords = macroplot3_df[, c("X", "Y")],
    data = subset(macroplot3_df, select = biomass_type)
  )

  ## make lists of variables to loop through  
  plot_layers = c(spatial_df1, spatial_df2, spatial_df3)
  plot_layer_names = c("macroplot1_", "macroplot2_", "macroplot3_")
  
  ## loop through the lists above
  for (i in 1:3) {

    ## make a formula like "ete ~ 1" for the variogram to use
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))

    ## make a name for the png file    
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    
    ## start up a device for writing png files
    png(filename = paste(clean_data_name, ".png", sep = ''))
    
    ## calculate a variogram
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
    
    ## a tryCatch is used here in case there is missing data
    ## the "error" function will run if there is no data for the current biomass type
    tryCatch({
      
      the_plot <- plot(variogram, multipanel = TRUE)
      ## customize the name of the variogram plot
      the_plot$main = clean_data_name
      ## save the plot to png
      plot(the_plot)
      
    }, error = function(e) {
      
      ## make a "plot" saying that there wasn't biomass data for this biomass type
      plot(1, 1, main = clean_data_name, type = 'n', ylab = "", xlab = "")
      text(x = 1, y = 1, labels = "biomass not found for this category", col = 'darkgrey')
      print(e)

    })
    
    ## exit the device that writes png files
    dev.off()
    
  }

}
