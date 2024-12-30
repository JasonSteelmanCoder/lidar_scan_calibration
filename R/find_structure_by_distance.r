## Given a lidar scan, this program finds: 
##    mean height, 
##    % of points in stratum 2 (50-100 cm high),
##    point density in stratum 2 
## point density in stratum 2 will be the number of points divided by the volume of the stratum
## the volume of the stratum is its height (0.5m) times its area (voxel_width^2. In this case, 1m^2)

require(lidR)
require(dplyr)

## USER: make sure that this width matches the width of the voxels you are using. 
## that width is set in segment_scan_pixels.r
voxel_width <- 1.0

## USER: put the path to the .las file here
input.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las1/pixel_1.las"

## USER: the .json file contains the distances to each segmented voxel. Put the path to it here
distance.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json"

## read in the distances
distances <- fromJSON(file = "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json")

## read in the .las file
input.las <- readLAS(input.path)

## find the distance of the segmented voxel from the center of the macroplot
## distance is measured from the center of the segmented voxel
this.coords <- distances[[1]][["centerpoint"]]
this.x <- this.coords[[1]]
this.y <- this.coords[[2]]
this.distance <- sqrt(this.x^2 + this.y^2)

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

## print the results
print(paste("distance from plot center:", this.distance, "m"))
print(paste("mean height:", mean_height))
print(paste("percent of points in stratum2:", pct_points_stratum2))
print(paste("point density in stratum2:", stratum2_point_density, "points/m^3"))


##TODO: 
# loop through all scans
# save results to file

