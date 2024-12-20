# This program will look at each biomass type across the combined macroplots
# It will find *weighted* mean biomasses and standard deviations of biomasses for each biomass type.
# strata that come from the same clip plot will be summed to find total biomass represented by each clip plot
# this program has been adjusted for clip plot center

library(dplyr)

# USER: write your input csv location here
input_data <- read.csv('C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024 multiplot.csv')
input_weights <- read.csv('C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/weights_for_combined_macroplots.csv')
# USER: write you output location here
output_location <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/weighted_mean_and_std_biomasses_on_combined_macroplots.csv'

# combine the strata into one biomass value per unique combination of clip plot and biomass type
low_df <- subset(input_data, Stratum == '0-30', select = c("Macroplot", "Clip.Plot", "X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL"))
high_df <- subset(input_data, Stratum == '30-100', select = c("Macroplot", "Clip.Plot", "X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL"))
by_clip_plot_df <- inner_join(low_df, high_df, by = c("Macroplot", "Clip.Plot"))

by_clip_plot_df$X1000hr <- by_clip_plot_df$X1000hr.x + by_clip_plot_df$X1000hr.y
by_clip_plot_df$X100hr <- by_clip_plot_df$X100hr.x + by_clip_plot_df$X100hr.y
by_clip_plot_df$X10hr <- by_clip_plot_df$X10hr.x + by_clip_plot_df$X10hr.y
by_clip_plot_df$X1hr <- by_clip_plot_df$X1hr.x + by_clip_plot_df$X1hr.y
by_clip_plot_df$CL <- by_clip_plot_df$CL.x + by_clip_plot_df$CL.y
by_clip_plot_df$ETE <- by_clip_plot_df$ETE.x + by_clip_plot_df$ETE.y
by_clip_plot_df$FL <- by_clip_plot_df$FL.x + by_clip_plot_df$FL.y
by_clip_plot_df$PC <- by_clip_plot_df$PC.x + by_clip_plot_df$PC.y
by_clip_plot_df$PN <- by_clip_plot_df$PN.x + by_clip_plot_df$PN.y
by_clip_plot_df$Wlit.BL <- by_clip_plot_df$Wlit.BL.x + by_clip_plot_df$Wlit.BL.y
by_clip_plot_df$Wlive.BL <- by_clip_plot_df$Wlive.BL.x + by_clip_plot_df$Wlive.BL.y
by_clip_plot_df$total_biomass <- by_clip_plot_df$X1000hr.x + by_clip_plot_df$X1000hr.y + by_clip_plot_df$X100hr.x + by_clip_plot_df$X100hr.y + by_clip_plot_df$X10hr.x + by_clip_plot_df$X10hr.y + by_clip_plot_df$X1hr.x + by_clip_plot_df$X1hr.y + by_clip_plot_df$CL.x + by_clip_plot_df$CL.y + by_clip_plot_df$ETE.x + by_clip_plot_df$ETE.y + by_clip_plot_df$FL.x + by_clip_plot_df$FL.y + by_clip_plot_df$PC.x + by_clip_plot_df$PC.y + by_clip_plot_df$PN.x + by_clip_plot_df$PN.y + by_clip_plot_df$Wlit.BL.x + by_clip_plot_df$Wlit.BL.y + by_clip_plot_df$Wlive.BL.x + by_clip_plot_df$Wlive.BL.y
by_clip_plot_df$fine_dead_fuels <- by_clip_plot_df$CL.x + by_clip_plot_df$CL.y + by_clip_plot_df$ETE.x + by_clip_plot_df$ETE.y + by_clip_plot_df$FL.x + by_clip_plot_df$FL.y + by_clip_plot_df$PN.x + by_clip_plot_df$PN.y + by_clip_plot_df$Wlit.BL.x + by_clip_plot_df$Wlit.BL.y
print(by_clip_plot_df)

# purge redundant columns
by_clip_plot_df <- by_clip_plot_df[, c("Macroplot", "Clip.Plot", "X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL", "total_biomass", "fine_dead_fuels")]

