###############################################################################
# API Authentication Script
#
# This script authenticates with the ReAsk API to obtain an access token.
# It uses your username and password to send a POST request to the token endpoint.
# The returned JSON is parsed, and the access token is extracted.
# Two sets of headers are constructed:
#  - metryc_headers
#  - deepcyc_headers
#
# Note:
#   - Replace "username" and "password" with your actual credentials.
#   - If you have a defined 'product_version' variable, it will be included in metryc_headers.
###############################################################################

# Load necessary libraries (make sure they are installed first)
library(httr)      # For sending HTTP requests
library(jsonlite)  # For parsing JSON responses

# Define the URL of the authentication endpoint for token retrieval
api_url_token <- "https://api.reask.earth/v2/token"

# Send a POST request with your credentials to obtain the access token.
# Replace "username" and "password" with your actual login details.
resp <- POST(api_url_token, body = list(username = "username", password = "password"))

# Convert the raw response content (bytes) into a character string
json_cont <- rawToChar(resp$content)

# Parse the JSON response into an R list
json <- fromJSON(json_cont)

# Extract the access token from the parsed JSON object
auth_token <- json$access_token

# Construct the headers for metryc endpoints.
metryc_headers <- c(
    'accept' = 'application/json',
    'product-version' = metryc_product_version,
    'Authorization' = paste("Bearer", auth_token)
  )

# Construct the headers for deepcyc endpoints.
deepcyc_headers <- c(
  'accept' = 'application/json',
  'product-version' = deepcyc_product_version,
  'Authorization' = paste("Bearer", auth_token)
)


