first_element <- function(x) {
  return(x[1])
}

get_address_only <- function(addresses) {
  addresses <- sapply(strsplit(
    sapply(strsplit(x = gsub(
      x = addresses,
      pattern = "\\.",
      replacement = " "),
      split = " Unit"), first_element
    ), split = " \\#"), first_element
  )
  addresses <- gsub(pattern = "[\\ ]*[,]*$", replacement = "", x = addresses)
  return(addresses)
}

extract_city <- function(vals) {
  starts <- stringr::str_locate(vals, "\\(")[, 1]
  stops <- stringr::str_locate(vals, "\\)")[, 1]
  idxs <- which(!is.na(starts))
  vals[idxs] <- substr(vals[idxs], starts[idxs] + 1, stops[idxs] - 1)
  return(vals)
}

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

