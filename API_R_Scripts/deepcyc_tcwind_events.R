##############################################################################################
# Reask API Query Script
##############################################################################################
# 
# Author: David Schmid / david@reask.earth
# Global Head of Data Products at Reask
# Last update: 10th September 2024
#
# Description: 
# This script queries the Reask DeepCyc Probabilistic API to retrieve tropical cyclone wind event data
# for specified latitude and longitude locations. The retrieved data is then processed and saved 
# as JSON files, and later compiled into a structured Excel spreadsheet for analysis.
#
# Dependencies:
# - Libraries: readr, jsonlite, data.table, openxlsx, httr
# - Input: locations.csv (CSV with 'lat' and 'lon' columns)
# - Output: JSON files saved in 'output/metryc_tcwind_events' folder
#           Final Excel sheet saved as 'Reask_Metryc_Windspeeds.xlsx'
##############################################################################################

# Load necessary libraries
library(readr)
library(jsonlite)
library(data.table)
library(openxlsx)
library(httr)

# Define working directory
working_directory <- this.path::here()

# Set the working directory
setwd(working_directory)

# Set the working directory and make sure it contains a folder 
# named "output" with a subfolder "metryc_tcwind_events"
setwd(working_directory)
dir.create("output/deepcyc_tcwind_events", recursive = TRUE)

# Read location data from the CSV file. The CSV must have at least the two columns "lat" and "lon", 
# but it can have additional columns such as id, address, name, tiv, limit etc.
locations <- read_csv("example_locations.csv", show_col_types = FALSE)

# Convert locations to a data.table and add an index column
locations_dt <- as.data.table(locations)
locations_dt[, index := .I]

# API endpoint and product version
api_url <- "https://api.reask.earth/v2/deepcyc/tcwind/events"
product_version <- "DeepCyc-2.0.6"

# Source the API authentication script
source("authentication.R")

# Function to send API request and save the response
deepcyc_tcwind_api_request <- function(lat, lon, index) {
  query_params <- list(
    lat = lat,
    lon = lon,
    time_horizon = "now",
    wind_speed_units = "mph",
    terrain_correction = "open_water",
    wind_speed_averaging_period = "1_minute",
    tag = ""  # Add tag if available
  )
  
  # Send GET request with headers
  response <- GET(api_url, query = query_params, add_headers(headers))
  
  # Convert the raw response to JSON format
  json_content <- rawToChar(response$content)
  
  # Save the JSON content to a file in the output folder
  output_file <- paste0("output/deepcyc_tcwind_events/Idx_", index, ".json")
  write(json_content, file = output_file)
  
  print(paste("Processed location index:", index))
}

# Loop through each location and send API requests
for (i in locations_dt$index) {
  lat <- locations_dt$lat[i]
  lon <- locations_dt$lon[i]
  
  send_api_request(lat, lon, i)
}

# Function to extract storm event data from JSON files
extract_events <- function(index) {
  json_file <- paste0("output/deepcyc_tcwind_events/Idx_", index, ".json")
  event_data <- fromJSON(txt = json_file)
  
  data.table(
    index = index,
    event_id = event_data$features$properties$event_id,
    year_id = event_data$features$properties$year_id,
    wind_speed = event_data$features$properties$wind_speed,
    cell_id = event_data$features$properties$cell_id,
    wind_speed_units = event_data$header$wind_speed_units,
    terrain_correction = event_data$header$terrain_correction,
    wind_speed_averaging_period = event_data$header$wind_speed_averaging_period,
    simulation_years = event_data$header$simulation_years,
    product = event_data$header$product,
    tag = event_data$header$tag
  )
}

# Extract data from all JSON files and combine them into a single data table
event_data_list <- lapply(locations_dt$index, extract_events)
combined_event_data <- rbindlist(event_data_list, use.names = TRUE, fill = TRUE)

# Merge extracted event data with location information
final_data <- merge(combined_event_data, locations_dt[, c(setdiff(names(locations_dt), "index"), "index"), with = FALSE], 
                    by = "index", all.x = TRUE)

# Save the final data to an Excel file
output_excel_file <- "output/Reask_DeepCyc_Windspeeds.xlsx"
write.xlsx(final_data, output_excel_file)

print(paste("Data saved to:", output_excel_file))
