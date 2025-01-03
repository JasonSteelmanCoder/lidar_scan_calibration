
## grab the data
structural_variables_path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/standardized_structural_variables_of_clip_plots.csv"
structural_variables <- read.csv(structural_variables_path)
biomasses_path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/biomasses_with_strata_combined.csv"
biomasses <- read.csv(biomasses_path)

## clean up some data to allow joining the data
structural_variables$clip.plot.name <- toupper(structural_variables$clip.plot.name)

## join the data into one table
combined_data <- merge(structural_variables, biomasses, by.x = c("macroplot", "clip.plot.name"), by.y = c("Macroplot", "Clip.Plot"))

## loop through the different kinds of biomass, comparing biomass to density in stratum 2
for (i in 13:25) {
  print(names(combined_data)[i])
  print(cor(combined_data$standardized_stratum2_point_density, combined_data[, i]))
  #print(combined_data[, i])
  print("")
  plot(combined_data$standardized_stratum2_point_density, combined_data[, i], main = paste(names(combined_data)[i], "standardized stratum2 point density"))
}

## loop through the different kinds of biomass, comparing biomass to percent points in stratum 2
for (i in 13:25) {
  print(names(combined_data)[i])
  print(cor(combined_data$standardized_pct_points_stratum2, combined_data[, i]))
  #print(combined_data[, i])
  print("")
  plot(combined_data$standardized_pct_points_stratum2, combined_data[, i], main = paste(names(combined_data)[i], "standardized pct points stratum2"))
}

## loop through the different kinds of biomass, comparing biomass to mean height
for (i in 13:25) {
  print(names(combined_data)[i])
  print(cor(combined_data$standardized_mean_height, combined_data[, i]))
  #print(combined_data[, i])
  print("")
  plot(combined_data$standardized_mean_height, combined_data[, i], main = paste(names(combined_data)[i], "standardized mean height"))
}

