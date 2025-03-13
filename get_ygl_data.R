library(httr)

ygl_urls <- readLines("ygl_url.txt")
df <- data.frame()
for(ygl_url in ygl_urls) {
  res <- httr::GET(ygl_url)
  ygl_url_base <- substr(x = ygl_url, start = 1, stop = nchar(ygl_url)-1)
  parsed <- XML::htmlTreeParse(httr::content(res), useInternalNodes = T)
  num_pages <- XML::xpathSApply(doc = parsed, path = "//*/div[@class='counter']", XML::xmlValue)
  num_pages <- as.integer(gsub(pattern = "[0-9]* of ", replacement = "", x = num_pages))
  
  for(i in 1:num_pages) {
    print(i)
    temp_df <- data.frame()
    ygl_url <- paste0(ygl_url_base, i)
    res <- httr::GET(ygl_url)
    parsed <- XML::htmlTreeParse(httr::content(res), useInternalNodes = T)
    tmp <- xpathSApply(doc = parsed,
                       path = "//*/div[@class='property_item']/div[@class='details']",
                       fun = XML::xmlValue)
    temp_df <- data.frame(t(
      sapply(strsplit(tmp, "\\n"), function(x) {
        x <- gsub("^[\\ ]*|[\\ ]*$", "", x)
        return(x[x!=""])
      })
    ))
    colnames(temp_df) <- c("Price", "Beds", "Baths", "Availability", "Address")
    df <- plyr::rbind.fill(df, temp_df)
  }
}
df$Price <- as.integer(gsub(pattern = "[^0-9]", replacement = "", x = df$Price))
df$Beds <- as.integer(sapply(strsplit(df$Beds, " "), function(x) x[1]))
df$Baths <- as.integer(sapply(strsplit(df$Baths, " "), function(x) x[1]))
df$Availability <- gsub(pattern = "^Available ", replacement = "", x = df$Availability)
df <- unique(df)
saveRDS(df, "ygl_data.Rds")
