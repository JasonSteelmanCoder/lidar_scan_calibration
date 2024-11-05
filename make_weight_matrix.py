# This script uses the biomass-multiplot data to make a dictionary of neighbors and a dictionary of distances. 
# Those dictionaries can then be used in libpysal.weights.W to make Weights for use in esda.Moran
import os
from dotenv import load_dotenv
import pandas as pd

load_dotenv()

input_file = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/HEF Biomass 2024 multiplot.csv'

df = pd.read_csv(input_file)

print(df)

neighbors = {}

for i in range(len(df["Clip Plot"])):
    combined_name = str(df["Macroplot"][i]) + "_" + str(df["Clip Plot"][i])
    if combined_name not in neighbors.keys():
        neighbors[combined_name] = []

clip_plot_names = list(neighbors.keys())
for name in clip_plot_names:
    neighbors[name] = [clip_plot for clip_plot in clip_plot_names if clip_plot != name]



