#Require stringr, rvest, and magrittr packages for use in analysis#
require(stringr)
require(rvest)
require(magrittr)

#Initialize where2getit API unique key#
key <- "6B962D40-03BA-11E5-BC31-9A51842CA48B"

#Initialize limit of 1000. All where2getit searches cap out at 1000 Locations regardless#
limit <- 1000

#Function to take in certain values and download a file of the html values to a local
#directory as an xml file#
#Inputs:
#dest - destination directory for downloaded files. Must be in /data/dennys/
#key - where2getit unique key which changes every few weeks
#lat - Specified Latitude
#long - Specified Longitude
#radius - radius around the latitude/longitude to search for
#limit - limit of number of dennys to output
#
#Output:
#An xml file with all Dennys locations based on input values#
#
get_dennys_locs <- function(dest, key, lat, long, radius, limit)

{
  
  #Concatenate url to download xml files from based on input values#
  url <- paste0(
    "https://hosted.where2getit.com/dennys/responsive/ajax?&xml_request=",
    "<request>",
    "<appkey>",key ,'</appkey><formdata id="locatorsearch">',
    "<dataview>store_default</dataview>",
    "<limit>",limit,"</limit>",
    "<order>rank,_distance</order>",
    "<geolocs><geoloc><addressline></addressline>",
    "<longitude>",long,"</longitude>",
    "<latitude>",lat,"</latitude>",
    "<country>US</country></geoloc></geolocs><stateonly>1</stateonly>",
    "<searchradius>",radius,"</searchradius></formdata></request>")
  
    #Download the html file based on url and destination directory inputed above#
    download.file(url,destfile = dest, method = "wget")
}

#Read location file which contains 5 latitude and longitudes around the United States#
locs = read.csv("dennys_coords.csv",header = FALSE)

#Create data/dennys/ directory to hold xml files#
dir.create("data/dennys/",recursive = TRUE,showWarnings = FALSE)

#Iterate across each row in the location file and extract values#
for(i in 1:nrow(locs))
{
  
  #Extract longitude, latitude, and radius values from location file#
  long <- locs[i,1]
  lat <- locs[i,2]
  radius <- locs[i,3]
  
  #Create new destination file for each row in location file#
  dest = paste0("data/dennys/",i,".xml")
  
  #Call function based on those values, a destination directory, and a specified limit#
  get_dennys_locs(dest, key, lat, long, radius, limit)
}
