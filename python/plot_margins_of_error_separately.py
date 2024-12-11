# for each unique combination of macroplot and biomass type, this script saves an elbow plot showing the width of the confidence interval for different numbers
# of clip plots, along with a histogram showing the sample mean and the distribution of probable actual population means. The purpose of the figures is to give 
# an intuitive sense of how precise (or inprecise) our estimations of biomass are.
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy as np
import os
from dotenv import load_dotenv
import pandas as pd

load_dotenv()

# USER: enter the location of the input data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/weighted_mean_and_std_biomasses_by_macroplot_and_type.csv"
# USER: enter the location of the input folder here
output_folder = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/estimations_by_biomass_type"
# USER: put the number of samples you want to simulate here
samples_simulated = 5 

input_data = pd.read_csv(input_data_path)
# print(input_data)

for i in range(39):
    fig = plt.figure(figsize=[9, 11])
    gs = gridspec.GridSpec(3, 1)

    Z = 1.96            # 95% confidence interval
    sigma = input_data.iloc[i, 3]          # the standard deviation of the biomass on observed clip plots

    n = np.linspace(1, 24, 24)
    margin_of_error = (Z * sigma) / np.sqrt(n)
    sum_xy = n + margin_of_error

    ax1 = fig.add_subplot(gs[0:2, :])
    plt.suptitle(f"{input_data.iloc[i, 1]} Macroplot {input_data.iloc[i, 0]}")
    plt.title(f"Margin of Error For Est'd Mean Biomass\nPer 1/4 m^2")  

    if margin_of_error[0] == 0:
        plt.text(0.5, 0.5, "No biomass found for this category", ha='center', va='center')
    else:
        plt.plot(n, margin_of_error, label = f"Macroplot {input_data.iloc[i, 0]}: {input_data.iloc[i, 1]}")
        plt.legend()
        if margin_of_error[0] > 200:
            plt.annotate("Note the high\nscale of uncertainty", (-1200, 2500))
            plt.xticks([1, 24], rotation=270, fontsize='x-small')
            plt.annotate("min(x + y) is not\nreached in 24 samples", (200, 700))
        else:
            plt.ylim([0, 130])
            if margin_of_error[0] > 70:
                plt.xticks(range(0, 25, 4))
            else:
                plt.xticks(range(1, 24, 2))
            # plt.plot(n, sum_xy)       # plots the guide function
            optimal_x = sum_xy.argmin() + 1
            optimal_y = margin_of_error[sum_xy.argmin()]
            plt.plot(optimal_x, optimal_y, 'bo')     # plots the tip of the elbow
            plt.text(optimal_x + 1, optimal_y + 1, f"clip plots for\nmin(x + y): {int(np.round(optimal_x, 0))}")
            plt.legend()
            # print(optimal_x, optimal_y)
        plt.ylabel("Margin of Error")
        plt.xlabel("Number of Clip Plots")
        plt.axis('equal')

    ax2 = fig.add_subplot(gs[2, :])
    plt.title(f"Distribution of Possible\nTrue Means With {samples_simulated} Clip Plots")
    if margin_of_error[0] == 0:
        plt.text(0.5, 0.5, "No biomass found for this category", ha='center', va='center')
    else:
        prediction_distribution = np.random.normal(input_data.iloc[i, 2], (margin_of_error[samples_simulated - 1] * np.sqrt(samples_simulated)) / Z, 10000)
        plt.hist(prediction_distribution, bins=100)
        plt.xlabel("Mean Biomass")
        plt.ylabel("Count")
        plt.axvline(x=input_data.iloc[i, 2], c='red', label=f"Sample\nMean:\n{round(input_data.iloc[i, 2], 2)}")
        plt.xlim(left=0)
        plt.legend()

    plt.tight_layout()

    # save each figure to its own png image file
    file_name = f"margin_of_error_macroplot{input_data.iloc[i, 0]}_{input_data.iloc[i, 1].replace(".", "")}"
    plt.savefig(os.path.join(output_folder, file_name))
    plt.close()

