library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv'
file_data <- read.csv(input.csv)

file_data$X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

macroplot1_low <- subset(file_data, Macroplot == 1 & Stratum == '0-30')
macroplot2_low <- subset(file_data, Macroplot == 2 & Stratum == '0-30')
macroplot3_low <- subset(file_data, Macroplot == 3 & Stratum == '0-30')
macroplot1_high <- subset(file_data, Macroplot == 1 & Stratum == '30-100')
macroplot2_high <- subset(file_data, Macroplot == 2 & Stratum == '30-100')
macroplot3_high <- subset(file_data, Macroplot == 3 & Stratum == '30-100')

spatial_df1_low <- SpatialPointsDataFrame(
  coords = macroplot1_low[, c("X", "Y")],
  data = data.frame(macroplot1_low[, "ETE"])
)

spatial_df2_low <- SpatialPointsDataFrame(
  coords = macroplot2_low[, c("X", "Y")],
  data = data.frame(macroplot2_low[, "ETE"])
)

spatial_df3_low <- SpatialPointsDataFrame(
  coords = macroplot3_low[, c("X", "Y")],
  data = data.frame(macroplot3_low[, "ETE"])
)

spatial_df1_high <- SpatialPointsDataFrame(
  coords = macroplot1_high[, c("X", "Y")],
  data = data.frame(macroplot1_high[, "ETE"])
)

spatial_df2_high <- SpatialPointsDataFrame(
  coords = macroplot2_high[, c("X", "Y")],
  data = data.frame(macroplot2_high[, "ETE"])
)

spatial_df3_high <- SpatialPointsDataFrame(
  coords = macroplot3_high[, c("X", "Y")],
  data = data.frame(macroplot3_high[, "ETE"])
)

plot_layers = c(spatial_df1_low, spatial_df2_low, spatial_df3_low, spatial_df1_high, spatial_df2_high, spatial_df3_high)

for (layer in plot_layers) {
  data_name <- names(layer)[1]
  formula <- as.formula(paste(data_name, '~ 1'))

  clean_data_name <- gsub("\\.+", "_", data_name)
  print(clean_data_name)
  png(filename = paste(clean_data_name, ".png", sep = ''))
    variogram = autofitVariogram(formula = formula, input_data = layer, verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
    plot(variogram, sub = names(layer), multipanel = TRUE)
  dev.off()
  
}

low_png_files <- list.files(pattern = "^macroplot\\w*low\\w*.png$")
low_images <- image_join(lapply(low_png_files, image_read))
combined_low_image <- image_append(low_images)
#image_write(combined_low_image, path = 'combined_low_plots.png')
for (file in low_png_files) {
  file.remove(file)
}

high_png_files <- list.files(pattern = "^macroplot\\w*high\\w*.png$")
high_images <- image_join(lapply(high_png_files, image_read))
combined_high_image <- image_append(high_images)
#image_write(combined_high_image, path = 'combined_high_plots.png')
for (file in high_png_files) {
  file.remove(file)
}

full_set <- image_append(c(combined_high_image, combined_low_image), stack = TRUE)
image_write(full_set, path = "full_set.png")

#methods("plot")
#getAnywhere("plot.variogramMap")

#setwd("C:/Users/js81535/Desktop/lidar_scan_calibration/")
#getwd()
#dev.list()
#dev.new()
#dev.set(2)
#dev.off()

