# For each stratum (0-30, 30-100),
# For each biomass type:
# This program will look at 3 plots.
# On each plot, it will look at three rings at 2, 2.5, and 6 meters.
# It will find mean biomasses and standard deviations of biomasses for each ring.

# USER: write your input csv location here
input_data <- read.csv('C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv') 
# USER: write you output location here
output_location <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/mean_and_std_of_rings.csv'

# add a column with the distance from the origin
distances_list <- c()
for (i in 1:nrow(input_data)) {
  distances_list <- c(distances_list, as.double(gsub('[NESW]', '', input_data$Clip.Plot[[i]])))
}
input_data$distance_from_origin <- distances_list 

# make lists to populate the indexing columns
stratum_col <- c(rep('0-30', 99), rep('30-100', 99))
biomass_type_col <- c(rep('X1000hr', 9), rep('X100hr', 9), rep('X10hr', 9), rep('X1hr', 9), rep('CL', 9), rep('ETE', 9), rep('FL', 9), rep('PC', 9), rep('PN', 9), rep('Wlit.BL', 9), rep('Wlive.BL', 9), rep('X1000hr', 9), rep('X100hr', 9), rep('X10hr', 9), rep('X1hr', 9), rep('CL', 9), rep('ETE', 9), rep('FL', 9), rep('PC', 9), rep('PN', 9), rep('Wlit.BL', 9), rep('Wlive.BL', 9))
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
output <- data.frame(stratum = stratum_col, biomass_type = biomass_type_col, macroplot = plt_col, distance_from_origin = distance_col)

means <- c()
stds <- c()
for (i in 1:198) {
  stratum <- output[i, 1]
  biomass <- output[i, 2]
  plot <- output[i, 3]
  distance <- output[i, 4]
  
  relevant_data <- subset(input_data, Stratum == stratum & Macroplot == plot & distance_from_origin == distance, select = biomass)
  mean_biomass <- mean(relevant_data[[1]])
  std_of_biomass <- sd(relevant_data[[1]])
  means <- c(means, mean_biomass)  
  stds <- c(stds, std_of_biomass)
}

output$mean_biomass <- means
output$std_dev_of_biomass <- stds
print(output)

write.csv(output, output_location, row.names = FALSE)







