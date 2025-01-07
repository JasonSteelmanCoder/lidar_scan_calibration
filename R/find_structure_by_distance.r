## Given a lidar scan, this program finds: 
##    mean height, 
##    % of points in stratum 2 (50-100 cm high),
##    point density in stratum 2 
## point density in stratum 2 will be the number of points divided by the volume of the stratum
## the volume of the stratum is its height (0.5m) times its area (voxel_width^2. In this case, 1m^2)

require(lidR)
require(dplyr)
require(stringr)

## USER: make sure that this width matches the width of the voxels you are using. 
## that width is set in segment_scan_pixels.r
voxel_width <- 1.0

## USER: put the path to your output file here
output.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/structural_variance_with_distance.csv"

## USER: put the paths to the folders of .las files here
source.folder1 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las1/"
source.folder2 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las2/"
source.folder3 <- "C:/Users/js81535/Desktop/lidar_scan_calibration/segmented_las3/"

## USER: the .json file contains the distances to each segmented voxel. Put the path to it here.
distance.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/pixel_dimensions.json"

## read in the distances
distances <- fromJSON(file = distance.path)

## initialize an empty data frame to be populated later
output <- data.frame(
  macroplot = numeric(),
  voxel_number = numeric(),
  distance = numeric(),
  mean_height = numeric(),
  pct_points_stratum2 = numeric(),
  point_density_stratum2 = numeric()
)

## set a number to keep track of macroplot
i <- 1

## loop through the three input folders
for (folder in c(source.folder1, source.folder2, source.folder3)) {

  ## grab all of the files in the current folder
  files <- list.files(path = folder, full.names = TRUE)
  
  ## loop through all of the files in the current folder
  for (file in files) {
    
    ## get the number of the segmented voxel
    voxel.number <- str_extract(file, "_(\\d+)\\.", group = 1)
    
    ## find the distance of the segmented voxel from the center of the macroplot
    ## distance is measured from the center of the segmented voxel
    this.coords <- distances[[voxel.number]][["centerpoint"]]
    this.x <- this.coords[[1]]
    this.y <- this.coords[[2]]
    this.distance <- sqrt(this.x^2 + this.y^2)
    
    ## read in the .las file
    input.las <- readLAS(file)
    
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
    
    ## uncomment to print the results
    # print("")
    # print(paste("voxel number:", voxel.number))
    # print(paste("distance from plot center:", this.distance, "m"))
    # print(paste("mean height:", mean_height, "m"))
    # print(paste("percent of points in stratum2:", pct_points_stratum2, "%"))
    # print(paste("point density in stratum2:", stratum2_point_density, "points/m^3"))
    
    ## assemble a new row with the calculated values
    new_row <- data.frame(
      macroplot = i,
      voxel_number = voxel.number,
      distance = this.distance,
      mean_height = mean_height,
      pct_points_stratum2 = pct_points_stratum2,
      point_density_stratum2 = stratum2_point_density
    )

    ## append the new row to the output data frame
    output <- rbind(output, new_row)
    
  }
    
  ## increment the macroplot index
  i <- i + 1

}

## uncomment to print the output table
print(output)

## uncomment to save the results to file
#write.csv(output, output.path, row.names = FALSE)


