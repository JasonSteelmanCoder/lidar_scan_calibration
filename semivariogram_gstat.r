library(gstat)
library(sp)
library(dplyr)
library(stringr)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv'
data <- read.csv(input.csv)

data$X <- as.numeric(str_extract(data$Coordinates, "\\d+(\\.\\d+)?"))
data$Y <- as.numeric(str_extract(data$Coordinates, "(\\d+(\\.\\d+)?)\\]", group=1))

coordinates(data) <- ~X+Y

v <- variogram(ETE~1, data, cutoff = 13)
plot(v, main = "Semivariogram")

v.model <- vgm(psill = 250, model = "Sph", range = 3.5, nugget = 0)
v.fit <- fit.variogram(v, v.model, fit.method = 2)      # Not converging
print(v.model)
plot(v.model, cutoff = 13)

