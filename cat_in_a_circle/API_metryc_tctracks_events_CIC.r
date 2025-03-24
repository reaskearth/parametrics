##############################################################################################
# Reask Cat in a Circle API Query Script for Historical Track Data (based on IBTrACS)
##############################################################################################
#
# Author: David Schmid / david@reask.earth
# Global Head of Data Products at Reask
# Last update: Zurich, 23th March 2025
#
# Description:
#   This script queries the Reask API /metryc/tctrack/events endpoint for maximum wind speed data
#   (Vmax) used to structure and back-test Cat in a Circle parametric contracts.
#
#   The results are saved to the folder results in an Excel file that contains one sheet per 
#   location with the Vmax per event within the circle per radius. The last sheet "meta" contains 
#   meta data about the model and the locations data (with loc_idx as the first column that can be
#   mapped back to the original loc_id). The CSV format include the data in long format allowing 
#   a flexible processing of the data.
#
# Dependencies:
#   - Input: CSV file "locations_CIC.csv" saved in working direcory.
#   - API_CIC_Master.R: defines parameters
##############################################################################################

###############################################################################
#                           User Input Parameterisation                       #
###############################################################################
api_url                        <- "https://api.reask.earth/v2/metryc/tctrack/events"

# API query parameters (commented: defined in master file):
agency                         <- "USA" # USA, BOM
# wind_speed_units               <- "kph"
# wind_speed_averaging_period    <- "1_minute"


# Output file names:
output_xlsx                    <- "results/metryc_tctracks_events_CIC.xlsx"
output_csv                     <- "results/metryc_tctracks_events_long_CIC.csv"

###############################################################################
#                             Library Imports                                 #
###############################################################################
required_packages <- c("data.table", "jsonlite", "dplyr", "glue", "here", "httr", "openxlsx")

new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) {
  install.packages(new_packages)
}
invisible(suppressPackageStartupMessages(lapply(required_packages, library, character.only = TRUE)))

###############################################################################
#                           Setup Working Directory                           #
###############################################################################
setwd(here())

# Ensure the "results" folder exists; if not, create it
if (!dir.exists("results")) {
  dir.create("results", recursive = TRUE)
}

###############################################################################
#                           Data Input                                        #
###############################################################################
# Global variable to store metadata (captured from the first valid JSON response)
meta_data <- NULL

# Read locations from the CSV file in the working directory
locations <- fread(locations_file)

# Append loc_idx column and move it to the beginning (i.e., before loc_id)
locations[, loc_idx := .I]
cols_order <- c("loc_idx", setdiff(names(locations), "loc_idx"))
locations <- locations[, ..cols_order]

# Determine the radius columns dynamically (assuming they start with "radius_")
radius_IDs <- seq_len(ncol(locations %>% select(starts_with("radius_"))))

# Source the API authentication script (adjust the path as necessary)
source(here("API_Authentication.R"))

###############################################################################
#                           Main Processing Loop                              #
###############################################################################
# Function to send an API request and save the JSON response to a temporary file
send_api_request <- function(lat, lon, tag, radius_km, loc_idx, radius_ID) {
  query_params <- list(
    lat = lat,
    lon = lon,
    tag = tag,
    geometry = "circle",
    radius_km = radius_km,
    scenario = "current_climate",
    time_horizon = "now",
    wind_speed_units = wind_speed_units,
    agency = agency,
    accurate_flag = "true"
  )
  
  # Send GET request with authentication headers
  response <- GET(api_url, query = query_params, add_headers(headers))
  
  # Check response status; if unsuccessful, log and return NULL
  if (http_status(response)$category != "Success") {
    message(glue("API request failed for loc_id {tag}, radius {radius_ID}: {http_status(response)$message}"))
    return(NULL)
  }
  
  # Convert response content to a character string (JSON)
  json_content <- rawToChar(response$content)
  
  # Save JSON content to a temporary file
  json_filename <- tempfile(pattern = glue("Loc{loc_idx}_radius_{radius_ID}_"), fileext = ".json")
  write(json_content, file = json_filename, append = FALSE)
  print(glue("Processed loc_id {tag} (loc_idx {loc_idx}) for radius {radius_ID}"))
  
  return(json_filename)
}

# Initialize list to store long-format event data
all_data_list <- list()

