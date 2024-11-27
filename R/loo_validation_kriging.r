library(gstat)
library(sp)
library(automap)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)
library(ggplot2)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv'
#previous.estimations.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/macroplot_biomass_estimations.csv'
#output.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/csv_data/kriged_biomass_estimations.csv'

file_data <- read.csv(input.csv)

file_data$X <- as.numeric(str_extract(file_data$Coordinates, "(-)?\\d+(\\.\\d+)?"))
file_data$Y <- as.numeric(str_extract(file_data$Coordinates, "((-)?\\d+(\\.\\d+)?)\\]", group=1))

file_data <- file_data %>%
  group_by(Macroplot, Clip.Plot, Coordinates, X, Y) %>%
  summarize(
    'total_biomass' = sum(X1000hr) + sum(X100hr) + sum(X10hr) + sum(X1hr) + sum(CL) + sum(ETE) + sum(FL) + sum(PC) + sum(PN) + sum(Wlit.BL) + sum(Wlive.BL),
    .groups = 'keep'
  )

macroplot1 <- subset(file_data, Macroplot == 1)
macroplot2 <- subset(file_data, Macroplot == 2)
macroplot3 <- subset(file_data, Macroplot == 3)

clip.plots.x <- macroplot1$X
clip.plots.y <- macroplot1$Y

biomass_type <- 'total_biomass'


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

plot_layers = c(spatial_df1, spatial_df2, spatial_df3)
plot_layer_names = c("macroplot1_", "macroplot2_", "macroplot3_")

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

round_to_half <- function(num) {
  return (round(num * 2, 0) / 2)
}

# loop through macroplots
for (i in 1:3) {
  if (i == 1) {
    current.macroplot = macroplot1
  } else if (i == 2) {
    current.macroplot = macroplot2
  } else {
    current.macroplot = macroplot3
  }
  current.spdf <- plot_layers[[i]]
  data_name <- names(current.spdf)[1]
  formula <- as.formula(paste(data_name, '~ 1'))
  clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
  
  
  variogram = autofitVariogram(formula = formula, input_data = current.spdf, verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
  
  losses <- c()
  
  # loop through clip plots to be excluded
  for (k in 1:24) {
  
    excluded.x <- clip.plots.x[k]
    excluded.y <- clip.plots.y[k]

    clique <- subset(current.spdf, !(current.spdf$X == excluded.x & current.spdf$Y == excluded.y))    
    kriged <- krige(formula, clique, newdata=grid_points, model = variogram$var_model)
    kriging_df <- as.data.frame(kriged)
    #print(subset(kriging_df, x == round_to_half(excluded.x) & y == round_to_half(excluded.y), select = c(x, y)))
    known.value <- subset(current.macroplot, (X == excluded.x & Y == excluded.y), select = c(total_biomass))[[1]]
    predicted.value <-  subset(kriging_df, x == round_to_half(excluded.x) & y == round_to_half(excluded.y), select = c(var1.pred))[[1]]
    losses <- c(losses, (predicted.value - known.value)^2)
    
    # make an image of the plot
    #this_plot <- ggplot(kriging_df, aes(x = x, y = y, fill = var1.pred)) + 
      #geom_tile() + 
      #coord_fixed() + 
      #scale_fill_viridis_c() +
      #labs(title = paste("Macroplot", i, '\n', data_name, sep = ' '), fill = "Prediction")
    #print(this_plot)
    #print(c(paste("Macroplot", i, data_name, sep = ' '), sum(kriged$var1.pred)))
  
  }
  print(sqrt(mean(losses)))
}

