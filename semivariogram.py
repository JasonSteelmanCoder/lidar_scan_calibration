# make semivariograms to quantify spatial autocorrelation of biomass across a macroplot
import os
from dotenv import load_dotenv
import pandas as pd
import numpy as np
import skgstat as skg
import ast
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

load_dotenv()

# USER: put the location of your biomass data csv file here
data_source = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/HEF Biomass 2024.csv"

all_data = pd.read_csv(data_source)
all_data["Coordinates"] = all_data["Coordinates"].apply(ast.literal_eval)

# print(all_data)

# separate the data into strata of individual macroplots
macroplot1_low = all_data[(all_data["Macroplot"] == 1) & (all_data["Stratum"] == '0-30')]
macroplot1_high = all_data[(all_data["Macroplot"] == 1) & (all_data["Stratum"] == '30-100')]

macroplot2_low = all_data[(all_data["Macroplot"] == 2) & (all_data["Stratum"] == '0-30')]
macroplot2_high = all_data[(all_data["Macroplot"] == 2) & (all_data["Stratum"] == '30-100')]

macroplot3_low = all_data[(all_data["Macroplot"] == 3) & (all_data["Stratum"] == '0-30')]
macroplot3_high = all_data[(all_data["Macroplot"] == 3) & (all_data["Stratum"] == '30-100')]

# prepare coordinates and values for input
x_coords, y_coords = zip(*macroplot1_low["Coordinates"])
coords = np.array([x_coords, y_coords]).T
values = np.array(macroplot1_low["ETE"])

vgram = skg.Variogram(coordinates=coords, values=values, fit_method='trf')
vgram.distance_difference_plot()
var_plot = vgram.plot()
plt.show(block=True)

