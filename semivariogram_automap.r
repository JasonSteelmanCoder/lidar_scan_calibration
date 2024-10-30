library(automap)
library(sp)
library(dplyr)
library(stringr)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv'
file_data <- read.csv(input.csv)

file_data$X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

macroplot1_low <- subset(file_data, Macroplot == 1 & Stratum == '0-30')

spatial_df <- SpatialPointsDataFrame(
  coords = macroplot1_low[, c("X", "Y")],
  data = data.frame(macroplot1_low[, "ETE"])
)

print(spatial_df)

print(spatial_df$macroplot1_low....ETE..)

variogram = autofitVariogram(formula = macroplot1_low....ETE..~1, input_data = spatial_df, verbose = TRUE, miscFitOptions = list(merge.small.bins = FALSE))
plot(variogram)
print(variogram)

