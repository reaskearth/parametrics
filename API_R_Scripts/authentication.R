# Load necessary libraries (install first)
library(httr)
library(jsonlite)
library(configr)

config_file <- paste0(Sys.getenv("HOME"), "/.reask")
if (file.exists(config_file)) {
  config <- read.config(config_file)
  username <- config$default$username
  password <- config$default$password
} else {
  username <- "your_email"
  password <- "your_password"
}

# URL of authentication API endpoint
api_url_token <- "https://api.reask.earth/v2/token"

# enter username and password
resp <- POST(api_url_token, body = list(username = username, password = password))
json_cont <- rawToChar(resp$content)
json <- fromJSON(json_cont)

auth_token <- json$access_token

  headers <- c(
    'accept' = 'application/json',
    'product-version' = product_version,
    'Authorization' = paste("Bearer", auth_token)
  )

