library(automap)
library(sp)
library(dplyr)
library(stringr)
library(png)
library(magick)
library(glue)

input.csv <- 'C:/Users/js81535/Desktop/lidar_scan_calibration/HEF Biomass 2024 multiplot.csv'
file_data <- read.csv(input.csv)

all_strata_data <- file_data %>% 
  group_by(Macroplot, Clip.Plot, Coordinates, multiplot_x, multiplot_y) %>%
  summarize(
    'X1000hr' = sum(X1000hr), 
    'X100hr' = sum(X100hr),
    'X10hr' = sum(X10hr),
    'X1hr' = sum(X1hr),
    'CL' = sum(CL),
    'ETE' = sum(ETE), 
    'FL' = sum(FL),
    'PC' = sum(PC),
    'PN' = sum(PN),
    'Wlit.BL' = sum(Wlit.BL), 
    'Wlive.BL' = sum(Wlive.BL),
    .groups = "keep"
  )
all_strata_data$total.biomass <- all_strata_data$X1000hr + all_strata_data$X100hr + all_strata_data$X10hr + all_strata_data$X1hr + all_strata_data$CL + all_strata_data$ETE + all_strata_data$FL + all_strata_data$PC + all_strata_data$PN + all_strata_data$Wlit.BL + all_strata_data$Wlive.BL
print(all_strata_data$total.biomass)


biomass_types <- c("total.biomass")
# print(biomass_types)

for (type in biomass_types) {
  
  biomass_type = type
  
  spatial <- SpatialPointsDataFrame(
    coords = all_strata_data[, c("multiplot_x", "multiplot_y")],
    data = subset(all_strata_data, select = biomass_type)
  )
  
  
  plot_layers = c(spatial)
  plot_layer_names = c("all_strata_")
  
  for (i in 1:1) {
    data_name <- names(plot_layers[[i]])[1]
    formula <- as.formula(paste(data_name, '~ 1'))
    
    clean_data_name <- glue(plot_layer_names[[i]], gsub("\\.", "", data_name))
    png(filename = paste(clean_data_name, ".png", sep = ''))
    variogram = autofitVariogram(formula = formula, input_data = plot_layers[[i]], verbose = FALSE, miscFitOptions = list(merge.small.bins = TRUE))
    tryCatch({
      the_plot <- plot(variogram, multipanel = TRUE)
      the_plot$main = clean_data_name
      plot(the_plot)
    }, error = function(e) {
      plot(1, 1, main = clean_data_name, type = 'n', ylab = "", xlab = "")
      text(x = 1, y = 1, labels = "biomass not found for this category", col = 'darkgrey')
      #print(e)
    })
    dev.off()
    
  }
  
  png_files <- list.files(pattern = "^low_stratum_\\w*.png$")
  images <- image_join(lapply(png_files, image_read))
  combined_low_image <- image_append(images)
  #image_write(combined_low_image, path = 'combined_low_plots.png')
  for (file in png_files) {
    file.remove(file)
  }
  
  #full_set <- image_append(c(combined_high_image, combined_low_image), stack = TRUE)
  #image_write(full_set, path = glue("multiplot_variograms_", biomass_type, ".png"))
  
}




