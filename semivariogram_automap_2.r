library(automap)
library(sp)
library(dplyr)
library(stringr)

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

spatial_df1_low <- SpatialPointsDataFrame(
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

pdf("ETE_plots.pdf")
par(mfrow = c(2, 3))

for (layer in plot_layers) {
  data_name <- names(layer)[1]
  formula <- as.formula(paste(data_name, '~ 1'))

  variogram = autofitVariogram(formula = formula, input_data = layer, verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
  plot(variogram, sub = names(layer))
  #print(variogram)
}

dev.off()



