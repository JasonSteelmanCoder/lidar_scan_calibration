# this script will estimate the weighted and unweighted total biomass of each macroplot
import os
from dotenv import load_dotenv
import pandas as pd

load_dotenv()

# USER: put the locations of your input here. You need to input weighted and unweighted means
unweighted_input = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/mean_and_std_biomasses_by_macroplot_and_type.csv"
weighted_input = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/weighted_mean_and_std_biomasses_by_macroplot_and_type.csv"
# USER: enter your output location here.
output_path = f"C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/macroplot_biomass_estimations.csv"

unweighted_df = pd.read_csv(unweighted_input)
weighted_df = pd.read_csv(weighted_input)

unweighted_df["total_biomass"] = unweighted_df["mean_biomass"] * 1256
weighted_df["weighted_total_biomass"] = weighted_df["weighted_mean_biomass"] * 1256

estimated_total_biomasses = pd.DataFrame(data={
    "macroplot": unweighted_df["macroplot"],
    "biomass_type": unweighted_df["biomass_type"],
    "total_biomass": unweighted_df["total_biomass"], 
    "weighted_total_biomass": weighted_df["weighted_total_biomass"]
})

print(estimated_total_biomasses)

estimated_total_biomasses.to_csv(output_path, index=False)