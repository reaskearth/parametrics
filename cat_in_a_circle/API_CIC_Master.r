##############################################################################################
# Master API Query Script for Probabilistic and Historical Cat in a Circle TC Data
##############################################################################################
#
# Author: David Schmid / david@reask.earth
# Global Head of Data Products at Reask
# Last update: Zurich, 23th March 2025
#
# Description:
#   This master script sets common parameters for querying both the historical (Metryc) and 
#   probabilistic (DeepCyc) wind speed data via the Reask API, and then runs both API scripts.
#
##############################################################################################

###############################################################################
#                           User Input Parameterisation                       #
###############################################################################
locations_file                 <- "locations_CIC.csv"   # Locations with loc_id, name, lat, lon and radius_1[km] to radius_X[km]. Radius needs to be in km.
wind_speed_units               <- "kph"             # kph, mph, ms, kts
wind_speed_averaging_period    <- "1_minute"        # 1_minute (for open_water & open_terrain), 3_seconds (for full_terrain_gust)
wind_speed_threshold           <- 80                # Filtering out unneeded wind speed values

###############################################################################
#                             Library Imports                                 #
###############################################################################
required_packages <- c("data.table", "jsonlite", "dplyr", "glue", "here", "httr", "openxlsx")
# Note: readxl and writexl are removed since we are now reading CSV files and using openxlsx.
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) {
  install.packages(new_packages)
}
invisible(suppressPackageStartupMessages(lapply(required_packages, library, character.only = TRUE)))

# Run the Historical API script
source(here("API_metryc_tctracks_events_CIC.r"))

# Run the Probabilistic API script
source(here("API_deepcyc_tctracks_events_CIC.r"))
