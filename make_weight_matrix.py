# This script uses the biomass-multiplot data to make a dictionary of neighbors and a dictionary of distances. 
# Those dictionaries are then used in libpysal.weights.W to make a weights matris. 
# The weights matrix allows us to calculate Moran's I.
import os
from dotenv import load_dotenv
import pandas as pd
import numpy as np
import libpysal
from esda.moran import Moran

load_dotenv()

# USER: set the stratum you want here ("0-30" or "30-100"). Type in the biomass type that you want. Below that, type in the location of your input csv file.
stratum = "0-30" 
biomass_type = "PC"
input_file = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/HEF Biomass 2024 multiplot.csv'

df = pd.read_csv(input_file)

print(df)

# find neighbors matrix
neighbors = {}

for i in range(len(df["Clip Plot"])):
    combined_name = str(df["Macroplot"][i]) + "_" + str(df["Clip Plot"][i])
    if combined_name not in neighbors.keys():
        neighbors[combined_name] = []

clip_plot_names = list(neighbors.keys())
for name in clip_plot_names:
    neighbors[name] = [clip_plot for clip_plot in clip_plot_names if clip_plot != name]

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
    
    distances = []
    for j in range(len(macroplots)):
        neighbor_macroplot = macroplots[j]
        neighbor_clip_plot = clip_plots[j]

        neighbor_x_series = df[(df["Macroplot"] == int(neighbor_macroplot)) & (df["Clip Plot"] == neighbor_clip_plot)]["multiplot_x"]
        neighbor_x = neighbor_x_series.iloc[0]
        neighbor_y_series = df[(df["Macroplot"] == int(neighbor_macroplot)) & (df["Clip Plot"] == neighbor_clip_plot)]["multiplot_y"]
        neighbor_y = neighbor_y_series.iloc[0]

        distance_to_neighbor = np.sqrt((neighbor_x - key_x)**2 + (neighbor_y - key_y)**2)
        distances.append(distance_to_neighbor)

    weights[key] = distances

values = df.loc[df["Stratum"] == "0-30", biomass_type]

weights_matrix = libpysal.weights.W(neighbors=neighbors, weights=weights)
moran_obj = Moran(values, weights_matrix)

print(moran_obj.I)
print(moran_obj.p_norm)