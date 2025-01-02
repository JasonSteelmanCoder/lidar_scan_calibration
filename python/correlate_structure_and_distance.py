import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit

## USER: put your output location here
output_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/standardized_structural_variables.csv"

## grab the data and prepare variables
data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/structural_variance_with_distance.csv"

input_data = pd.read_csv(data_path)

macroplots = input_data["macroplot"]
voxel_number = input_data["voxel_number"]
distances = input_data["distance"]
mean_heights = input_data["mean_height"]
pct_points_stratum2 = input_data["pct_points_stratum2"]
point_density_stratum2 = input_data["point_density_stratum2"]

output_df = pd.DataFrame({
    "macroplot": macroplots,
    "voxel_number": voxel_number,
    "distance": distances
})

## find some aggregate values
agg_data = input_data.groupby("distance", as_index=False).agg({
    "distance": 'max',           # this is just a list of the unique distances
    "point_density_stratum2": 'std',     # this is the local standard deviation for each distance from plot center
    "pct_points_stratum2": 'std',        # this is the local standard deviation for each distance from plot center
    "mean_height": lambda x: np.percentile(x, 75) - np.percentile(x, 25),      # this is the local IQR. IQR is used here, instead of standard dev, to account for outliers in the mean height values
})
agg_data = agg_data.rename(columns={        # rename columns to avoid confusion
    "distance": "unique_distance",
    "point_density_stratum2": "local_standard_deviation_for_density",
    "pct_points_stratum2": "local_standard_deviation_for_pct_points",
    "mean_height": "local_iqr_for_mean_height"
})

## Point Density in Stratum 2

## define power law decay for the trend line
def power_law(x, a, b):
    return a * x**(-b)

## fit a trend line
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
# plt.show()                      # plots the density data and trend line, so you can see the effect of distance from the scanner
plt.clf()

## standardize the density data with respect to distance
## make it flat
input_data["point_density_straightened"] = input_data["point_density_stratum2"] - power_law(input_data["distance"], a_fit, b_fit)
## make it homoscedastic
input_data = input_data.merge(agg_data[["unique_distance", "local_standard_deviation_for_density"]], how="inner", left_on="distance", right_on="unique_distance")

## add standardized data to the output
output_df["standardized_point_density_in_stratum2"] = input_data["point_density_straightened"] / input_data["local_standard_deviation_for_density"]

## plot the flattened data
plt.scatter(distances, input_data["point_density_straightened"])
plt.plot(x_fit, [0] * 31)
# plt.show()
plt.clf()

## plot the standardized data
plt.scatter(distances, input_data["point_density_straightened"] / input_data["local_standard_deviation_for_density"])
plt.plot(x_fit, [0] * 31)
# plt.show()
plt.clf()



## Percent of Points in Stratum 2

## fit a trend line
degree_of_pct_s2 = 2
coefficients_of_pct_s2 = np.polyfit(distances, pct_points_stratum2, degree_of_pct_s2)
polynomial_of_pct_s2 = np.poly1d(coefficients_of_pct_s2)
x_fit_of_pct_s2 = np.linspace(min(distances), max(distances), 31)
y_fit_of_pct_s2 = polynomial_of_pct_s2(x_fit_of_pct_s2)
print()
print(f"pct s2 polynomial degree and formula: {polynomial_of_pct_s2}")

## visualize the data and the trend line
plt.scatter(distances, pct_points_stratum2)
plt.title("Percent of Points in Stratum 2 (50-100cm)")
plt.xlabel("Distance from Macroplot Center to Voxel Center (m)")
plt.ylabel("Percent of Voxel's Points in Stratum 2")
plt.plot(x_fit_of_pct_s2, y_fit_of_pct_s2, color="black")
# plt.show()          # plots the percent points data and trend line, so you can see the effect of distance from the scanner
plt.clf()

## standardize the pct points data with respect to distance
## make it flat
input_data["pct_points_straightened"] = input_data["pct_points_stratum2"] - polynomial_of_pct_s2(input_data["distance"])
## make it homoscedastic
input_data = input_data.merge(agg_data[["unique_distance", "local_standard_deviation_for_pct_points"]], how="inner", left_on="distance", right_on="unique_distance")

## add standardized data to the output
output_df["standardized_pct_points_in_stratum2"] = input_data["pct_points_straightened"] / input_data["local_standard_deviation_for_pct_points"]

## plot the flattened data
plt.scatter(distances, input_data["pct_points_straightened"])
plt.plot(x_fit_of_pct_s2, [0] * 31)
# plt.show()
plt.clf()

## plot the standardized data
plt.scatter(distances, input_data["pct_points_straightened"] / input_data["local_standard_deviation_for_pct_points"])
plt.plot(x_fit_of_pct_s2, [0] * 31)
# plt.show()
plt.clf()



## Mean Height

## fit a trend line
degree_of_mean_height = 2
coefficients_of_mean_height = np.polyfit(distances, mean_heights, degree_of_mean_height)
polynomial_of_mean_height = np.poly1d(coefficients_of_mean_height)
x_fit_of_mean_height = np.linspace(min(distances), max(distances), 100)
y_fit_of_mean_height = polynomial_of_mean_height(x_fit_of_mean_height)
print()
print(f"mean height polynomial degree and formula: {polynomial_of_mean_height}")
print()

## visualize the data and the trend line
plt.scatter(distances, mean_heights)
plt.plot(x_fit_of_mean_height, y_fit_of_mean_height, color="black")
plt.title("Mean Height of Points (0-3m)")
plt.xlabel("Distance from Macroplot Center to Voxel Center (m)")
plt.ylabel("Mean Height of Points in the Voxel")
# plt.show()            # plots the mean_height data and trend line, so you can see the effect of distance from the scanner
plt.clf()

## standardize the mean_height data with respect to distance
## make it flat
input_data["mean_height_straightened"] = input_data["mean_height"] - polynomial_of_mean_height(input_data["distance"])
## make it homoscedastic
input_data = input_data.merge(agg_data[["unique_distance", "local_iqr_for_mean_height"]], how="inner", left_on="distance", right_on="unique_distance")

## add standardized data to the output
output_df["standardized_mean_height"] = input_data["mean_height_straightened"] / input_data["local_iqr_for_mean_height"]

## plot the flattened data
plt.scatter(distances, input_data["mean_height_straightened"])
plt.plot(x_fit_of_pct_s2, [0] * 31)
# plt.show()
plt.clf()

## plot the standardized data
plt.scatter(distances, input_data["mean_height_straightened"] / input_data["local_iqr_for_mean_height"])
plt.plot(x_fit_of_pct_s2, [0] * 31)
# plt.show()
plt.clf()

## view the output
print(output_df)

## uncomment to save the output to file
# output_df.to_csv(output_path, index=False)