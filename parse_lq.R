#Require rvest, magrittr, and stringr package for use in analysis#
library(rvest)
library(stringr)
library(magrittr)

#Load files from local directory#
files = dir("data/lq",pattern = "*.html",full.names = TRUE)

#Find total number of files#
l = length(files)

#Initialize address, location, name, and room vectors based on length of files#
addr = rep(NA,l)
loc = rep(NA,l)
name = rep(NA,l)
room = rep(NA,l)

#Iterate across HTML Files and pull La Quinta specific information#
for (i in 1:length(files))
{
  
  #Read HTML of i'th file#
  html <- read_html(files[i])
  
  #Get address, phone, and fax number for each LQ Location#
  addr[i] <- html_nodes(html, ".hotelDetailsBasicInfoTitle p") %>% 
            html_text()
  
  #Get latitude and longitude
  loc[i] <- html_nodes(html, ".minimap") %>% 
           html_attr("src")
  
  #Get Names of each LQ Location#
  name[i] <- html_nodes(html, "h1") %>% 
            html_text()
  
  #Get hotel size (# of rooms)
  room[i] <- html_nodes(html, ".hotelFeatureList li:nth-child(2)") %>% 
            html_text()
  
}

#Delete the space and line break#
addr=unlist(addr)
space_pattern = "\\n {2,}"
addr1 = str_replace_all(addr,space_pattern,"")

#Get the full address#
add_pattern = "^.+[0-9]{5}"
address = str_extract(addr1, add_pattern)

#Get the phone number#
phone_pattern = "Phone: 1-[1-9][0-9]{2}-[0-9]{3}-[0-9]{4}"
number_pattern = "1-[1-9][0-9]{2}-[0-9]{3}-[0-9]{4}"
phone = str_extract(addr1, phone_pattern) %>%
        str_extract(., number_pattern)

#Get the fax number#
fax_pattern = "Fax: 1-[1-9][0-9]{2}-[0-9]{3}-[0-9]{4}"
fax = str_extract(addr1, fax_pattern) %>%
      str_extract(., number_pattern)

#Get the state info#
state_pattern = "[,][ ][A-Z]{2}[ ]"
state = str_extract(addr1, state_pattern) %>%
        str_extract("[A-Z]{2}")

#Remove unnecessary characters from location node#
loc_pattern = "[-]?[0-9]{2,}.[0-9]{2,},[-]?[0-9]{2,}.[0-9]{2,}"
location = str_extract(loc, loc_pattern)

#Get latitude from location#
lat = str_extract(location,"^[-]?[0-9]+.[0-9]+") %>% as.numeric() %>% round(4)

#Get longtitude from location#
long = str_extract(location,"[-]?[0-9]+.[0-9]+$") %>% as.numeric() %>% round(4)

#Get the hotel size (rooms)
room_pattern = "[0-9]+"
room = str_extract(room, room_pattern) %>% as.integer()

#Construct the data frame
d = rbind(state, name, address, phone, fax, lat, long, room)
dd = data.frame(t(d))
dd = dd[order(dd$state),]
rownames(dd) = 1:l

#Save completed data frame in data/lq as an Rdata file#
save(dd, file = "data/lq.Rdata")

rownames(dd) = 1:l

#Save completed data frame in data/lq as an Rdata file#
save(dd, file = "data/lq.Rdata")
