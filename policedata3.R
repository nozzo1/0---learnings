# Crime Mapping
# Used as a learning tool (c) Chris Norris and free to use by anyone
# Police Data from public sources
install.packages(c("mapproj", "maps", "jsonlite", "ggmap", "colorspace","Rcpp"))
library(mapproj);library( maps);library(jsonlite);library(ggmap);library(colorspace)
require(ggplot2); require(sp); ## This needs tidying up.

# Setup
baseurl <- "https://data.police.uk/api/crimes-street/all-crime?lat=52.091983&lng=-0.835741&date=" #Castlethorpe
mappostcode <- "mk19 7hf" #castlethorpe
maptitle <- "Castlethorpe"
# baseurl <- "https://data.police.uk/api/crimes-street/all-crime?lat=52.0417200&lng=-0.7558300&date=" #Milton Keynes
# mappostcode <- "mk9 3nb" #milton keynes
# maptitle <- "Milton Keynes"
# baseurl <- "https://data.police.uk/api/crimes-street/all-crime?lat=51.8199&lng=-0.824&date=" #Aylesbury Honda
# mappostcode <- "hp19 8ed" #Aylesbury
# maptitle <- "Aylesbury"

baseyear  <- "2016"
poldatapages <- list()

#poldata1 are the crime data from all the above
for (i in 1:12) {
  poldata1 <- fromJSON(paste0(baseurl, baseyear, "-0", i), flatten = TRUE)
  message("Retrieving page ", i, " for year ", baseyear, " and month ", i)
  if (length(poldata1) == 0) poldata1 <- data.frame()
  poldatapages[[i+1]] <- poldata1
  }

#flatten poldatapages
poldata1 <- rbind.pages(poldatapages)

#then convert lat lon in to numeric values
poldata1$location.latitude <- as.numeric(as.character(poldata1$location.latitude))
poldata1$location.longitude <- as.numeric(as.character(poldata1$location.longitude))

#store counts of lat lon pairs in poltable1
# then merge the two tables so we end up with the location (lat,lon) count of crimes in polmerge3
poltable1 <- table(poldata1$location.latitude, poldata1$location.longitude)
polmerge3 <- merge(poldata1, poltable1, by.x=c("location.latitude", "location.longitude"), by.y=c("Var1", "Var2"))
polmerge3$tFreq <- as.character(polmerge3$Freq)

# open map and plot
crimemap = qmap(mappostcode, zoom = 15, maptype='hybrid', size = c(1024, 768)) +
  geom_point(data = polmerge3, aes(x = location.longitude, y = location.latitude, size = Freq), color = "red") +
  geom_text(data = polmerge3, aes(x = location.longitude, y = location.latitude, label = Freq), size=4, vjust=.5, hjust=0.5, color = "white") +
  ggtitle(paste(maptitle, "Crime For year", baseyear))
print(crimemap)