print(input_weights)
print(by_clip_plot_df)

# join weights table with biomasses table
weighted_masses_df <- inner_join(input_weights, by_clip_plot_df, by = c("Macroplot", "Clip.Plot"))

weighted_masses_df$X1000hr <- weighted_masses_df$X1000hr.x * weighted_masses_df$X1000hr.y
weighted_masses_df$X100hr <- weighted_masses_df$X100hr.x * weighted_masses_df$X100hr.y
weighted_masses_df$X10hr <- weighted_masses_df$X10hr.x * weighted_masses_df$X10hr.y
weighted_masses_df$X1hr <- weighted_masses_df$X1hr.x * weighted_masses_df$X1hr.y
weighted_masses_df$CL <- weighted_masses_df$CL.x * weighted_masses_df$CL.y
weighted_masses_df$ETE <- weighted_masses_df$ETE.x * weighted_masses_df$ETE.y
weighted_masses_df$FL <- weighted_masses_df$FL.x * weighted_masses_df$FL.y
weighted_masses_df$PC <- weighted_masses_df$PC.x * weighted_masses_df$PC.y
weighted_masses_df$PN <- weighted_masses_df$PN.x * weighted_masses_df$PN.y
weighted_masses_df$Wlit.BL <- weighted_masses_df$Wlit.BL.x * weighted_masses_df$Wlit.BL.y
weighted_masses_df$Wlive.BL <- weighted_masses_df$Wlive.BL.x * weighted_masses_df$Wlive.BL.y
weighted_masses_df$total_biomass <- weighted_masses_df$total_biomass.x * weighted_masses_df$total_biomass.y
weighted_masses_df$fine_dead_fuels <- weighted_masses_df$fine_dead_fuels.x * weighted_masses_df$fine_dead_fuels.y

# filter out redundant columns
weighted_masses_df <- weighted_masses_df[, c("Macroplot", "Clip.Plot", "X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL", "total_biomass", "fine_dead_fuels")]

print(weighted_masses_df)


# initialize output columns
biomass_type <- c("X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL", "total_biomass", "fine_dead_fuels")
weighted_mean_biomass <- c()
weighted_standard_deviation <- c()

# loop through the biomass types
# populate output columns
for (i in 1:13) {              # there are 11 biomass types, plus 1 row for total_biomass and 1 for fine_dead_fuels
  
  weighted_biomass_values <- weighted_masses_df[biomass_type[[i]]]
  
  weights <- input_weights[biomass_type[[i]]]
  
  if (sum(weights) == 0) {
    this_mean <- 0          # prevent divide by zero
  } else {
    this_mean <- sum(weighted_biomass_values) / sum(weights)
  }
  
  ## append the mean to the weighted means
  weighted_mean_biomass <- c(weighted_mean_biomass, this_mean)
  
  biomass_values <- by_clip_plot_df[biomass_type[[i]]]
  
  weighted_squared_differences_from_mean <- weights * (biomass_values - this_mean)^2
  
  if (sum(weights) == 0) {
    variance <- 0
  } else {
    variance <- (sum(weighted_squared_differences_from_mean)) / sum(weights)    
  }
  
  standard_dev <- sqrt(variance)
  
  ## append the standard deviation to the list of standard deviations
  weighted_standard_deviation <- c(weighted_standard_deviation, standard_dev)
  
}

# build output data frame
output <- data.frame(biomass_type, weighted_mean_biomass, weighted_standard_deviation)

print(output)

# save the output to csv
#write.csv(output, output_location, row.names = FALSE)


# uncomment to make csvs of combined masses and weighted masses.
# CAUTION: the weighted masses don't represent the actual mass of the clip plot, but how it is integrated into the weighted model of the macroplot.
#write.csv(by_clip_plot_df, 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/biomasses_with_strata_combined.csv', row.names = FALSE)
#write.csv(weighted_masses_df, 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/weighted_masses.csv', row.names = FALSE)




