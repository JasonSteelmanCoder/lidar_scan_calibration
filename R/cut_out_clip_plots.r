require(lidR)

input.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/third_modded_HEF_0001_20231127_1.las"
output.path <- "C:/Users/js81535/Desktop/lidar_scan_calibration/clip_plot.las"

las <- readLAS(input.path)

#inner_wall_x <- -0.5747529553555284
inner_wall_y <- 2.175352624360034
#outer_wall_x <- -0.7024758343234235
outer_wall_y <- 2.6587643186622634
right_wall_x <- -0.39690854768836115
#right_wall_y <- 2.4809199109950963
left_wall_x <- -0.8803202419905909
#left_wall_y <- 2.353197032027201

clip.plot.las <- clip_rectangle(las, xleft = left_wall_x, ybottom = inner_wall_y, xright = right_wall_x, ytop = outer_wall_y)

#plot(clip.plot.las)

#writeLAS(clip.plot.las, output.path)