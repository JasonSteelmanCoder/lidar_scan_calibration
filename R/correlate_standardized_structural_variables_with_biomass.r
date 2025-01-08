## This program makes scatter plots of standardized structural variables versus biomass for a variety
## of biomass types. 
## It also prints out the Pearson's correlation (r) values of those correlations

## USER: put the paths to your input files here
structural_variables_path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/standardized_structural_variables_of_clip_plots.csv"
biomasses_path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/biomasses_with_strata_combined.csv"

## grab the data
structural_variables <- read.csv(structural_variables_path)
biomasses <- read.csv(biomasses_path)

## clean up some variable names to allow joining the data frames
structural_variables$clip.plot.name <- toupper(structural_variables$clip.plot.name)

## join the data into one table
combined_data <- merge(structural_variables, biomasses, by.x = c("macroplot", "clip.plot.name"), by.y = c("Macroplot", "Clip.Plot"))

## loop through the different kinds of biomass, comparing biomass to density in stratum 2
for (i in 13:25) {
  print(names(combined_data)[i])
  print(cor(combined_data$standardized_stratum2_point_density, combined_data[, i]))
  #print(combined_data[, i])
  print("")
  plot(combined_data$standardized_stratum2_point_density, combined_data[, i], main = paste(names(combined_data)[i], "standardized stratum 2 point density"), xlab = "standardized stratum 2 point density score", ylab = paste(names(combined_data)[i], "biomass (g)"))
}

## loop through the different kinds of biomass, comparing biomass to percent points in stratum 2
for (i in 13:25) {
  print(names(combined_data)[i])
  print(cor(combined_data$standardized_pct_points_stratum2, combined_data[, i]))
  #print(combined_data[, i])
  print("")
  plot(combined_data$standardized_pct_points_stratum2, combined_data[, i], main = paste(names(combined_data)[i], "standardized pct points stratum 2"), xlab = "standardized pct points stratum 2 score", ylab = paste(names(combined_data)[i], "biomass (g)"))
}

## loop through the different kinds of biomass, comparing biomass to mean height
for (i in 13:25) {
  print(names(combined_data)[i])
  print(cor(combined_data$standardized_mean_height, combined_data[, i]))
  #print(combined_data[, i])
  print("")
  plot(combined_data$standardized_mean_height, combined_data[, i], main = paste(names(combined_data)[i], "standardized mean height"), xlab = "standardized mean height score", ylab = paste(names(combined_data)[i], "biomass (g)"))
}

