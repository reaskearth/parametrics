###############################################################################
#  Author: David Schmid, Global Head of Data Products
#  Email: david@reask.earth
#
#  Description:
#    This script retrieves probabilistic location-level wind event data from DeepCyc
#    via the Reask API, processes CSV responses to extract key metrics, constructs a pivot table,
#    and saves the results in CSV and Parquet formats. It also extracts and saves metadata.
#
# Dependencies:
#   - API_WaL_Master.R: defines parameters
#   - Libraries: data.table, arrow, httr, here
#   - Input: locations.csv (CSV with at least "lat" and "lon" columns)
###############################################################################

###############################################################################
#                           User Input Parameterisation                       #
###############################################################################
# Modify these default parameters if necessary:
product_version                <- "DeepCyc-2.0.7"
api_url                        <- "https://api.reask.earth/v2/deepcyc/tcwind/events"
agency                         <- "USA" # USA, BOM (USA is NHC, CPHC and JTWC)

# Output file names:
output_pivot_csv               <- "results/deepcyc_tcwind_events_pivot.csv"
output_long_csv                <- "results/deepcyc_tcwind_events_long.csv"
output_parquet                 <- "results/deepcyc_tcwind_events_pivot.parquet"
output_meta_csv                <- "results/deepcyc_tcwind_events_meta.csv"

# Set working directory relative to the repository root and load API authentication
# (Make sure you have copied your API_Authentication.R into the repository root)
source(here("API_Authentication.R"))


###############################################################################
#                           Main Processing Loop                              #
###############################################################################
# Load locations and determine number of locations
locations   <- fread(here(locations_file))
num_locations <- nrow(locations)

# Create an empty list to accumulate the extracted data tables
all_data_list <- list()

# Variable to hold metadata from the first valid CSV response
meta_data <- NULL

# Query parameters template (CSV format) using user-specified parameters
query_params <- list(
  scenario                    = "current_climate",
  time_horizon                = "now",
  wind_speed_units            = wind_speed_units,
  terrain_correction          = terrain_correction,
  wind_speed_averaging_period = wind_speed_averaging_period,
  format                      = "csv",
  agency                      = agency
)

# Start time for progress tracking
start_time <- Sys.time()

# Loop through each location
valid_idx <- 1  # Index for valid data entries
for (i in 1:num_locations) {
  
  # Set latitude and longitude for the current location
  query_params$lat <- locations$lat[i]
  query_params$lon <- locations$lon[i]
  
  # Perform API request with added authentication headers
  response <- GET(api_url, query = query_params, add_headers(headers))
  
  # Check response status: if not 200, log and skip current location
  if (status_code(response) != 200) {
    message("Failed to fetch data for location: ", locations$ID[i])
    next
  }
  
  # Handle authentication expiration
  if (status_code(response) == 401) {
    message("Authentication expired. Refreshing token...")
    source(here("API_Authentication.R"))
    next
  }
  
  # Write API response (CSV) to a temporary file
  csv_file <- tempfile(fileext = ".csv")
  writeBin(content(response, "raw"), csv_file)
  
  # Read CSV data
  csv_data <- fread(csv_file)
  
  # If CSV is empty or missing required columns, remove temp file and skip
  if (nrow(csv_data) == 0 || !("event_id" %in% names(csv_data))) {
    file.remove(csv_file)
    next
  }
  
  # ------------------------------ Filtering ------------------------------
  # Apply wind_speed threshold filtering
  csv_data <- csv_data[wind_speed >= wind_speed_threshold]
  # If no rows remain after filtering, skip this location
  if (nrow(csv_data) == 0) {
    file.remove(csv_file)
    next
  }
  # -------------------------------------------------------------------------
  
  # On the first valid CSV response, capture metadata (all columns except these)
  if (is.null(meta_data)) {
    meta_cols <- setdiff(names(csv_data), c("latitude", "longitude", "cell_id",
                                            "event_id", "year_id", "wind_speed"))
    meta_data <- csv_data[1, ..meta_cols]  # Use first row as representative metadata
  }
  
  # Extract relevant fields for the pivot table (round wind_speed)
  extracted_data <- data.table(
    event_id    = csv_data$event_id,
    year_id     = csv_data$year_id,
    location_idx = i,
    wind_speed  = round(csv_data$wind_speed, 0)
  )
  
  # Add the extracted data to the accumulation list
  all_data_list[[valid_idx]] <- extracted_data
  valid_idx <- valid_idx + 1
  
  # Clean up temporary CSV file
  file.remove(csv_file)
  
  # Display progress (elapsed time in h, m, s)
  elapsed_time    <- as.numeric(Sys.time() - start_time, units = "secs")
  elapsed_hours   <- floor(elapsed_time / 3600)
  elapsed_minutes <- floor((elapsed_time %% 3600) / 60)
  elapsed_seconds <- floor(elapsed_time %% 60)
  
  cat(sprintf("\rProcessed %d/%d locations (Elapsed time: %dh %dm %ds)", 
              i, num_locations, elapsed_hours, elapsed_minutes, elapsed_seconds))
  flush.console()
}

cat("\nProcessing completed. Building pivot table...\n")

# Combine all extracted data into one data.table
all_data <- rbindlist(all_data_list, use.names = TRUE, fill = TRUE)

# Create pivot table: pivot long-format data to wide format
pivot_table <- dcast(
  all_data, 
  event_id + year_id ~ location_idx, 
  value.var = "wind_speed", 
  fill = NA
)

###############################################################################
#                             Output Saving                                   #
###############################################################################
# Ensure the 'results' folder exists; if not, create it
if (!dir.exists("results")) {
  dir.create("results", recursive = TRUE)
}

# Save the pivot table and the long-format data
fwrite(pivot_table, output_pivot_csv)
fwrite(all_data, output_long_csv)
arrow::write_parquet(pivot_table, output_parquet)

# Save the captured metadata (if available)
if (!is.null(meta_data)) {
  fwrite(meta_data, output_meta_csv)
} else {
  message("No metadata was captured from the CSV responses.")
}

cat("\nDeepCyc data extraction completed\n")
