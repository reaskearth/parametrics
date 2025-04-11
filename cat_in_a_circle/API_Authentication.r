# Load necessary libraries (install first)
library(httr)
library(jsonlite)

# URL of authentication API endpoint
api_url_token <- "https://api.reask.earth/v2/token"

# enter username and password
resp <- POST(api_url_token, body = list(username = "username", password = "password"))
json_cont <- rawToChar(resp$content)
json <- fromJSON(json_cont)

auth_token <- json$access_token

# Check if product_version is defined
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
