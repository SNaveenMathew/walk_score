library(openxlsx)
library(walkscoreAPI)
source("walk_score_utils.R")

walkscore_API_key <- readLines("walkscore_API_key.txt")

redfin_data <- openxlsx::read.xlsx(xlsxFile = "Data/Apartment.xlsx", sheet = "Consolidated", startRow = 2)
redfin_data$Address_Only <- get_address_only(redfin_data$Address)

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
