import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit

data_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/structural_variance_with_distance.csv"

input_data = pd.read_csv(data_path)
print(input_data)

macroplots = input_data["macroplot"]
distances = input_data["distance"]
mean_heights = input_data["mean_height"]
pct_points_stratum2 = input_data["pct_points_stratum2"]
point_density_stratum2 = input_data["point_density_stratum2"]

def power_law(x, a, b):
    return a * x**(-b)

params, covariance = curve_fit(power_law, distances, point_density_stratum2)
a_fit, b_fit = params
x_fit = np.linspace(min(distances), max(distances), 100)
y_fit = power_law(x_fit, a_fit, b_fit)

plt.scatter(distances, point_density_stratum2)
plt.plot(x_fit, y_fit, color="black")
plt.show()
plt.clf()

degree_of_mean_height = 2
coefficients_of_mean_height = np.polyfit(distances, mean_heights, degree_of_mean_height)
polynomial_of_mean_height = np.poly1d(coefficients_of_mean_height)
x_fit_of_mean_height = np.linspace(min(distances), max(distances), 100)
y_fit_of_mean_height = polynomial_of_mean_height(x_fit_of_mean_height)

plt.scatter(distances, mean_heights)
plt.plot(x_fit_of_mean_height, y_fit_of_mean_height, color="black")
plt.show()
plt.clf()

degree_of_pct_s2 = 2
coefficients_of_pct_s2 = np.polyfit(distances, pct_points_stratum2, degree_of_pct_s2)
polynomial_of_pct_s2 = np.poly1d(coefficients_of_pct_s2)
x_fit_of_pct_s2 = np.linspace(min(distances), max(distances), 100)
y_fit_of_pct_s2 = polynomial_of_pct_s2(x_fit_of_pct_s2)

plt.scatter(distances, pct_points_stratum2)
plt.plot(x_fit_of_pct_s2, y_fit_of_pct_s2, color="black")
plt.show()
plt.clf()
