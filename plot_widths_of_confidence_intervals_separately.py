import matplotlib.pyplot as plt
import numpy as np
import os
from dotenv import load_dotenv
import pandas as pd

load_dotenv()

# USER: enter the location of the input data here
input_data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/mean_and_std_biomasses_by_macroplot_and_type.csv"
# USER: enter the location of the input folder here
output_folder = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/estimations_by_biomass_type"
# USER: put the number of samples you want to simulate here
samples_simulated = 5 

input_data = pd.read_csv(input_data_path)
# print(input_data)

for i in range(33):
    plt.figure()

    Z = 1.96            # 95% confidence interval
    sigma = input_data.iloc[i, 3]          # the standard deviation of the biomass on observed clip plots

    n = np.linspace(1, 24, 24)
    W = np.sqrt((4 * (Z**2) * (sigma**2)) / (n))

    plt.subplot(1, 2, 1)
    plt.suptitle(f"{input_data.iloc[i, 1]} Macroplot {input_data.iloc[i, 0]}")
    plt.title(f"CI Width For Est'd Mean Biomass\nPer 1/4 m^2")  

    if W[0] == 0:
        plt.text(0.5, 0.5, "No biomass found for this category", ha='center', va='center')
    else:
        plt.plot(n, W, label = f"Macroplot {input_data.iloc[i, 0]}: {input_data.iloc[i, 1]}")
        plt.legend()
        if W[0] > 200:
            plt.annotate("Note the high\nscale of uncertainty", (10, 800))
        else:
            plt.ylim([0, 130])
        plt.ylabel("Width of Confidence Interval")
        plt.xlabel("Number of Clip Plots")
        plt.xticks(range(1, 24, 2))

    plt.subplot(1, 2, 2)
    plt.title(f"Distribution of Possible\nTrue Means With {samples_simulated} Clip Plots")
    if W[0] == 0:
        plt.text(0.5, 0.5, "No biomass found for this category", ha='center', va='center')
    else:
        prediction_distribution = np.random.normal(input_data.iloc[i, 2], W[samples_simulated - 1] / 4, 1000)
        plt.hist(prediction_distribution, bins=50)
        plt.xlabel("Mean Biomass")
        plt.ylabel("Count")
        plt.axvline(x=input_data.iloc[i, 2], c='red', label=f"Sample\nMean:\n{round(input_data.iloc[i, 2], 2)}")
        plt.xlim(left=0)
        plt.legend()

    plt.tight_layout()

    file_name = f"confidence_interval_macroplot{input_data.iloc[i, 0]}_{input_data.iloc[i, 1].replace(".", "")}"
    plt.savefig(os.path.join(output_folder, file_name))
    plt.close()
    
