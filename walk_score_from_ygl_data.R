library(openxlsx)
source("walk_score_utils.R")

df <- readRDS("ygl_data.Rds")
df[, "Walk Score"] <- NA
for(i in 1:nrow(df)) {
  df$Address[i]
}

df$Address_Only <- get_address_only(df$Address)

df$Address_for_URL <- sapply(strsplit(df$Address, ", "), function(x) {
  return(paste(gsub(pattern = "[\\.]*[,]*$", replacement = "", x = x[1]),
               extract_city(x[length(x)]), "MA", sep = ", "))
})
df$Address_for_URL <- gsub(pattern = ",", replacement = "",
                           x = gsub(pattern = " ", replacement = "%20", x = df$Address_for_URL))
walkscore_API_key <- readLines("walkscore_API_key.txt")
url <- paste0("https://api.walkscore.com/score?format=json&address=", df$Address_for_URL[1],
              "&wsapikey=", walkscore_API_key)
