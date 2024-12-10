require(lidR)

input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0001_20231127_1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0002_20231127_1.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0003_20231127_1.las"

input_lasses <- c(input.las1, input.las2, input.las3)


  las_location <- input.las1
  las <- readLAS(las_location)
  
  mycsf <- csf(FALSE, class_threshold = 0.05, rigidness = 2, cloth_resolution = 0.5)
  new.las <- classify_ground(las, mycsf)
  print(new.las$Classification)
  plot(new.las, color = "Classification")




