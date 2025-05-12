##############################################################################################
# Master API Query Script
##############################################################################################
#
# Author: David Schmid / david@reask.earth
# Global Head of Data Products at Reask
# Zurich, March 2025
#
# Description:
#   This master script sets common parameters for querying both the historical (Metryc) and 
#   probabilistic (DeepCyc) wind speed data via the Reask API, and then runs both API scripts.
#
##############################################################################################

###############################################################################
#                           User Input Parameterisation                       #
###############################################################################
locations_file                 <- "locations.csv"   # File must include lat, lon. The id and limit is not required.
wind_speed_units               <- "kph"             # kph, mph, ms, kts
terrain_correction             <- "open_water"      # open_water, open_terrain, full_terrain_gust
wind_speed_averaging_period    <- "1_minute"        # 1_minute (for open_water & open_terrain), 3_seconds (for full_terrain_gust)
wind_speed_threshold           <- 0                 # Filtering out unneeded wind speed values
agency_metryc                  <- "USA"             # USA, BOM
metryc_product_version         <- "Metryc-1.0.5"    # Metryc-1.0.5 is default.
deepcyc_product_version        <- "DeepCyc-2.0.7"

# List of required packages
required_packages <- c("httr", "data.table", "arrow", "here")

# Identify any packages that are not yet installed
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

# Install missing packages if necessary
if (length(new_packages)) {
  install.packages(new_packages)
}

# Load all required packages
library(httr)       # For API requests
library(data.table) # Fast data processing
library(arrow)      # For Parquet export
library(here)       # For relative file paths

# Run the Historical API script
source(here("API_Authentication.r"))

# Run the Historical API script
source(here("API_metryc_tcwinds_events_WaL.r"))

# Run the Probabilistic API script
source(here("API_deepcyc_tcwinds_events_WaL.r"))
