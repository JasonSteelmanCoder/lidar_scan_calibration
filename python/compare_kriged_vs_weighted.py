import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

input_csv = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/csv_data/kriged_biomass_estimations.csv'

estimations = pd.read_csv(input_csv)
estimations["weighted_vs_kriged"] = estimations["kriged_biomass"] - estimations["weighted_biomass"]
estimations["wvk_pct"] = (estimations["weighted_vs_kriged"] / estimations["weighted_biomass"]) * 100

print(estimations)
print(np.mean(estimations["wvk_pct"]))
print(np.median(estimations["wvk_pct"]))

# plt.hist(estimations["weighted_vs_kriged"], bins = 500)
# plt.show()

plt.hist(estimations["wvk_pct"], bins = 500)
plt.show()