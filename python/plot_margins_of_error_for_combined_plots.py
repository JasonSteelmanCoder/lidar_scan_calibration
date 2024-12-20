# This script makes two graphs.
# On each graph there are several curves. Each curve represents the margin of error for one 
# type of biomass for each number of clip plots from 1 to 72. 
# The first graph represents the separate biomass types. The second graph has totals.
import matplotlib.pyplot as plt
import numpy as np
import os
from dotenv import load_dotenv
import pandas as pd
from matplotlib.lines import Line2D

load_dotenv()

# USER: enter the location of the input data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/weighted_mean_and_std_biomasses_on_combined_macroplots.csv"

colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', 
          '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf', '#ff1493', '#00ced1']

input_data = pd.read_csv(input_data_path)
# exclude 1000hr biomass, since it is either not present, or an extreme outlier
input_data = input_data[input_data["biomass_type"] != "X1000hr"]
type_count = len(input_data)

# plot the curves for each individual type of biomass (not for totals)
plt.figure()

for j in range(type_count):

    biomass_type = input_data.iloc[j, 0]
    if biomass_type != 'total_biomass' and biomass_type != 'fine_dead_fuels':

        Z = 1.96            # 95% confidence interval
        sigma = input_data.iloc[j, 2]          # the standard deviation of the biomass on observed clip plots

        n = np.linspace(1, 72, 72)
        margin_of_error = (Z * sigma) / np.sqrt(n)            # calculate half the width of a 95% confidence interval
        if margin_of_error[1] != 0:                     # filter out curves that have no data
            sum_xy = n + margin_of_error

            plt.plot(n, margin_of_error, label = input_data.iloc[j, 0], color=colors[j])

            optimal_x = sum_xy.argmin() + 1
            optimal_y = margin_of_error[sum_xy.argmin()]
            plt.plot(optimal_x, optimal_y, 'o', color=colors[j], alpha=0.5)     # plots the tip of the elbow


plt.title("Margin of Error For The Est'd Mean Biomass Per 1/4 m^2")
point_label = Line2D([0], [0], marker='o', color='w', markerfacecolor='grey', alpha=0.5)
handles, labels = plt.gca().get_legend_handles_labels()
handles.append(point_label)
labels.append('min(x + y)')
plt.legend(handles=handles, labels=labels)
plt.ylim([0, 130])
plt.axis('equal')
plt.ylabel("Margin of Error")
plt.xlabel("Number of Clip Plots")
plt.xticks(range(1, 72, 2))

plt.tight_layout(w_pad=-2)
plt.show()

# plot the curve for totals (total_biomass and fine_dead_fuels)
plt.figure()

for j in range(type_count):

    biomass_type = input_data.iloc[j, 0]
    if biomass_type == 'total_biomass' or biomass_type == 'fine_dead_fuels':

        Z = 1.96            # 95% confidence interval
        sigma = input_data.iloc[j, 2]          # the standard deviation of the biomass on observed clip plots

        n = np.linspace(1, 72, 72)
        margin_of_error = (Z * sigma) / np.sqrt(n)            # calculate *half* the width of a 95% confidence interval
        sum_xy = n + margin_of_error

        plt.plot(n, margin_of_error, label = input_data.iloc[j, 0], color=colors[j])

        optimal_x = sum_xy.argmin() + 1
        optimal_y = margin_of_error[sum_xy.argmin()]
        if optimal_x != 72:                                                 # 
            plt.plot(optimal_x, optimal_y, 'o', color=colors[j], alpha=0.5)     # plots the tip of the elbow
            plt.text(optimal_x + 0.5, optimal_y + 0.5, f"{int(optimal_x)}")


plt.title("Margin of Error For The Est'd Mean Biomass Per 1/4 m^2")
point_label = Line2D([0], [0], marker='o', color='w', markerfacecolor='grey', alpha=0.5)
handles, labels = plt.gca().get_legend_handles_labels()
handles.append(point_label)
labels.append('num clip plots\nfor min(x + y)')
plt.legend(handles=handles, labels=labels)
plt.ylim([0, 130])
plt.axis('equal')
plt.ylabel("Margin of Error")
plt.xlabel("Number of Clip Plots")
plt.xticks(range(1, 72, 2))

plt.tight_layout(w_pad=-2)
plt.show()