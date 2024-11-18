import matplotlib.pyplot as plt
import numpy as np
import os
from dotenv import load_dotenv
import pandas as pd

load_dotenv()

# USER: enter the location of the input data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/mean_and_std_biomasses_by_macroplot_and_type.csv"

colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', 
          '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf', '#ff1493']

input_data = pd.read_csv(input_data_path)
print(input_data)
for i in range(3):
    for j in range(11):

        Z = 1.96            # 95% confidence interval
        sigma = input_data.iloc[j + i * 11, 3]          # the standard deviation of the biomass on observed clip plots

        n = np.linspace(1, 24, 24)
        W = np.sqrt((4 * (Z**2) * (sigma**2)) / (n))
        # print(W)

        plt.plot(n, W, label = input_data.iloc[j + i * 11, 1], color=colors[j])

    # print()
    plt.suptitle("CI Width For The Est'd Mean Biomass Per 1/4 m^2")
    plt.title(f"Macroplot {input_data.iloc[j + i * 11, 0]}")
    plt.legend()
    plt.ylim(bottom=0)
    plt.ylabel("Width of Confidence Interval")
    plt.xlabel("Number of Clip Plots")
    plt.xticks(range(1, 26))
    plt.show()

