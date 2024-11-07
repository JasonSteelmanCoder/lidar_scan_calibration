# For each stratum (0-30, 30-100),
# For each biomass type:
# This program will look at 3 plots.
# On each plot, it will look at three rings at 2, 2.5, and 6 meters.
# It will find mean biomasses and standard deviations of biomasses for each ring.

# read the csv
input_data <- read.csv('C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv') 

# make lists to populate the indexing columns
stratum_col <- c(rep('0-30', 99), rep('30-100', 99))
biomass_type_col <- c(rep('1000hr', 9), rep('100hr', 9), rep('10hr', 9), rep('1hr', 9), rep('CL', 9), rep('ETE', 9), rep('FL', 9), rep('PC', 9), rep('PN', 9), rep('Wlit-BL', 9), rep('Wlive-BL', 9), rep('1000hr', 9), rep('100hr', 9), rep('10hr', 9), rep('1hr', 9), rep('CL', 9), rep('ETE', 9), rep('FL', 9), rep('PC', 9), rep('PN', 9), rep('Wlit-BL', 9), rep('Wlive-BL', 9))
plt_col <- c()
# one set of plots for every combination of stratum and biomass
for (i in 1:22) {
  # three rings for each of three plots in a set
  for (j in 1:3) {
    plt_col <- c(plt_col, rep(j, 3))
  }
}
distance_col <- c()
for (i in 1:66) {
  distance_col <- c(distance_col, 2, 2.5, 6)
}

# build data frame with one row for each unique combination of stratum, biomass, plot, and distance
output <- data.frame(stratum_col, biomass_type_col, plt_col, distance_col)
# name the columns for readability
stratum_id <- 1
biomass_id <- 2
plot_id <- 3
distance_id <- 4

for (i in 1:198) {
  print(output[i, stratum_id])
}
