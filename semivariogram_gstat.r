library(gstat)
library(sp)
library(dplyr)
library(stringr)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv'
file_data <- read.csv(input.csv)

file_data$X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

macroplot1_low <- subset(file_data, Macroplot == 1 & Stratum == '0-30')

coordinates(macroplot1_low) <- ~X+Y

v <- variogram(ETE~1, macroplot1_low, cutoff = 13)
plot(v)

v.model <- vgm(psill = 170, model = "Sph", range = 0.5, nugget = 140)
v.fit <- fit.variogram(v, v.model, fit.method = 2)      
print(v.model)
plot(v.model, cutoff = 13)

