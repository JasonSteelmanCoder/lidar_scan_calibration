# this script finds and records the multi-plot coordinates of all clipplots 
# by translating the single-plot coordinates of macroplots 2 and 3 by the 
# distances and directions of their centers from the center of macroplot 1.
from dotenv import load_dotenv
import os
import pandas as pd
from ast import literal_eval
import matplotlib.pyplot as plt

load_dotenv()

#USER: write the location of your input and output here
input_file = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024.csv'
output_file = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/HEF Biomass 2024 multiplot.csv'

# set the offsets for plots that are away from the origin (the origin is the center of macroplot 3)
macroplot1_x_offset = 28.9245
macroplot1_y_offset = -7.2117
macroplot2_x_offset = 27.7773
macroplot2_y_offset = 15.3972

df = pd.read_csv(input_file)

xs = []
ys = []
for row in df["Coordinates"]:
    coord_list = literal_eval(row)
    xs.append(coord_list[0])
    ys.append(coord_list[1])

df["multiplot_x"] = xs
df["multiplot_y"] = ys

df.loc[df["Macroplot"] == 1, 'multiplot_x'] += macroplot1_x_offset
df.loc[df["Macroplot"] == 1, 'multiplot_y'] += macroplot1_y_offset
df.loc[df["Macroplot"] == 2, 'multiplot_x'] += macroplot2_x_offset
df.loc[df["Macroplot"] == 2, 'multiplot_y'] += macroplot2_y_offset

# see the coordinates
print(df)
plt.scatter(df["multiplot_x"], df["multiplot_y"])
plt.show()

# uncomment to save to csv
# df.to_csv(output_file, index=False)