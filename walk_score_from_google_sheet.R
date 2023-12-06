library(openxlsx)
library(walkscoreAPI)

walkscore_API_key <- readLines("walkscore_API_key.txt")
get_walk_score <- function(address, lat, lon) {
  url <- paste0("https://api.walkscore.com/score?format=json&address=", address,
                "&lat=", lat, "&lon=", lon,
                "&wsapikey=", walkscore_API_key)
  return(httr::GET(url, httr::accept_json()))
}

get_transit_score <- function(lat, lon, city, state) {
  url <- paste0("https://transit.walkscore.com/transit/score/?lat=", lat,
                "&lon=", lon, "&city=", city, "&state=", state,
                "&wsapikey=", walkscore_API_key)
  return(httr::GET(url, httr::accept_json()))
}

first_element <- function(x) {
  return(x[1])
}

redfin_data <- openxlsx::read.xlsx(xlsxFile = "Data/Apartment.xlsx", sheet = "Consolidated", startRow = 2)
redfin_data$Address_Only <- sapply(strsplit(
  sapply(strsplit(x = gsub(
    x = redfin_data$Address,
    pattern = "\\.",
    replacement = " "),
    split = " Unit"), first_element
  ), split = " \\#"), first_element
)

redfin_data$Address_for_URL <- gsub(
  x = paste(
    redfin_data$Address_Only,
    redfin_data$City,
    redfin_data$State
  ),
  pattern = " ",
  replacement = "%20"
)

# Walk score
res <- walkscoreAPI::getWS(redfin_data$Longitude[3], redfin_data$Latitude[3], walkscore_API_key)
res$walkscore
res <- get_walk_score(address = redfin_data$Address_for_URL[3], lat = redfin_data$Latitude[3], lon = redfin_data$Longitude[3])
httr::content(res)

for(i in 1:nrow(redfin_data)) {
  if(is.na(redfin_data$Walk.score[i])) {
    res <- walkscoreAPI::getWS(redfin_data$Longitude[i], redfin_data$Latitude[i], walkscore_API_key)
    redfin_data$Walk.score[i] <- res$walkscore
  }
}

# Transit score
# res <- walkscoreAPI::getTS(redfin_data$Longitude[3], redfin_data$Latitude[3],
#                            redfin_data$City[3], state = redfin_data$State[3],
#                            walkscore_API_key)
# res <- get_transit_score(lat = redfin_data$Latitude[3], lon = redfin_data$Longitude[3],
#                          city = redfin_data$City[3], state = redfin_data$State[3])
# httr::content(res)

# Other
# walkscoreAPI::networkSearch(redfin_data$Longitude[3], redfin_data$Latitude[3], walkscore_API_key)
# walkscoreAPI::walkshed(redfin_data$Longitude[3], redfin_data$Latitude[3], walkscore_API_key)
