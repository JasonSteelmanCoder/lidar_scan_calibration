require(lidR)
require(stringr)

## grab data
m1_clip_plots_folder <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las1"
m2_clip_plots_folder <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las2"
m3_clip_plots_folder <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot_las3"

## set up variables
voxel_width <- 0.5

## initialize empty output data frame to be populated later
output <- data.frame(
  clip.plot.name = character(),
  distance = numeric(),
  mean_height = numeric(),
  pct_points_stratum2 = numeric(),
  stratum2_point_density = numeric(),
  flattened_mean_height = numeric(),
  flattened_pct_points_stratum2 = numeric(),
  flattened_stratum2_point_density = numeric()
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

## loop through the three input folders
for (folder in c(m1_clip_plots_folder, m2_clip_plots_folder, m3_clip_plots_folder)) {
  
  ## grab all of the files in the current folder
  files <- list.files(path = folder, full.names = TRUE)  
  
  ## loop through all of the files in the current folder
  for (file in files) {
    
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
    
    ## uncomment to print the results
    #print("")
    #print(paste("clip plot:", clip.plot.name))
    #print(paste("distance from plot center:", this.distance, "m"))
    
    #print(paste("mean height:", mean_height, "m"))
    #print(paste("percent of points in stratum2:", pct_points_stratum2, "%"))
    #print(paste("point density in stratum2:", stratum2_point_density, "points/m^3"))

    #print(paste("flattened mean height:", flattened_mean_height))
    #print(paste("flattened percent of points in stratum2:", flattened_pct_points_stratum2))
    #print(paste("flattened point density in stratum2:", flattened_stratum2_point_density))
    
    ## create a new row with the values from the clip plot
    new_row <- data.frame(
      clip.plot.name = clip.plot.name,
      distance = this.distance,
      mean_height = mean_height,
      pct_points_stratum2 = pct_points_stratum2,
      stratum2_point_density = stratum2_point_density,
      flattened_mean_height = flattened_mean_height,
      flattened_pct_points_stratum2 = flattened_pct_points_stratum2,
      flattened_stratum2_point_density = flattened_stratum2_point_density
    )
    ## add the new row to the output data frame
    output <- rbind(output, new_row)
    
  }
    
}

#print(output)
plot(output$distance, output$mean_height)
plot(output$distance, output$flattened_mean_height)

