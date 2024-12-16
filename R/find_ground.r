require(lidR)

input.las1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0001_20231127_1.las"
input.las2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0002_20231127_1.las"
input.las3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/HEF_0003_20231127_1.las"


las_location <- input.las2
las <- readLAS(las_location)

mycsf <- csf(FALSE, class_threshold = 0.1, cloth_resolution = 0.25) # intelimon settings: TRUE, class_threshold = 0.5, cloth_resolution = 0.25, time_step = 0.65
new.las <- classify_ground(las, mycsf)
cropped.las <- clip_circle(new.las, 0, 0, 10)
#plot(cropped.las, color = "Classification")

norm.las <- normalize_height(cropped.las, tin())
plot(norm.las, color = "Classification")

# plot only the ground
# change == to != to plot everything but ground
#only.ground.las <- filter_poi(cropped.las, Classification == 2)
#plot(only.ground.las, color = 'Z', legend = TRUE)


