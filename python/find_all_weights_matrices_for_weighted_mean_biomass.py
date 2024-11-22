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
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv"
# USER: input your output location here
output_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/clip_plot_weights.csv"

# these autocorreletion ranges are based on the variogram models
autocorrelation_ranges = {
    1: {
        "X1000hr": None,
        "X100hr": 0.66,
        "X10hr": 0.25,
        "X1hr": 0.19,
        "CL": 1,
        "ETE": 24,
        "FL": 1.3,
        "PC": 21,
        "PN": 0.73,
        "Wlit.BL": 0.99,
        "Wlive.BL": 0.22, 
        "total_biomass": 0.93
    },

    2: {
        "X1000hr": None,
        "X100hr": 0.43,
        "X10hr": 0.54,
        "X1hr": 5.2,
        "CL": 0.84,
        "ETE": 0.63,
        "FL": 0.7,
        "PC": 7.5,
        "PN": 4.8,
        "Wlit.BL": 634,
        "Wlive.BL": 27,
        "total_biomass": 0.63
    },
    
    3: {
        "X1000hr": 1.4,
        "X100hr": None,
        "X10hr": 3.7,
        "X1hr": 2.5,
        "CL": 0.6,
        "ETE": 4.1,
        "FL": 1.2,
        "PC": 8.3,
        "PN": 116,
        "Wlit.BL": 31,
        "Wlive.BL": 22,
        "total_biomass": 1.4
    }
}


# transform input_data into by-macroplot, with high and low strata summed into one biomass value per clip plot
input_data = pd.read_csv(input_data_path)
grouped_data = input_data.groupby(["Macroplot", "Clip Plot", "Coordinates"], as_index=False).agg({"1000hr": "sum", "100hr": "sum", "10hr": "sum", "1hr": "sum", "CL":"sum", "ETE": "sum", "FL": "sum", "PC": "sum", "PN": "sum", "Wlit-BL": "sum", "Wlive-BL": "sum"})
macroplot1 = grouped_data[grouped_data["Macroplot"] == 1]
macroplot2 = grouped_data[grouped_data["Macroplot"] == 2]
macroplot3 = grouped_data[grouped_data["Macroplot"] == 3]
macroplot2.reset_index(inplace=True)
macroplot3.reset_index(inplace=True)

# initialize data structures
plots = [macroplot1, macroplot2, macroplot3]

distances_by_clip_plot = {}
curved_distances_by_clip_plot = {}
weights = {}

initial_data = {
    "Macroplot": [1] * 24 + [2] * 24 + [3] * 24,
    "Clip.Plot": ['E2', 'E2.5', 'E5', 'N2', 'N2.5', 'N5', 'NE3', 'NE4', 'NE6', 'NW3', 'NW4', 'NW6', 'S2', 'S2.5', 'S5', 'SE3', 'SE4', 'SE6', 'SW3', 'SW4', 'SW6', 'W2', 'W2.5', 'W5'] * 3,
    "X1000hr": [None] * 72,
    "X100hr": [None] * 72,
    "X10hr": [None] * 72,
    "X1hr": [None] * 72,
    "CL": [None] * 72,
    "ETE": [None] * 72,
    "FL": [None] * 72,
    "PC": [None] * 72,
    "PN": [None] * 72,
    "Wlit.BL": [None] * 72,
    "Wlive.BL": [None] * 72,
    "total_biomass": [None] * 72
}
output = pd.DataFrame(initial_data)

# populate the output. The outer loop cycles through the three macroplots. The inner loop goes through the 11 biomass types and their autocorrelation ranges
for i in range(3):
    plot = plots[i]

    plot_data = autocorrelation_ranges[i + 1]

    for item in plot_data.items():
        biomass_type = item[0]
        autocorrelation_range = item[1]

        # go through all 24 clip plots with the given macroplot and range
        for k in range(24):
            clip_plot = plot["Clip Plot"][k]
            if autocorrelation_range is None:
                weights[clip_plot] = 0       # if there is no data for a biomass type, give it a weight of 0
                continue
            else:
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
        
        print(f"macroplot: {i + 1}")
        print(biomass_type)
        print(autocorrelation_range)
        print(weights)

        # add the calculated weights to the output data frame
        for item in weights.items():
            output.loc[(output["Macroplot"] == i + 1) & (output["Clip.Plot"] == item[0]), biomass_type] = item[1]

print(output)

# uncomment to save to csv
# output.to_csv(output_data_path, index=False)