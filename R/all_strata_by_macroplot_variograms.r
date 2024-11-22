library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv'
file_data <- read.csv(input.csv)

file_data$X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

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
    .groups = 'keep'
  )
#print(all_strata_data)

macroplot1_df <- subset(all_strata_data, Macroplot == 1)
macroplot2_df <- subset(all_strata_data, Macroplot == 2)
macroplot3_df <- subset(all_strata_data, Macroplot == 3)

biomass_types <- names(all_strata_data)[6:17]

for (type in biomass_types) {
  
  biomass_type = type
  
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

  
  plot_layers = c(spatial_df1, spatial_df2, spatial_df3)
  plot_layer_names = c("macroplot1_", "macroplot2_", "macroplot3_")
  
  for (i in 1:3) {
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

}

