# This script makes two panels, each with three plots, each plot representing a macroplot. 
# On each plot there are several curves. Each curve represents the margin of error for one 
# type of biomass on that macroplot for each number of clip plots from 1 to 24. 
# The first panel represents the separate biomass types. The second panel has totals.
import matplotlib.pyplot as plt
import numpy as np
import os
from dotenv import load_dotenv
import pandas as pd
from matplotlib.lines import Line2D

load_dotenv()

# USER: enter the location of the input data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/weighted_mean_and_std_biomasses_by_macroplot_and_type.csv"

colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', 
          '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf', '#ff1493', '#00ced1']

input_data = pd.read_csv(input_data_path)
# exclude 1000hr biomass, since it is either not present, or an extreme outlier
input_data = input_data[input_data["biomass_type"] != "X1000hr"]
print(input_data)
types_per_plot = int(len(input_data) / 3)

# plot the curves for each individual type of biomass (not for totals)

plt.figure() 

## loop through the three macroplots
for i in range(3):

    ## loop through the different types of biomass
    for j in range(types_per_plot):

        ## select the biomass types, leaving out totals
        biomass_type = input_data.iloc[j + i * types_per_plot, 1]
        if biomass_type != 'total_biomass' and biomass_type != 'fine_dead_fuels':

            ## set up variables for calculation
            Z = 1.96            # 95% confidence interval
            sigma = input_data.iloc[j + i * types_per_plot, 3]          # the standard deviation of the biomass on observed clip plots

            ## set up the x axis (the number of clip plots taken, from 1-24)
            n = np.linspace(1, 24, 24)

            ## calculate the margin of error curve
            margin_of_error = (Z * sigma) / np.sqrt(n)            # half the width of a 95% confidence interval
            if margin_of_error[1] != 0:                     # filter out curves that have no data
                
                ## find the (x + y) curve 
                ## this will allow us to find the optimal number of clip plots to take
                sum_xy = n + margin_of_error

                ## make three plots on one panel
                plt.subplot(1, 3, i + 1)                 
                
                ## plot the margin of error
                plt.plot(n, margin_of_error, label = input_data.iloc[j + i * types_per_plot, 1], color=colors[j])

                ## calculate and plot the optimal point on the margin of error curve
                optimal_x = sum_xy.argmin() + 1
                optimal_y = margin_of_error[sum_xy.argmin()]
                plt.plot(optimal_x, optimal_y, 'o', color=colors[j], alpha=0.5)     # plots the tip of the elbow

    ## style the figure
    plt.suptitle("Margin of Error For The Est'd Mean Biomass Per 1/4 m^2")
    plt.title(f"Macroplot {input_data.iloc[j + i * types_per_plot, 0]}")
    point_label = Line2D([0], [0], marker='o', color='w', markerfacecolor='grey', alpha=0.5)
    handles, labels = plt.gca().get_legend_handles_labels()
    handles.append(point_label)
    labels.append('min(x + y)')
    plt.legend(handles=handles, labels=labels)
    plt.ylim([0, 130])
    plt.axis('equal')
    plt.ylabel("Margin of Error")
    plt.xlabel("Number of Clip Plots")
    plt.xticks(range(1, 24, 2))

## show all of the curves together
plt.tight_layout(w_pad=-2)
plt.show()

## plot the curves for totals (total_biomass and fine_dead_fuels)

plt.figure()

## loop through the macroplots
for i in range(3):

    ## loop through the types of biomass
    for j in range(types_per_plot):

        ## grab the biomass types for totals categories
        biomass_type = input_data.iloc[j + i * types_per_plot, 1]
        if biomass_type == 'total_biomass' or biomass_type == 'fine_dead_fuels':

            ## set up variables for the calculation
            Z = 1.96            # 95% confidence interval
            sigma = input_data.iloc[j + i * types_per_plot, 3]          # the standard deviation of the biomass on observed clip plots

            ## set the x axis (the number of clip plots taken from 1 to 24)
            n = np.linspace(1, 24, 24)

            ## calculate the margin of error curve
            margin_of_error = (Z * sigma) / np.sqrt(n)            # calculate *half* the width of a 95% confidence interval

            ## calculate the (x + y) curve
            ## this will help us find the optimal number of clip plots to take
            sum_xy = n + margin_of_error

            ## plot the margin of error elbow curves
            plt.subplot(1, 3, i + 1)                 # make three plots on one panel
            plt.plot(n, margin_of_error, label = input_data.iloc[j + i * types_per_plot, 1], color=colors[j])

            ## calculate and plot the optimal point on the margin of error curve
            optimal_x = sum_xy.argmin() + 1
            optimal_y = margin_of_error[sum_xy.argmin()]
            if optimal_x != 24:                                                 # when optimal_x = 24, the optimal x is actually outside the range of the curve and shouldn't be plotted
                plt.plot(optimal_x, optimal_y, 'o', color=colors[j], alpha=0.5)     # plots the tip of the elbow
                plt.text(optimal_x + 0.5, optimal_y + 0.5, f"{int(optimal_x)}")

    ## style the figure
    plt.suptitle("Margin of Error For The Est'd Mean Biomass Per 1/4 m^2")
    plt.title(f"Macroplot {input_data.iloc[j + i * types_per_plot, 0]}")
    point_label = Line2D([0], [0], marker='o', color='w', markerfacecolor='grey', alpha=0.5)
    handles, labels = plt.gca().get_legend_handles_labels()
    handles.append(point_label)
    labels.append('num clip plots\nfor min(x + y)')
    plt.legend(handles=handles, labels=labels)
    plt.ylim([0, 130])
    plt.axis('equal')
    plt.ylabel("Margin of Error")
    plt.xlabel("Number of Clip Plots")
    plt.xticks(range(1, 24, 2))

## show the curves together in one figure
plt.tight_layout(w_pad=-2)
plt.show()