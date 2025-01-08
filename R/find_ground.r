## This program prepares a lidar scan of a forest plot for analysis. It:
## - models where the ground is
## - classifies points that are apparently part of the ground
## - normalizes the heights of the scan (leveling the ground points and adjusting points above or below the ground accordingly)
## - crops the scan to the radius of the forest plot
## - finds, labels, and removes tree stems
## - crops the scan to a normalized height range between 0 and 3 m
## 
## To save the results to file, uncomment the section at the end of the script.

require(lidR)
require(TreeLS)

## USER: put the locations of your input las files here
input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0001_20231127_1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0002_20231127_1.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0003_20231127_1.las"

## USER: put the paths to your output locations here
output.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot1.las"
output.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot2.las"
output.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot3.las"

## put inputs and outputs into vectors to loop through
inputs.list <- c(input.las1, input.las2, input.las3)
outputs.list <- c(output.las1, output.las2, output.las3)

## loop through the lists above
for (i in 1:3) {
  
  ## read in the input las files
  las_location <- inputs.list[[i]]
  las <- readLAS(las_location)
  
  ## model the ground
  mycsf <- csf(FALSE, class_threshold = 0.1, cloth_resolution = 0.15) # intelimon settings: TRUE, class_threshold = 0.5, cloth_resolution = 0.25, time_step = 0.65

  ## use the ground model to classify ground points
  new.las <- classify_ground(las, mycsf)
  
  ## crop the las scan to the radius of the forest plot
  cropped.las <- clip_circle(new.las, 0, 0, 10)
  #plot(cropped.las, color = "Classification")
  
  ## use the ground points to normalize the scan
  norm.las <- normalize_height(cropped.las, tin())
  #plot(norm.las, color = "Classification")
  
  ## fastPointMetrics quickly gathers a number of attributes about a point cloud
  ## we are interested in verticality and eigentropy to find tree stems
  ## this is modeled after part of the intelimon code
  all_metrics <- fastPointMetrics.available()     # examine all of the available metrics
  my_metrics <- all_metrics[c(16, 11)]            # choose Verticality and Eigentropy
  stems.las <- fastPointMetrics(norm.las, ptm.knn(25), my_metrics)
  
  ## find areas with trees
  filtered.las <- filter_poi(stems.las, Verticality > 80, Verticality < 95)
  filtered.las <- filter_poi(filtered.las, Eigentropy < 0.03)
  map.las <- treeMap(filtered.las, map.hough(min_h = 2, max_h = 4, min_votes = 1), merge = 0)
  
  ## clean up memory
  rm(stems.las)
  gc()
  
  ## label tree and stem points
  ## the else clause is for when there are no trees in the las
  if (object.size(map.las) > 20000L) {
    
    norm.las <- treePoints(norm.las, map.las, trp.crop())
    norm.las <- stemPoints(norm.las, stm.hough(
      h_step = 0.2,
      h_base = c(0.05, 2.05),
      min_votes = 1
    ))
    
  } else {
    
    norm.las <- add_lasattribute(norm.las, x, "Stem", "tree stem point")
  
  }
  
  ## clean up
  rm(map.las)
  gc()
  
  ## set classification to 20 for points that are part of tree stems
  norm.las@data[Stem == T, Classification := 20]
  
  ## remove points classified as stems
  nonstem.las <- filter_poi(norm.las, Classification != 20)
  
  ## crop points that are outside of 0-3 m height range
  nonstem.las <- filter_poi(nonstem.las, Z < 3)
  nonstem.las <- filter_poi(nonstem.las, Z >= 0)
  #plot(nonstem.las, legend = TRUE)
  
  ## uncomment to save to file
  #writeLAS(nonstem.las, outputs.list[[i]])
  
}

