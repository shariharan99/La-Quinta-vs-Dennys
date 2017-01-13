#Require stringr, rvest, and magrittr packages for use in analysis#
require(stringr)
require(rvest)
require(magrittr)

#Download files from data/dennys/ directory created in get_dennys script#
files <- dir("data/dennys", pattern = "*.xml", full.names = TRUE)

#Initialize Data Frame list#
loc.list <- list(NA,NA,NA,NA)

#Loop across all files in data/dennys/ directory#
for (i in 1:length(files))
{
  
  #Pull Longitude from XML file and round to 4 digits#
  Latitude <- read_html(files[i]) %>%
    html_nodes("latitude") %>%
    html_text() %>% 
    as.numeric() %>%
    round(4)
  
  #Pull Longitude from XML file and round to 4 digits#
  Longitude <- read_html(files[i]) %>%
    html_nodes("longitude") %>%
    html_text() %>%
    as.numeric() %>%
    round(4)
  
  #Pull City from XML File#
  City <- read_html(files[i]) %>%
    html_nodes("city") %>%
    html_text()
  
  #Pull State from XML File#
  State <- read_html(files[i]) %>%
    html_nodes("state") %>%
    html_text()
  
  #Pull Zip Code from XML File#
  Zip <- read_html(files[i]) %>%
    html_nodes("postalcode") %>%
    html_text()
  
  #Pull Country from XML File#
  Country <- read_html(files[i]) %>%
    html_nodes("country") %>%
    html_text()
  
  #Create Data Frame of Values above and save as first node in list#
  loc.list[[i]] <- data.frame(Latitude, Longitude, City, 
                             State, Zip, Country)
  
}

#Bind all data frames into a larger data frame#
loc.df <- rbind(loc.list[[1]], loc.list[[2]], loc.list[[3]], loc.list[[4]])

#Remove all Dennys not in the United States and remove duplicate values#
true.loc.df <- unique(loc.df[-which(loc.df[,6] != "US"),])

#Save Data Frame as an .Rdata file in specified directory#
save(true.loc.df, file = "data/dennys.Rdata")
