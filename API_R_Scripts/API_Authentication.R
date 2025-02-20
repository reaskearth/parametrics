# Load necessary libraries (install first)
library(httr)
library(jsonlite)

# URL of authentication API endpoint
api_url_token <- "https://api.reask.earth/v2/token"

# enter username and password
resp <- POST(api_url_token, body = list(username = "your_email", password = "your_password"))
json_cont <- rawToChar(resp$content)
json <- fromJSON(json_cont)

auth_token <- json$access_token

  headers <- c(
    'accept' = 'application/json',
    'product-version' = product_version,
    'Authorization' = paste("Bearer", auth_token)
  )
  