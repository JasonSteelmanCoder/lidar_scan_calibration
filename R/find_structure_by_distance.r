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

## read in the file
input.las <- readLAS(input.path)

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
print(paste("mean height:", mean_height))
print(paste("percent of points in stratum2:", pct_points_stratum2))
print(paste("point density in stratum2:", stratum2_point_density, "points/m^3"))



