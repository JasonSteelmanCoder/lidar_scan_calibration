# Summary
This project takes as input three lidar scans of forest plots in the Hitchiti Experimental Forest, accompanied by biomass data of 24 clip plots taken from each macroplot. 

# Goals
Goals of the project include:
- understanding the distributions of different types of biomass in a macroplot
- finding the number of clip plots necessary to accurately estimate the biomass of a whole macroplot
- developing a model to estimate the biomass on a macroplot, based on its lidar scan

# Structure of Readme
Below, I enumerate the steps that I took to further these goals. The steps are organized by indentation. The leftmost layer of indentation represents intermediate goals. Below and to the right of those goals, you will find the steps taken. Most of those steps include the name of a script that was used to accomplish the goal. Where that script produced an output in the form of a file or several files, those are named in the third level of indentation, along with any important notes about the step.

# Steps and Details
    Find Moran's I
        find moran's I for one biomass type using **calculate_morans_i.py** 
            set autocorrelation range (None to use IDW, int to use binary matrix)
        find moran's I for all biomasses using calculate_all_morans_i.py (still under construction!) (may need updating for adjusted clip plot centers)

    Make variogram panels
        -- test coordinates with demonstrate_coordinate_system.py --
        adjust the coordinates to be at the center of the clip plots with find_adjusted_coordinates.py
        make variogram panels with semivariogram_automap_2.r
            they go in the variogram_panels/ folder with names like variograms_CL.png

    Make multi-plot variograms
        measure distance from center to center using the measuring tool in ArcGIS Pro on the blk_biomass shapefile 
        do the math for the coordinate system   
            the westmost plot's center is (0,0)
            the line from the origin to the center of plot 2 is 29 degrees from east and the distance is 31.76
            the line from the origin to the center of plot 1 is 14 degrees from east and the distance is 29.81
            use sin and cosin to find the offsets for the centers of macroplots 1 and 2
        offset the coordinates of plots 1 and 2 and add them to "HEF Biomass 2024 multiplot.csv" using calculate_multiplot_coordinates.py
        make multiplot variograms with multiplot_variograms.r
            these go in multiplot_variograms/ folder with names like multiplot_variograms_ETE.png
        make multiplot variogram for total biomass with multiplot_variograms_total.r
            it goes in multiplot_variograms/ folder with the name multiplot_variograms_total.biomass.png

    Make all-strata multi-plot variograms
        merge strata and make a multiplot variogram using multiplot_all_strata_variograms.r
            they go in the all_strata_variograms/ folder with names like all_strata_CL.png
        make an all-strata multi-plot variogram for total biomass using multiplot_all_strata_variogram_total.r
            it goes in all_strata_variograms/ with the name all_strata_totalbiomass.png
        make an all-strata multi-plot variogram for fine_dead_fuels using multiplot_all_strata_variogram_fine_dead_fuels.r
            it goes in all_strata_variograms/ with the name all_strata_finedeadfuels.png
        
    Make all-strata single-macroplot variograms
        make a unique variogram for each pair of macroplot and biomass type, combining strata into one value using all_strata_by_macroplot_variograms.r
            this will also make a variogram for total biomass and fine_dead_fuels on each macroplot
            variograms are saved under all_strata_by_macroplot_variograms/ with names like macroplot1_CL.png 

    Calculate weights
        get weights matrix for mean and std biomasses using find_all_weights_matrices_for_weighted_mean_biomass.py
            use it to make clip_plot_weights.csv
            this will also include weights for total_biomass and fine_dead_fuels on each macroplot
        get weights matrix for all macroplots combined using find_weights_matrix_for_mean_biomass_on_combined_macroplots.py
            use it to make weights_for_combined_macroplots.csv

    Validate weights
        get weighted masses and combined-strata masses from find_weighted_mean_and_std_biomasses_by_macroplot_and_type.r
            that's not the primary purpose of the script, but it's a good side effect
            use it to make biomasses_with_strata_combined.csv and weighted_masses.csv
        compare LOO weighted and unweighted using loo_weight_validation.py
        
    Find mean and std of biomasses (weighted and unweighted)
        find (unweighted) mean and standard of biomasses for each unique combination of macroplot and biomass type with find_mean_and_std_biomasses_by_macroplot_and_type.r
            use it to make mean_and_std_biomasses_by_macroplot_and_type.csv

        find weighted mean and standard of biomasses for each unique combination of macroplot and biomass type with find_weighted_mean_and_std_biomasses_by_macroplot_and_type.r
            use it to make weighted_mean_and_std_biomasses_by_macroplot_and_type.csv   
            this will also include a mean and std for total biomass on each macroplot 

        find weighted mean and standard of biomasses on combined macroplots using find_weighted_mean_and_std_biomass_oncombined_plots.r
            use it to make weighted_mean_and_std_biomasses_on_combined_macroplots.csv

    Find margins of error (elbow plots) (previously width of confidence intervals) (helps us determine number of clip plots needed per macroplot)
        make sure you have found the mean and std of biomasses (see above)
        find autocorrelation ranges of each biomass type for combined high and low strata using multiplot_all_strata_variograms.r (and multiplot_all_strata_variogram_total.r)
            (read the ranges from the variograms)
        make elbow plots of each macroplot, split up by type with plot_all_margins_of_error_by_num_samples.py
            creates plots in memory
            this will also include plots for total_biomass and fine_dead_fuels
        make elbow plots and model the actual mean for each biomass type and macroplot with plot_margins_of_error_separately.py
            makes png files stargint with margin_of_error_macroplot in estimations_by_biomass_type/ folder
            Notes:
                the x axis needs to be on the same scale as the y axis for the curves to be correctly interpreted
                min(x+y) points in the plot are rounded to the nearest whole clip plot
                some min(x+y) points are completely outside of the 24 clip plot range shown on the plots
        make elbow plots for the combined macroplots using plot_margins_of_error_for_combined_plots.py
            plots graphs in memory            

    Estimate macroplot biomasses from means
        estimate weighted and unweighted biomasses for each combination of macroplot and biomass type with estimate_macroplot_biomasses.py
            use it to make macroplot_biomass_estimations.csv

    Krige the macroplot
        krige plots using krige.R
            it will make kriged_biomass_estimations.csv
            it will make kriged plot images and save them in kriged_images/ as .png files
        do LOO validation of kriging with loo_validation_kriging.r

    Cut out individual clip plots from lidar scans
        use macroplot photos to find north in the lidar scans
            photos are in box
            my conclusions are recorded on pages 8-9 of my notebook
        find the coordinates of clip plot centers and corners adjusted for scan-North using calculate_coordinates.py
            creates coordinates_macroplot1.json, coordinates_macroplot2.json, and coordinates_macroplot3.json
        cut out clip plots from lidar scans using cut_out_clip_plots.r
            creates folders clip_plot_las1, 2, and 3
            with files like e2.las

    Find variograms for lidar scan structural variance
        classify ground points, normalize macroplots, remove tree stems, and crop heights with find_ground.r
            notes: 
                the intelimon settings for csf seemed odd - ground points were up to 0.5m from the cloth
                intelimon uses tls_normalize2, which doesn't seem to exist
                tls_normalize did not work very well, so I used lidR's normalize_height instead
                the normalization is not perfect: some points are underground
        find the squares that are fully within the radius of the circle using define_pixels_inside_macroplot_circle.py
            that makes pixel_dimensions.json
            notes:
                excludes pixels that overlap with the donut hole at center plot
        cut out the segmented pixels using segment_scan_pixels.r
            that makes .las scans that go in segmented_las1, 2, and 3
            notes: 
                includes tree-bole pixels
        choose structural variables based on Louise's paper 
            see end of spatial_variation_scratch.txt for selections
        find distance and structural variables of segmented voxels using find_structure_by_distance.r
            makes structural_variance_with_distance.csv
        standardize structural variables and plot the relationship between distance from plot center and structural variables with correlate_structure_and_distance.py
            makes standardized_structural_variables_of_voxels.csv
            plots are made in memory
            also makes local_measurements_of_spread_for_structural_variables.csv
        make variograms from structural variables of lidar scans with make_variograms_from_standardized_structural_variables.R
            manually saved variogram plots to variograms_of_lidar_structural_variables/ with names like variogrma_of_mean_height_macroplot1.png
        make variograms from structural variables of combined macroplots using make_variograms_from_combined_standardized_structural_variables.r 
            manually saved variogram plots to variograms_of_lidar_structural_variables/ with names like combined_macroplots_mean_height.png
        
    Model the biomass of clip plots based on the lidar scan
        find north based on photos (results in notebook, page 8)
        use north to cut out clip plots from the lidar scan
            use a rotation matrix from linear algebra to orient the edges of the clip plot
        find standardization formulas and values at different distances by following "find variograms for lidar scan structural variance" above
            especially correlate_structure_and_distance.py. see "standardize structural variables and plot the relationship...etc" above
        get raw structural variables from clip plots and standardize it with find_standardized_structurala_variables.r
            makes standardized_structural_variables_of_clip_plots.csv
        plot biomasses versus structural variables and calculate correlation coefficients using correlate_standardized_structural_variables_with_biomass.r
            makes plots in memory and prints correlation coefficients

    Pipeline to check if a new structural variable correlates with clip plot biomass (within the 3 macroplots and 72 clip plots that we have):
        find structural variables (and distance) of segmented voxels using find_structure_by_distance.r
            makes structural_variance_with_distance.csv
        standardize structural variables and plot the relationship between distance from plot center and structural variables with correlate_structure_and_distance.py
            makes standardized_structural_variables_of_voxels.csv
            plots are made in memory
            also makes local_measurements_of_spread_for_structural_variables.csv
        get raw structural variables from clip plots and standardize it with find_standardized_structurala_variables.r
            makes standardized_structural_variables_of_clip_plots.csv
        plot biomasses versus structural variables and calculate correlation coefficients using correlate_standardized_structural_variables_with_biomass.r
            makes plots in memory and prints correlation coefficients
