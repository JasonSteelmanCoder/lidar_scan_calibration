import os
import pandas as pd
import matplotlib.pyplot as plt

data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/structural_variance_with_distance.csv"

input_data = pd.read_csv(data_path)
print(input_data)

macroplots = input_data["macroplot"]
distances = input_data["distance"]
mean_heights = input_data["mean_height"]
pct_points_stratum2 = input_data["pct_points_stratum2"]
point_density_stratum2 = input_data["point_density_stratum2"]

plt.scatter(distances, mean_heights)
plt.show()
plt.clf()

plt.scatter(distances, pct_points_stratum2)
plt.show()
plt.clf()

plt.scatter(distances, point_density_stratum2)
plt.show()
