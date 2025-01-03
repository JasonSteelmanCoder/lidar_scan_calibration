require(lidR)
require(stringr)
require(ggplot2)

## USER: put the folders containing clip plot lidar files here
m1_clip_plots_folder <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las1"
m2_clip_plots_folder <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las2"
m3_clip_plots_folder <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las3"

## USER: put the path to the local measurements of spread csv here
spreads.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/local_measurements_of_spread_for_structural_variables.csv"
spreads <- read.csv(spreads.path)

## USER: put the pathe to your output folder here
output.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/standardized_structural_variables_of_clip_plots.csv"

## set up variables
voxel_width <- 0.5

## initialize empty output data frame to be populated later
output <- data.frame(
  macroplot = numeric(),
  clip.plot.name = character(),
  distance = numeric(),
  raw_mean_height = numeric(),
  raw_pct_points_stratum2 = numeric(),
  raw_stratum2_point_density = numeric(),
  flattened_mean_height = numeric(),
  flattened_pct_points_stratum2 = numeric(),
  flattened_stratum2_point_density = numeric(),
  standardized_mean_height = numeric(),
  standardized_pct_points_stratum2 = numeric(),
  standardized_stratum2_point_density = numeric()
)

## set up trend-line formulas. 
## these come from the calculations done in correlate_structure_and_distance.py
point_density_formula <- function(x) {
  return (66519.34091135851 * x^(-2.3800269567879138))
}

pct_s2_formula <- function(x) {
  return(-0.1786 * x^2 + 3.051 * x + 3.656)
}

mean_height_formula <- function(x) {
  return(-0.002356 * x^2 + 0.04076 * x + 0.07822)
}

## find trend lines for local measures of spread
std_pct_points_line <- lm(as.formula(paste('local_standard_deviation_for_pct_points ~ unique_distance')), data = spreads)
#print(std_pct_points_line$coefficients)
iqr_mean_height <- lm(as.formula('local_iqr_for_mean_height ~ unique_distance'), data = spreads)
#print(iqr_mean_height$coefficients)
std_density_curve <- nls(local_standard_deviation_for_density ~ a * unique_distance^b, start = list(a = 66519, b = -2), data = spreads)
#print(coef(std_density_curve))
std_density_function <- function(x) {
  return (coef(std_density_curve)[[1]] * x^coef(std_density_curve)[[2]])
}

## uncomment to view measures of spread at different distances
#print(spreads)
#ggplot(data = spreads, aes(unique_distance, local_iqr_for_mean_height)) + 
#  geom_point() +
#  geom_abline(slope = iqr_mean_height$coefficients[[2]], intercept = iqr_mean_height$coefficients[[1]])
#ggplot(data = spreads, aes(unique_distance, local_standard_deviation_for_density)) +
#  geom_point() + 
#  stat_function(fun = std_density_function)
#ggplot(data = spreads, aes(unique_distance, local_standard_deviation_for_pct_points)) + 
#  geom_point() +
#  geom_abline(slope = std_pct_points_line$coefficients[[2]], intercept = std_pct_points_line$coefficients[[1]])

## set a variable to track which clip plot we are on
i <- 1

