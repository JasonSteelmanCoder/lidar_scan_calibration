## this script checks the effectiveness of estimating macroplot biomass with the krigeing method.
## it uses leave-one-out validation.
## one clip plot is left out of the data and then krigeing is used to estimate the biomass of the missing clip plot.
## these results are compared to the known value of the excluded clip plot
## you can compare these losses with the losses experienced when estimating by average (see loo_weight_validation.py)

library(gstat)
library(sp)
library(automap)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)
library(ggplot2)

##USER: put the paths to your input data here
input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv'
#previous.estimations.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/macroplot_biomass_estimations.csv'
#output.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/kriged_biomass_estimations.csv'

## grab the data
file_data <- read.csv(input.csv)

## extract x and y coordinates from coordinates column of the data
file_data$X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

## boil the data down to x and y coordinates, along with one total.biomass value for each clip plot
file_data <- file_data %>%
  group_by(Macroplot, Clip.Plot, Coordinates, X, Y) %>%
  summarize(
    'total_biomass' = sum(X1000hr) + sum(X100hr) + sum(X10hr) + sum(X1hr) + sum(CL) + sum(ETE) + sum(FL) + sum(PC) + sum(PN) + sum(Wlit.BL) + sum(Wlive.BL),
    .groups = 'keep'
  )

## chunk the data out into three macroplots
macroplot1 <- subset(file_data, Macroplot == 1)
macroplot2 <- subset(file_data, Macroplot == 2)
macroplot3 <- subset(file_data, Macroplot == 3)

## grab the x and y coordinates of clip plots
clip.plots.x <- macroplot1$X
clip.plots.y <- macroplot1$Y

## set variable
biomass_type <- 'total_biomass'

## make spatial data frames for the three macroplots 
## each data frame has columns for x, y, and total biomass
spatial_df1 <- SpatialPointsDataFrame(
  coords = macroplot1[, c("X", "Y")],
  data = subset(macroplot1, select = biomass_type)
)

spatial_df2 <- SpatialPointsDataFrame(
  coords = macroplot2[, c("X", "Y")],
  data = subset(macroplot2, select = biomass_type)
)

spatial_df3 <- SpatialPointsDataFrame(
  coords = macroplot3[, c("X", "Y")],
  data = subset(macroplot3, select = biomass_type)
)

## make lists of variables to loop through
plot_layers = c(spatial_df1, spatial_df2, spatial_df3)
plot_layer_names = c("macroplot1_", "macroplot2_", "macroplot3_")

## set up a grid
## and crop the grid into a (pixelated) circle the size of the macroplot
origin <- c(x0 = 0, y0 = 0)
radius <- 10
grid_points <- expand.grid(
  x = seq(-radius, radius, by = 0.5),
  y = seq(-radius, radius, by = 0.5)
)
grid_points <- grid_points[
  (grid_points$x - origin[["x0"]])^2 + (grid_points$y - origin[["y0"]])^2 <= radius^2,
]
coordinates(grid_points) <- ~x + y

## define a function that will round a number to the nearest half
round_to_half <- function(num) {
  return (round(num * 2, 0) / 2)
}

## prepare an empty vector to be filled with root mean squared errors
root_mean_squared_errors <- c()

# loop through the macroplots
for (i in 1:3) {
  
  ## set the current macroplot and spatial data frame
  if (i == 1) {
    current.macroplot = macroplot1
  } else if (i == 2) {
    current.macroplot = macroplot2
  } else {
    current.macroplot = macroplot3
  }
  current.spdf <- plot_layers[[i]]
  
  ## make a formula for the variogram model to use
  data_name <- names(current.spdf)[1]
  formula <- as.formula(paste(data_name, '~ 1'))
  
  ## calculate a variogram
  variogram = autofitVariogram(formula = formula, input_data = current.spdf, verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
  
  ## make an empty vector to be populated with losses
  losses <- c()
  
  ## loop through the clip plots to be excluded
  for (k in 1:24) {

    ## set the coordinates to be excluded  
    excluded.x <- clip.plots.x[k]
    excluded.y <- clip.plots.y[k]

    ## the clique is the data excluding one clip plot
    clique <- subset(current.spdf, !(current.spdf$X == excluded.x & current.spdf$Y == excluded.y))    
    
    ## perform krigeing on the clique
    kriged <- krige(formula, clique, newdata=grid_points, model = variogram$var_model)
    
    ## make the krigeing results into a data frame
    kriging_df <- as.data.frame(kriged)
    #print(subset(kriging_df, x == round_to_half(excluded.x) & y == round_to_half(excluded.y), select = c(x, y)))

    ## grab the actual value of the excluded clip plot
    known.value <- subset(current.macroplot, (X == excluded.x & Y == excluded.y), select = c(total_biomass))[[1]]

    ## grab the value of the excluded clip plot, predicted using krigeing
    predicted.value <-  subset(kriging_df, x == round_to_half(excluded.x) & y == round_to_half(excluded.y), select = c(var1.pred))[[1]]

    ## append to losses the squared difference between the known and predicted values
    losses <- c(losses, (predicted.value - known.value)^2)
    
    ## uncomment to make an image of the plot
    #this_plot <- ggplot(kriging_df, aes(x = x, y = y, fill = var1.pred)) + 
      #geom_tile() + 
      #coord_fixed() + 
      #scale_fill_viridis_c() +
      #labs(title = paste("Macroplot", i, '\n', data_name, sep = ' '), fill = "Prediction")
    #print(this_plot)
    #print(c(paste("Macroplot", i, data_name, sep = ' '), sum(kriged$var1.pred)))
  
  }
  
  ## append the square root of the mean of the losses to the root_mean_squared_errors vector
  root_mean_squared_errors <- c(root_mean_squared_errors, sqrt(mean(losses)))
}

## print the results
print(root_mean_squared_errors)