# Loop over each location and each radius, storing temporary file paths
for (i in 1:nrow(locations)) {
  tag <- locations$loc_id[i]
  
  # For each location, collect event data across radii
  dt_list <- lapply(radius_IDs, function(radius_ID) {
    radius_km_col <- paste0("radius_", radius_ID, "_[km]")
    if (!radius_km_col %in% names(locations)) return(NULL)
    
    radius_km <- locations[[radius_km_col]][i]
    if (is.na(radius_km)) return(NULL)
    
    # Get temporary file path from API request
    temp_file <- send_api_request(locations$lat[i], locations$lon[i], tag, radius_km, i, radius_ID)
    if (is.null(temp_file)) return(NULL)
    
    # Read JSON content and extract required event data fields
    Events <- fromJSON(txt = temp_file)
    
    # Capture metadata from the first valid JSON response (if not already captured)
    if (is.null(meta_data) && i == 1 && radius_ID == 1) {
      meta_data <<- data.table(
        scenario = Events$header$scenario,
        time_horizon = Events$header$time_horizon,
        map_projection = Events$header$map_projection_used_for_geometric_calculations,
        wind_speed_units = Events$header$wind_speed_units,
        wind_speed_averaging_period = Events$header$wind_speed_averaging_period,
        simulation_years = Events$header$simulation_years,
        product = Events$header$product,
        agency = agency
      )
    }
    
    dt <- data.table(
      storm_name = Events$features$properties$storm_name,
      storm_year = Events$features$properties$storm_year,
      storm_id   = Events$features$properties$storm_id,
      loc_idx    = i,
      radius_ID  = as.integer(radius_ID),
      wind_speed = round(Events$features$properties$wind_speed, 0)
    )
    
    # Delete the temporary file after extraction
    file.remove(temp_file)
    
    return(dt)
  })
  
  # Combine event data from all radii for this location
  dt_ws <- rbindlist(dt_list, use.names = TRUE, fill = TRUE)
  if (nrow(dt_ws) == 0) next
  
  # Append this location's data to the overall list
  all_data_list[[length(all_data_list) + 1]] <- dt_ws
}

# Combine all long-format data across locations into a single data.table
all_data <- rbindlist(all_data_list, use.names = TRUE, fill = TRUE)

###############################################################################
#                             Output Saving                                   #
###############################################################################
# Save the long-format data to CSV and Parquet
fwrite(all_data, output_csv)

# Create pivot tables for each location (each as its own sheet)
pivot_tables_by_location <- list()
unique_locations <- unique(all_data$loc_idx)
for (loc in unique_locations) {
  # Create pivot table for the current location
  pivot_loc <- dcast(
    all_data[loc_idx == loc, ],
    storm_name + storm_year + storm_id ~ paste0("Radius_",radius_ID),
    value.var = "wind_speed",
    fill = NA
  )
  # Determine the last radius column name
  last_radius_col <- tail(names(pivot_loc), n = 1)
  # Order the pivot data in descending order based on the wind speed in the last radius
  pivot_loc <- pivot_loc[order(-get(last_radius_col))]
  
  sheet_name <- paste0("loc_idx_", loc)
  pivot_tables_by_location[[sheet_name]] <- pivot_loc
}


###############################################################################
#                      Excel Output with openxlsx                             #
###############################################################################
# Create a new workbook
wb <- createWorkbook()

# Add pivot table sheets for each location first
for (sheet_name in names(pivot_tables_by_location)) {
  addWorksheet(wb, sheet_name)
  writeData(wb, sheet = sheet_name, x = pivot_tables_by_location[[sheet_name]])
}

# Add the "meta" sheet as the last sheet
addWorksheet(wb, "meta")

# Write meta_data to the "meta" sheet starting at cell A1
if (!is.null(meta_data)) {
  writeData(wb, sheet = "meta", x = meta_data, startRow = 1, startCol = 1, colNames = TRUE)
} else {
  writeData(wb, sheet = "meta", x = data.table("No meta data captured"), startRow = 1, startCol = 1)
}

# Write locations data starting at row 4 (with header in row 4)
writeData(wb, sheet = "meta", x = locations, startRow = 4, startCol = 1, colNames = TRUE)

# Save the workbook
saveWorkbook(wb, file = output_xlsx, overwrite = TRUE)

print("Processing historical tracks complete! Results saved in the 'results' folder.")

