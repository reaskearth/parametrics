###############################################################################
# API Authentication Script
#
# This script authenticates with the ReAsk API to obtain an access token.
# It uses your username and password to send a POST request to the token endpoint.
# The returned JSON is parsed, and the access token is extracted.
# The token is then combined with additional headers for subsequent API requests.
#
# Note:
#   - Replace "username" and "password" with your actual credentials.
#   - If you have a defined 'product_version' variable, it will be included in the headers.
###############################################################################

# Load necessary libraries (make sure they are installed first)
library(httr)     # For sending HTTP requests
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

# Construct the headers for subsequent API requests.
# If 'product_version' is defined, include it in the headers; otherwise, only include the token.
if (exists("product_version")) {
  headers <- c(
    'accept' = 'application/json',
    'product-version' = product_version,
    'Authorization' = paste("Bearer", auth_token)
  )
} else {
  headers <- c(
    'accept' = 'application/json',
    'Authorization' = paste("Bearer", auth_token)
  )
}