## loop through the three input folders
for (folder in c(m1_clip_plots_folder, m2_clip_plots_folder, m3_clip_plots_folder)) {
  
  ## grab all of the files in the current folder
  files <- list.files(path = folder, full.names = TRUE)  
  
  ## loop through all of the files in the current folder
  for (file in files) {
    
    ## get the macroplot number
    macroplot <- i
    
    ## get the clip plot's name
    clip.plot.name <- str_extract(file, "\\/(\\S{2,5})\\.las", group = 1)
    
    ## find the clip plot's distance from macroplot center
    ## note: we add 0.25 to the nominal distance, since the nominal distance is from macroplot center
    ## to the *edge* of the clip plot, but we want to know the distance to the *center* of the clip plot
    this.distance <- as.numeric(str_extract(clip.plot.name, "(\\d(\\.\\d)?)", group = 1)) + 0.25
    
    ## read in the .las file
    input.las <- readLAS(file)

    
    ## find raw structural variables
        
    ## calculate mean height
    mean_height <- mean(input.las$Z)
    
    ## count points in the whole voxel
    point_count <- length(input.las$Z)
    
    ## find the number of points in stratum2
    filtered_by_height <- filter(input.las@data, Z >= 0.5, Z < 1)
    stratum2_count <- length(filtered_by_height$Z)
    
    ## calculate the percentage of total points that land in stratum2
    pct_points_stratum2 <- stratum2_count / point_count * 100
    
    ## calculate the point density in stratum2 (see the introductory doc strings for more details)
    stratum2_point_density <- stratum2_count / (voxel_width^2 * 0.5)
    
    
    ## find flattened structural variables

    flattened_mean_height <- mean_height - mean_height_formula(this.distance)
    flattened_pct_points_stratum2 <-  pct_points_stratum2 - pct_s2_formula(this.distance)
    flattened_stratum2_point_density <- stratum2_point_density - point_density_formula(this.distance)
    
    
    ## find local measures of spread
    local_iqr_mean_height <- iqr_mean_height$coefficients[[1]] + iqr_mean_height$coefficients[[2]] * this.distance
    local_std_pct_points <- std_pct_points_line$coefficients[[1]] + std_pct_points_line$coefficients[[2]] * this.distance 
    local_std_density <- coef(std_density_curve)[[1]] * this.distance^coef(std_density_curve)[[2]]
    
    
    ## find standardized structural variables
    standardized_mean_height <- flattened_mean_height / local_iqr_mean_height
    standardized_pct_points_stratum2 <- flattened_pct_points_stratum2 / local_std_pct_points
    standardized_stratum2_point_density <- flattened_stratum2_point_density / local_std_density
    
    
    ## create a new row with the values from the clip plot
    new_row <- data.frame(
      macroplot = macroplot,
      clip.plot.name = clip.plot.name,
      distance = this.distance,
      raw_mean_height = mean_height,
      raw_pct_points_stratum2 = pct_points_stratum2,
      raw_stratum2_point_density = stratum2_point_density,
      flattened_mean_height = flattened_mean_height,
      flattened_pct_points_stratum2 = flattened_pct_points_stratum2,
      flattened_stratum2_point_density = flattened_stratum2_point_density,
      standardized_mean_height = standardized_mean_height,
      standardized_pct_points_stratum2 = standardized_pct_points_stratum2,
      standardized_stratum2_point_density = standardized_stratum2_point_density
    )
    ## add the new row to the output data frame
    output <- rbind(output, new_row)
    
  }
  
  # increment the macroplot number
  i <- i + 1  
  
}

## uncomment to see the output
print(output)

## uncomment to save the output to file
#write.csv(output, output.path, row.names = FALSE)

## uncomment to see the standardization process visualized
#ggplot(data = output, aes(distance, mean_height)) + 
#  geom_point() + 
#  geom_hline(yintercept = 0)
#ggplot(data = output, aes(distance, flattened_mean_height)) + 
#  geom_point() + 
#  geom_hline(yintercept = 0)
#ggplot(data = output, aes(distance, standardized_mean_height)) + 
#  geom_point() + 
#  geom_hline(yintercept = 0)

#ggplot(data = output, aes(distance, pct_points_stratum2)) + 
#  geom_point() +
#  geom_hline(yintercept = 0)
#ggplot(data = output, aes(distance, flattened_pct_points_stratum2)) + 
#  geom_point() +
#  geom_hline(yintercept = 0)
#ggplot(data = output, aes(distance, standardized_pct_points_stratum2)) + 
#  geom_point() +
#  geom_hline(yintercept = 0)

#ggplot(data = output, aes(distance, stratum2_point_density)) +
#  geom_point() + 
#  geom_hline(yintercept = 0)
#ggplot(data = output, aes(distance, flattened_stratum2_point_density)) +
#  geom_point() + 
#  geom_hline(yintercept = 0)
#ggplot(data = output, aes(distance, standardized_stratum2_point_density)) +
#  geom_point() + 
#  geom_hline(yintercept = 0)

