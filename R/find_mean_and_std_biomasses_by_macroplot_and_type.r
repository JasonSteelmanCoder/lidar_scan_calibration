# This program will look at each biomass type in 3 macroplots.
# It will find mean biomasses and standard deviations of biomasses for each combination of macroplot and type.
# strata that come from the same clip plot will be summed to find total biomass represented by each clip plot
# NOTE: this script drops clip plots that are 2.5m from the center, since they are spatially autocorrelated with the 2m clip plots

library(dplyr)

# USER: write your input csv location here
input_data <- read.csv('C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv') 
# USER: write you output location here
output_location <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/mean_and_std_biomasses_by_macroplot_and_type.csv'

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
by_clip_plot_df$total_biomass <- by_clip_plot_df$X1000hr.x + by_clip_plot_df$X1000hr.y + by_clip_plot_df$X100hr.x + by_clip_plot_df$X100hr.y + by_clip_plot_df$X10hr.x + by_clip_plot_df$X10hr.y + by_clip_plot_df$X1hr.x + by_clip_plot_df$X1hr.y + by_clip_plot_df$CL.x + by_clip_plot_df$CL.y + by_clip_plot_df$ETE.x + by_clip_plot_df$ETE.y + by_clip_plot_df$FL.x + by_clip_plot_df$FL.y + by_clip_plot_df$PC.x + by_clip_plot_df$PC.y + by_clip_plot_df$PN.x + by_clip_plot_df$PN.y + by_clip_plot_df$Wlit.BL.x + by_clip_plot_df$Wlit.BL.y + by_clip_plot_df$Wlive.BL.x + by_clip_plot_df$Wlive.BL.y
by_clip_plot_df$fine_dead_fuels <- by_clip_plot_df$CL.x + by_clip_plot_df$CL.y + by_clip_plot_df$ETE.x + by_clip_plot_df$ETE.y + by_clip_plot_df$FL.x + by_clip_plot_df$FL.y + by_clip_plot_df$PN.x + by_clip_plot_df$PN.y + by_clip_plot_df$Wlit.BL.x + by_clip_plot_df$Wlit.BL.y

# purge redundant columns
by_clip_plot_df <- by_clip_plot_df[, c("Macroplot", "Clip.Plot", "X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL", "total_biomass", "fine_dead_fuels")]

# initialize output columns
macroplot <- c(rep(1, 13), rep(2, 13), rep(3, 13))
biomass_type <- c(rep(c("X1000hr", "X100hr", "X10hr", "X1hr", "CL", "ETE", "FL", "PC", "PN", "Wlit.BL", "Wlive.BL", "total_biomass", "fine_dead_fuels"), 3))
mean_biomass <- c()
standard_deviation <- c()

# populate output columns
for (i in 1:39) {              # there are 33 unique combinations of macroplot and biomass type
  biomass_values <- subset(by_clip_plot_df, Macroplot == macroplot[[i]], select = biomass_type[[i]])
  this_mean <- sum(biomass_values) / 24         # there are 24 values per plot for each biomass type
  mean_biomass <- c(mean_biomass, this_mean)
  squared_differences_from_mean <- (biomass_values - this_mean)^2
  variance <- (sum(squared_differences_from_mean)) / 23    # 23 is N - 1
  standard_dev <- sqrt(variance)
  standard_deviation <- c(standard_deviation, standard_dev)
}

# build output data frame
output <- data.frame(macroplot, biomass_type, mean_biomass, standard_deviation)

print(output)

# save the output to csv
#write.csv(output, output_location, row.names = FALSE)

