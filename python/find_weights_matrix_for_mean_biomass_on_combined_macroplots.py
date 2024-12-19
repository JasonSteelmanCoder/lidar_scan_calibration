# this script will find a weights matrix to compensate for spatial autocorrelation when calculating a weighted mean or weighted standard deviation
# of clip plot biomass values
# this will be done with high and low strata summed into one biomass value per clip plot
# this has been adjusted for clip plot centers

import pandas as pd
import os
from dotenv import load_dotenv
import ast
import numpy as np
import matplotlib.pyplot as plt

load_dotenv()

# USER: input the path to your data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024 multiplot.csv"
# USER: input your output location here
output_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/weights_for_combined_macroplots.csv"

# these autocorreletion ranges are based on the variogram models
autocorrelation_ranges = {
    "X1000hr": 120,
    "X100hr": 1.3,
    "X10hr": 6.3,
    "X1hr": 5.1,
    "CL": 1.2,
    "ETE": 2.9,
    "FL": 2.2,
    "PC": 6.2,
    "PN": 6.2,
    "Wlit.BL": 0.64,
    "Wlive.BL": 91,
    "total_biomass": 352,
    "fine_dead_fuels": 3.4
}

# sum high and low strata biomasses into one value per clip plot
raw_data = pd.read_csv(input_data_path)
grouped_data = raw_data.groupby(["Macroplot", "Clip Plot", "multiplot_x", "multiplot_y"], as_index=False).agg({"1000hr": "sum", "100hr": "sum", "10hr": "sum", "1hr": "sum", "CL":"sum", "ETE": "sum", "FL": "sum", "PC": "sum", "PN": "sum", "Wlit-BL": "sum", "Wlive-BL": "sum"})

# initialize data structures
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
    "total_biomass": [None] * 72,
    "fine_dead_fuels": [None] * 72
}
output = pd.DataFrame(initial_data)

## loop through biomass types and their ranges
for type_range in autocorrelation_ranges.items():
    biomass_type = type_range[0]
    autocorrelation_range = type_range[1]

    ## loop through clip plots
    for i in range(72):
        clip_plot_name = str(grouped_data.iloc[i, 0]) + '_' + grouped_data.iloc[i, 1]
        multiplot_x = grouped_data.iloc[i, 2]
        multiplot_y = grouped_data.iloc[i, 3]


        if autocorrelation_range is None:
            weights[clip_plot_name] = 0
            continue
        else:
            distances = []
            curved_distances = []

            ## loop through clip plots again, this time looking for neighbors
            for k in range(72):
                neighbor_multiplot_x = grouped_data.iloc[k, 2]
                neighbor_multiplot_y = grouped_data.iloc[k, 3]

                distance = np.sqrt((multiplot_x - neighbor_multiplot_x)**2 + (multiplot_y - neighbor_multiplot_y)**2)
                if distance < autocorrelation_range and distance > 0:
                    distances.append(distance)
                    curved_distances.append(np.exp((-4 * distance**2) / autocorrelation_range**2))

            distances_by_clip_plot[clip_plot_name] = distances
            curved_distances_by_clip_plot[clip_plot_name] = curved_distances
            weights[clip_plot_name] = 1 / (1 + sum(curved_distances))       

    # print()
    # print(biomass_type)
    # print(autocorrelation_range)
    # print(weights)

    for item in weights.items():
        output.loc[(output["Macroplot"] == int(item[0][0])) & (output["Clip.Plot"] == item[0][2:]), biomass_type] = item[1]

print(output)

## uncomment to save to csv
# output.to_csv(output_data_path, index=False)
