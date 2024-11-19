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

# USER: type the autocorrelation range of the biomass type here
autocorrelation_range = 2.8
# USER: input the path to your data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv"


# transform input_data into by-macroplot, with high and low strata summed into one biomass value per clip plot
input_data = pd.read_csv(input_data_path)
grouped_data = input_data.groupby(["Macroplot", "Clip Plot", "Coordinates"], as_index=False).agg({"1000hr": "sum", "100hr": "sum", "10hr": "sum", "1hr": "sum", "CL":"sum", "ETE": "sum", "FL": "sum", "PC": "sum", "PN": "sum", "Wlit-BL": "sum", "Wlive-BL": "sum"})
macroplot1 = grouped_data[grouped_data["Macroplot"] == 1]


# initialize dictionaries
inverse_distances = {}
inverse_distance_sums = {}
weights = {}

# choose one macroplot
one_plot = macroplot1       # later, this can be replaced with a loop through all three macroplots
# for each clip plot in the macroplot, find the sum of the inverses of each distance to another clip plot within the autocorrelation range
for i in range(24):
    clip_plot = one_plot["Clip Plot"][i]                        # the name of the clip plot
    list_coords = ast.literal_eval(one_plot["Coordinates"][i])      
    x = list_coords[0]
    y = list_coords[1]
    this_inverse_distances = []         # a list to store all of the inverse distances for this clip plot
    
    for inner_pair in one_plot["Coordinates"]:                  # go through all of the surrounding clip plots
        inner_list_coords = ast.literal_eval(inner_pair)
        inner_x = inner_list_coords[0]
        inner_y = inner_list_coords[1]

        distance = np.sqrt((x - inner_x)**2 + (y - inner_y)**2)
        if distance < autocorrelation_range and distance != 0:          # distances beyond the autocorrelation range don't have an effect
            this_inverse_distances.append(1 / distance)

    inverse_distances[clip_plot] = sorted(this_inverse_distances, reverse=True)        
    inverse_distance_sums[clip_plot] = sum(this_inverse_distances)
    weights[clip_plot] = 1 / sum(this_inverse_distances)**0.5               # change this exponent to adjust the strength of the weights

# print(inverse_distances)

# sorted_inverse_distance_sums = sorted(inverse_distance_sums.items(), key= lambda item: item[1])
# for item in sorted_inverse_distance_sums:
#     print(item)

sorted_weights = sorted(weights.items(), key= lambda item: item[1])
for item in sorted_weights:
    print(item)



