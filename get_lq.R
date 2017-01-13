#Require rvest, magrittr, and stringr package for use in analysis#
library(rvest)
library(stringr)
library(magrittr)

#Read the state list from lq_states csv file#
s <- read.csv("lq_states.csv",header=FALSE)

#Pull vector of first column#
states <- s$V1

#Set base url#
base_url <- "http://www.lq.com"

#Set listing page url piece#
listing_page <- "/en/findandbook/hotel-listings.html"

#Read full listings HTML file from web page and set value in variable listings#
listings <- read_html(paste0(base_url, listing_page))

#Function to download HTML file based on state list#
get_state_hotels <- function(html, states, base_url, out_dir = "data/lq/")
{
  
  #Create data/lq/ directory if not created yet#
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  #Pull hotels out of HTML listing file#
  hotels <- html_nodes(html, "#hotelListing a")
  
  #Iterate across states in state vector#
  for (state in states)
  {
    
    # Find the start of a state's hotels by finding its name in the node text
    # Use '+2' to skip the State and Back to Top anchor tags#
    start <- 2 + which(html_text(hotels) %>% 
                      str_trim() %in% 
                      paste("Hotels in", state))
    
    #Stop if the length of start is not equal to 1#
    stopifnot(length(start) == 1)
    
    #Find URL Attribute for each hotel#
    urls <- html_attr(hotels, "href")
    
    #Find URL Indices which are 'NA'#
    label_index = which(is.na(urls))
    
    #Find End of state's hotels by using label_index value to find the min
    end = label_index[label_index > start] %>% min() - 1
    
    #Iterate across all URLs found within the state#
    for (url in urls[start:end])
    {
      
     #Download HTML file to destination directory#
     download.file(paste0(base_url,url),
                    destfile = paste0(out_dir,basename(url)),
                    quiet = TRUE)
      Sys.sleep(5)
    }
  }
}

#Download files for all hotels #
get_state_hotels(listings, states, base_url, out_dir = "data/lq/")
