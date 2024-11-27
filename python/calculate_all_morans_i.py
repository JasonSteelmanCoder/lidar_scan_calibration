# This script uses the biomass-multiplot data to make a dictionary of neighbors and a dictionary of distances. 
# Those dictionaries are then used in libpysal.weights.W to make a weights matrix. 
# The weights matrix allows us to calculate Moran's I.
import os
from dotenv import load_dotenv
import pandas as pd
import numpy as np
import libpysal
from esda.moran import Moran

load_dotenv()

# USER: Type in the location of your input csv file.
input_file = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024 multiplot.csv'
# USER: Type in the location of your output csv file.
output_file = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/morans_i.csv'

df = pd.read_csv(input_file)

# print(df)

columns = []
for column in df:
    columns.append(column)
biomass_types = columns[4:15]

# find neighbors matrix
neighbors = {}

for i in range(len(df["Clip Plot"])):
    combined_name = str(df["Macroplot"][i]) + "_" + str(df["Clip Plot"][i])
    if combined_name not in neighbors.keys():
        neighbors[combined_name] = []

clip_plot_names = list(neighbors.keys())
for name in clip_plot_names:
    neighbors[name] = [clip_plot for clip_plot in clip_plot_names if clip_plot != name]

for biomass_type in biomass_types:
    # find weights matrix
    weights = {}

    for key, value in neighbors.items():
        key_macroplot = key[0]
        key_clip_plot = key[2:]
        macroplots = [name[0] for name in value]
        clip_plots = [name[2:] for name in value]
        
        key_x_series = df[(df["Macroplot"] == int(key_macroplot)) & (df["Clip Plot"] == key_clip_plot)]["multiplot_x"]
        key_x = key_x_series.iloc[0]
        key_y_series = df[(df["Macroplot"] == int(key_macroplot)) & (df["Clip Plot"] == key_clip_plot)]["multiplot_y"]
        key_y = key_y_series.iloc[0]
        
        distance_weights = []
        for j in range(len(macroplots)):
            neighbor_macroplot = macroplots[j]
            neighbor_clip_plot = clip_plots[j]

            neighbor_x_series = df[(df["Macroplot"] == int(neighbor_macroplot)) & (df["Clip Plot"] == neighbor_clip_plot)]["multiplot_x"]
            neighbor_x = neighbor_x_series.iloc[0]
            neighbor_y_series = df[(df["Macroplot"] == int(neighbor_macroplot)) & (df["Clip Plot"] == neighbor_clip_plot)]["multiplot_y"]
            neighbor_y = neighbor_y_series.iloc[0]

            distance_to_neighbor = np.sqrt((neighbor_x - key_x)**2 + (neighbor_y - key_y)**2)
            if autocorrelation_range is None:
                distance_weights.append(1 / distance_to_neighbor)
            else:
                if distance_to_neighbor < autocorrelation_range:
                    distance_weights.append(1)
                else:
                    distance_weights.append(0)

        weights[key] = distance_weights

    print(weights)

    values = df.loc[df["Stratum"] == stratum, biomass_type]

    # don't transform the weights
    transformation = "O"

    # calculate moran's I
    weights_matrix = libpysal.weights.W(neighbors=neighbors, weights=weights, id_order=clip_plot_names)
    moran_obj = Moran(values, weights_matrix, transformation=transformation)

    print(moran_obj.I)
    if autocorrelation_range is None:
        print(moran_obj.p_norm)



# TODO: 
# combine strata!
# loop through biomass types
# find ranges