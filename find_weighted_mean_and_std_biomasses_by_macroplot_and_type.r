# This program will look at each biomass type in 3 macroplots.
# It will find *weighted* mean biomasses and standard deviations of biomasses for each combination of macroplot and type.
# strata that come from the same clip plot will be summed to find total biomass represented by each clip plot

library(dplyr)

# USER: write your input csv location here
input_data <- read.csv('C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv')
input_weights <- read.csv('C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_weights.csv')
# USER: write you output location here
output_location <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/weighted_mean_and_std_biomasses_by_macroplot_and_type.csv'

# combine the strata into one biomass per unique combination of clip plot and biomass type
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


# purge redundant columns
by_clip_plot_df <- by_clip_plot_df[, c("Macroplot", "Clip.Plot", "X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL")]

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

# filter out redundant columns
weighted_masses_df <- weighted_masses_df[, c("Macroplot", "Clip.Plot", "X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL")]

print(weighted_masses_df)


# initialize output columns
macroplot <- c(rep(1, 11), rep(2, 11), rep(3, 11))
biomass_type <- c(rep(c("X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL"), 3))
weighted_mean_biomass <- c()
weighted_standard_deviation <- c()
# autocorrelation ranges are hard coded.
autocorrelation_range <- c(rep(c(100, 2.1, 2.8, 5.1, 0.92, 3.2, 2.2, 7.1, 4.8, 0.64, 68), 3))

# populate output columns
for (i in 1:33) {              # there are 33 unique combinations of macroplot and biomass type
  
  weighted_biomass_values <- subset(weighted_masses_df, Macroplot == macroplot[[i]], select = biomass_type[[i]])
  weights <- subset(input_weights, Macroplot == macroplot[[i]], select = biomass_type[[i]])
  this_mean <- sum(weighted_biomass_values) / sum(weights)         
  weighted_mean_biomass <- c(weighted_mean_biomass, this_mean)
  
  biomass_values <- subset(by_clip_plot_df, Macroplot == macroplot[[i]], select = biomass_type[[i]])
  weighted_squared_differences_from_mean <- weights * (biomass_values - this_mean)^2
  variance <- (sum(weighted_squared_differences_from_mean)) / sum(weights)    
  standard_dev <- sqrt(variance)
  weighted_standard_deviation <- c(weighted_standard_deviation, standard_dev)
  
}

# build output data frame
output <- data.frame(macroplot, biomass_type, weighted_mean_biomass, weighted_standard_deviation, autocorrelation_range)

print(output)

# save the output to csv
write.csv(output, output_location, row.names = FALSE)

