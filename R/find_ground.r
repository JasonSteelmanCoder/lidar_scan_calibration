require(lidR)

input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0001_20231127_1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0002_20231127_1.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0003_20231127_1.las"

inputs.list <- c(input.las1, input.las2, input.las3)

output.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot1.las"
output.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot2.las"
output.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/normalized_macroplots/normalized_macroplot3.las"

outputs.list <- c(output.las1, output.las2, output.las3)

for (i in 1) {
  las_location <- inputs.list[[i]]
  las <- readLAS(las_location)
  
  mycsf <- csf(FALSE, class_threshold = 0.1, cloth_resolution = 0.15) # intelimon settings: TRUE, class_threshold = 0.5, cloth_resolution = 0.25, time_step = 0.65
  new.las <- classify_ground(las, mycsf)
  cropped.las <- clip_circle(new.las, 0, 0, 10)
  plot(cropped.las, color = "Classification")
  
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
  nonstem.las <- filter_poi(nonstem.las, Z < 3)
  nonstem.las <- filter_poi(nonstem.las, Z >= 0)
  plot(nonstem.las, legend = TRUE)
  
  ## uncomment to plot only the ground
  # change == to != to plot everything but ground
  #only.ground.las <- filter_poi(cropped.las, Classification != 2)
  #plot(only.ground.las, color = 'Z', legend = TRUE)

  ## uncomment to save to file
  #writeLAS(norm.las, outputs.list[[i]])
  
}

