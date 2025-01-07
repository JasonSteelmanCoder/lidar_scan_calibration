## This program checks the effectiveness of the weights matrix by estimating the biomass of a macroplot using all but one of the clip plot values. 
## This is first performed using the unweighted biomasses, then the weighted biomasses. 
## The weighted biomasses should do a better job thatn the unweighted ones at estimating the macroplot biomass with missing data.

import os
from dotenv import load_dotenv
import pandas as pd
import numpy as np

load_dotenv()

## USER: put the paths to your input files here
masses = pd.read_csv(f'C:/Users/{os.getenv('MS_USER_NAME')}/Desktop/lidar_scan_calibration/csv_data/biomasses_with_strata_combined.csv')
weighted_masses = pd.read_csv(f'C:/Users/{os.getenv('MS_USER_NAME')}/Desktop/lidar_scan_calibration/csv_data/weighted_masses.csv')
weights = pd.read_csv(f'C:/Users/{os.getenv('MS_USER_NAME')}/Desktop/lidar_scan_calibration/csv_data/clip_plot_weights.csv')

## put the relevant data into variables
masses_plot1 = masses[masses['Macroplot'] == 1]
masses_plot2 = masses[masses['Macroplot'] == 2]
masses_plot3 = masses[masses['Macroplot'] == 3]

weighted_plot1 = weighted_masses[weighted_masses['Macroplot'] == 1]
weighted_plot2 = weighted_masses[weighted_masses['Macroplot'] == 2]
weighted_plot3 = weighted_masses[weighted_masses['Macroplot'] == 3]

weight_plot1 = weights[weights['Macroplot'] == 1]
weight_plot2 = weights[weights['Macroplot'] == 2]
weight_plot3 = weights[weights['Macroplot'] == 3]

## reset the indexes in the series so that they all match
masses_plot2.reset_index(inplace=True)
masses_plot3.reset_index(inplace=True)
weighted_plot2.reset_index(inplace=True)
weighted_plot3.reset_index(inplace=True)
weight_plot2.reset_index(inplace=True)
weight_plot3.reset_index(inplace=True)

## collect the series into lists to loop through
mass_plots = [masses_plot1, masses_plot2, masses_plot3]
weighted_plots = [weighted_plot1, weighted_plot2, weighted_plot3]
weight_plots = [weight_plot1, weight_plot2, weight_plot3]

## loop through the lists above
## i.e. loop through the three macroplots
for i in range(3): 
    mp = mass_plots[i]
    wp = weighted_plots[i]
    ws = weight_plots[i]
    unweighted_losses = []
    weighted_losses = []

    ## loop through the clip plots in the current macroplot
    for k in range(24):

        ## leave out the currently selected clip plot from the data
        unweighted_ingroup = mp["total_biomass"].drop(k)
        weighted_ingroup = wp["total_biomass"].drop(k)
        weights_ingroup = ws["total_biomass"].drop(k)
        test_value = mp.loc[k, "total_biomass"]
        
        ## estimate the mean biomass across the macroplot (with one clip plot missing)
        ## do this once with the unweighted values and once with the weighted values
        unweighted_estimated_mean_biomass_per_clip_plot = np.mean(unweighted_ingroup)
        weighted_estimated_mean_biomass_per_clip_plot = weighted_ingroup.sum() / weights_ingroup.sum()

        ## check how far the estimates were from the correct value
        ## add the difference to a list
        unweighted_losses.append((unweighted_estimated_mean_biomass_per_clip_plot - test_value)**2)
        weighted_losses.append((weighted_estimated_mean_biomass_per_clip_plot - test_value)**2)

    ## print the results
    ## weighted losses should be less than unweighted losses
    print(np.sqrt(np.mean(unweighted_losses)))
    print(np.sqrt(np.mean(weighted_losses)))
    print()


