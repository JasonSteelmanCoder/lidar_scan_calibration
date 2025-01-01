import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit

data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/structural_variance_with_distance.csv"

input_data = pd.read_csv(data_path)

macroplots = input_data["macroplot"]
distances = input_data["distance"]
mean_heights = input_data["mean_height"]
pct_points_stratum2 = input_data["pct_points_stratum2"]
point_density_stratum2 = input_data["point_density_stratum2"]

agg_data = input_data.groupby("distance", as_index=False).agg({
    "distance": 'max',           # this is just a list of the unique distances
    "mean_height": 'count',      # this is just a count of the number of voxels for each distance
    "point_density_stratum2": 'std'     # this is the local standard deviation for each distance from plot center
})
agg_data = agg_data.rename(columns={        # rename columns to avoid confusion
    "distance": "unique_distance",
    "mean_height": "num_voxels",
    "point_density_stratum2": "local_standard_deviation_for_density"
})
counts = agg_data["num_voxels"]
local_standard_deviations_for_density = agg_data["local_standard_deviation_for_density"]

## work with point density in stratum 2
## define power law decay for the trend line
def power_law(x, a, b):
    return a * x**(-b)

## calculate the trend line
params, covariance = curve_fit(power_law, distances, point_density_stratum2)
a_fit, b_fit = params
x_fit = np.linspace(min(distances), max(distances), 31)
y_fit = power_law(x_fit, a_fit, b_fit)
print()
print(f"point density formula:\n{a_fit} * x^-{b_fit}")

## visualize the data and trend line
plt.scatter(distances, point_density_stratum2)
plt.plot(x_fit, y_fit, color="black")
plt.title("Point Density in Stratum 2 (50-100cm)")
plt.xlabel("Distance from Macroplot Center to Voxel Center (m)")
plt.ylabel("Points Per m^3 In Stratum 2")
# plt.show()
plt.clf()

## normalize
input_data["point_density_straightened"] = input_data["point_density_stratum2"] - power_law(input_data["distance"], a_fit, b_fit)
input_data = input_data.merge(agg_data[["unique_distance", "local_standard_deviation_for_density"]], how="inner", left_on="distance", right_on="unique_distance")
# input_data["point_density_normalized"] = input_data["point_density_straightened"]...
print(input_data)
# plt.scatter(distances, input_data["point_density_straightened"])
plt.scatter(distances, input_data["point_density_straightened"] / input_data["local_standard_deviation_for_density"])
plt.plot(x_fit, [0] * 31)
plt.show()



## work with percent of points in stratum 2
# degree_of_pct_s2 = 2
# coefficients_of_pct_s2 = np.polyfit(distances, pct_points_stratum2, degree_of_pct_s2)
# polynomial_of_pct_s2 = np.poly1d(coefficients_of_pct_s2)
# x_fit_of_pct_s2 = np.linspace(min(distances), max(distances), 100)
# y_fit_of_pct_s2 = polynomial_of_pct_s2(x_fit_of_pct_s2)
# print()
# print(f"pct s2 polynomial degree and formula: {polynomial_of_pct_s2}")

# plt.scatter(distances, pct_points_stratum2)
# plt.title("Percent of Points in Stratum 2 (50-100cm)")
# plt.xlabel("Distance from Macroplot Center to Voxel Center (m)")
# plt.ylabel("Percent of Voxel's Points in Stratum 2")
# plt.plot(x_fit_of_pct_s2, y_fit_of_pct_s2, color="black")
# plt.show()



## work with mean_height
# degree_of_mean_height = 2
# coefficients_of_mean_height = np.polyfit(distances, mean_heights, degree_of_mean_height)
# polynomial_of_mean_height = np.poly1d(coefficients_of_mean_height)
# x_fit_of_mean_height = np.linspace(min(distances), max(distances), 100)
# y_fit_of_mean_height = polynomial_of_mean_height(x_fit_of_mean_height)
# print()
# print(f"mean height polynomial degree and formula: {polynomial_of_mean_height}")
# print()

# plt.scatter(distances, mean_heights)
# plt.plot(x_fit_of_mean_height, y_fit_of_mean_height, color="black")
# plt.title("Mean Height of Points (0-3m)")
# plt.xlabel("Distance from Macroplot Center to Voxel Center (m)")
# plt.ylabel("Mean Height of Points in the Voxel")
# plt.show()
# plt.clf()