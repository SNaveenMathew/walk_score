library(httr)

link <- "https://www.coldwellbankerhomes.com/new-england/geo_10064425/rentals/kvc-4_1,3628_3,3878_1750,3879_2300/"
res <- httr::GET(link)
parsed <- XML::htmlTreeParse(httr::content(res), useInternalNodes = T)
page_links <- XML::xpathSApply(doc = parsed, path = "//*/ul[@class='propertysearch-results-pager']/*/a")

listings <- XML::xpathSApply(doc = parsed, path = "//*/div[@class='list-items psr-panel']")
listing_panels <- XML::xpathSApply(doc = listings[[1]], path = "//*/div[@class='property-snapshot-psr-panel']")
listing_description <- XML::xpathSApply(doc = listings[[1]], path = "//*/div[@class='prop-info']")
# XML::xpathSApply(doc = listing_panels[[1]], path = "//*/span[@class='property-status-indicator-text']")

street_addresses <- XML::xpathSApply(doc = listing_panels[[1]], path = "//*/span[@class='street-address']", XML::xmlValue)
unit_nums <- XML::xpathSApply(doc = listing_panels[[1]], path = "//*/span[@class='unit-number']", XML::xmlValue)
city_state_zips <- XML::xpathSApply(doc = listing_panels[[1]], path = "//*/span[@class='city-st-zip city-zip-space']", XML::xmlValue)

statuses <- unlist(XML::xpathSApply(doc = listing_description[[1]], path = "//*/div[@class='description-summary']/ul/li", XML::xmlValue))
end_indices <- which(grepl(pattern = "^MLS", x = statuses)) + 1
updates <- statuses[end_indices]
start_indices <- end_indices
start_indices[which(grepl(pattern = "^Update", x = updates))] <- start_indices[which(grepl(pattern = "^Update", x = updates))] + 1
end_indices[which(!grepl(pattern = "^Update", x = updates))] <- end_indices[which(!grepl(pattern = "^Update", x = updates))] - 1
start_indices <- c(1, start_indices[-length(start_indices)])
statuses[start_indices]
statuses[end_indices]
sapply(1:length(start_indices), function(i) statuses[start_indices[i]:end_indices[i]])

prices <- XML::xpathSApply(doc = listing_panels[[1]], path = "//*/div[@class='price-normal']", XML::xmlValue)

XML::xpathApply(doc = listing_description[[1]], path = "//*/div[@class='description-summary']/ul/li", XML::xmlValue)

for(page in page_links) {
  
}