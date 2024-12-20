# CAUTION: this script only looks at one macroplot at a time. To go through all macroplots, use find_all_weights_matrices_for_weighted_mean_biomass.py

# this script will find a weights matrix to compensate for spatial autocorrelation when calculating a weighted mean or weighted standard deviation
# of clip plot biomass values
# this will be done by macroplot, with high and low strata summed into one biomass value per clip plot

import pandas as pd
import os
from dotenv import load_dotenv
import ast
import numpy as np
import matplotlib.pyplot as plt

load_dotenv()

# USER: input the path to your data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv"
# USER: input your output location here
output_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/clip_plot_weights_for_10h.csv"

# these autocorreletion ranges are based on the variogram models
autocorrelation_ranges = {
    "X1000hr": 100,
    "X100hr": 2.1,
    "X10hr": 2.8,
    "X1hr": 5.1,
    "CL": 0.92,
    "ETE": 3.2,
    "FL": 2.2,
    "PC": 7.1,
    "PN": 4.8,
    "Wlit.BL": 0.64,
    "Wlive.BL": 68
}


# transform input_data into by-macroplot, with high and low strata summed into one biomass value per clip plot
input_data = pd.read_csv(input_data_path)
grouped_data = input_data.groupby(["Macroplot", "Clip Plot", "Coordinates"], as_index=False).agg({"1000hr": "sum", "100hr": "sum", "10hr": "sum", "1hr": "sum", "CL":"sum", "ETE": "sum", "FL": "sum", "PC": "sum", "PN": "sum", "Wlit-BL": "sum", "Wlive-BL": "sum"})
macroplot1 = grouped_data[grouped_data["Macroplot"] == 1]
macroplot2 = grouped_data[grouped_data["Macroplot"] == 2]
macroplot3 = grouped_data[grouped_data["Macroplot"] == 3]
macroplot2.reset_index(inplace=True)
macroplot3.reset_index(inplace=True)


autocorrelation_range = autocorrelation_ranges["X10hr"]

plot = macroplot1

distances_by_clip_plot = {}
curved_distances_by_clip_plot = {}
weights = {}

for k in range(24):
    clip_plot = plot["Clip Plot"][k]
    list_coords = ast.literal_eval(plot["Coordinates"][k])
    x = list_coords[0]
    y = list_coords[1]
    
    distances = []
    curved_distances = []

    for coord_pair in plot["Coordinates"]:
        neighbor_coords = ast.literal_eval(coord_pair)
        neighbor_x = neighbor_coords[0]
        neighbor_y = neighbor_coords[1]

        distance = np.sqrt((x - neighbor_x)**2 + (y - neighbor_y)**2)
        if distance < autocorrelation_range and distance > 0:
            distances.append(distance)
            curved_distances.append(np.exp((-4 * distance**2) / autocorrelation_range**2))

    distances_by_clip_plot[clip_plot] = distances
    curved_distances_by_clip_plot[clip_plot] = curved_distances
    weights[clip_plot] = 1 / (1 + sum(curved_distances))

# print(distances_by_clip_plot)
# print(curved_distances_by_clip_plot)
print(weights)