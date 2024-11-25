import os
from dotenv import load_dotenv
import pandas as pd
import numpy as np

load_dotenv()

masses = pd.read_csv(f'C:/Users/{os.getenv('MS_USER_NAME')}/Desktop/lidar_scan_calibration/csv_data/biomasses_with_strata_combined.csv')
weighted_masses = pd.read_csv(f'C:/Users/{os.getenv('MS_USER_NAME')}/Desktop/lidar_scan_calibration/csv_data/weighted_masses.csv')
weights = pd.read_csv(f'C:/Users/{os.getenv('MS_USER_NAME')}/Desktop/lidar_scan_calibration/csv_data/clip_plot_weights.csv')

masses_plot1 = masses[masses['Macroplot'] == 1]
masses_plot2 = masses[masses['Macroplot'] == 2]
masses_plot3 = masses[masses['Macroplot'] == 3]

weighted_plot1 = weighted_masses[weighted_masses['Macroplot'] == 1]
weighted_plot2 = weighted_masses[weighted_masses['Macroplot'] == 2]
weighted_plot3 = weighted_masses[weighted_masses['Macroplot'] == 3]

weight_plot1 = weights[weights['Macroplot'] == 1]
weight_plot2 = weights[weights['Macroplot'] == 2]
weight_plot3 = weights[weights['Macroplot'] == 3]

masses_plot2.reset_index(inplace=True)
masses_plot3.reset_index(inplace=True)
weighted_plot2.reset_index(inplace=True)
weighted_plot3.reset_index(inplace=True)
weight_plot2.reset_index(inplace=True)
weight_plot3.reset_index(inplace=True)

mass_plots = [masses_plot1, masses_plot2, masses_plot3]
weighted_plots = [weighted_plot1, weighted_plot2, weighted_plot3]
weight_plots = [weight_plot1, weight_plot2, weight_plot3]

for i in range(3): 
    mp = mass_plots[i]
    wp = weighted_plots[i]
    ws = weight_plots[i]
    unweighted_losses = []
    weighted_losses = []

    for k in range(24):
        unweighted_ingroup = mp["total_biomass"].drop(k)
        weighted_ingroup = wp["total_biomass"].drop(k)
        weights_ingroup = ws["total_biomass"].drop(k)
        test_value = mp.loc[k, "total_biomass"]
        
        unweighted_estimated_mean_biomass_per_clip_plot = np.mean(unweighted_ingroup)
        weighted_estimated_mean_biomass_per_clip_plot = weighted_ingroup.sum() / weights_ingroup.sum()
        unweighted_losses.append((unweighted_estimated_mean_biomass_per_clip_plot - test_value)**2)
        weighted_losses.append((weighted_estimated_mean_biomass_per_clip_plot - test_value)**2)

    print(np.sqrt(np.mean(unweighted_losses)))
    print(np.sqrt(np.mean(weighted_losses)))
    print()


