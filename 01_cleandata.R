library('plyr')
library('dplyr')
library('tidyr')
library('stringr')
library('zipcode')
library('noncensus')
library('rgeos')
library('sp')

setwd('~/Library/Mobile Documents/com~apple~CloudDocs/Projects/ufo')

##### other datasets #####

## demographics
# read in state-level total population data
data('states')

state.pop <- read.csv('data/nst-est2016-alldata.csv', stringsAsFactors = F)
names(state.pop) <- tolower(names(state.pop))
state.pop <- state.pop %>% select(region, division, name, census2010pop, grep("popestimate", names(state.pop))) %>% filter(name != 'Puerto Rico')
state.pop <- merge(state.pop, states %>% select(-population), by = 'name')

# read in state-level urban/rural population data
state.rural <- read.csv('data/PctUrbanRural_State.csv', stringsAsFactors = F)
names(state.rural) <- tolower(names(state.rural))
state.rural <- state.rural %>% filter(statename != 'Puerto Rico')
state.rural <- merge(state.rural, states %>% select(-population), by.x = 'statename', by.y = 'name')

# read in county-level urban/rural population data
county.rural <- read.csv('data/PctUrbanRural_County.txt', colClasses = c('numeric', 'character', 'character', 'character', rep('numeric', 22)), stringsAsFactors = F)
names(county.rural) <- tolower(names(county.rural))
county.rural <- county.rural %>% filter(statename != 'Puerto Rico')
county.rural$fips <- as.numeric(paste0(county.rural$state, county.rural$county))

# read in county-level median household income data
county.income <- read.csv('data/ACS_15_5YR_B19013_with_ann.csv', stringsAsFactors = F)
names(county.income) <- tolower(names(county.income))
county.income <- county.income %>% select(-hd02_vd01)
colnames(county.income)[4] <- 'county.hhinc'

saveRDS(county.income, 'data/countyincome.RDS')

# read in county-level election results
election <- read.csv('data/US_County_Level_Presidential_Results_12-16.csv', stringsAsFactors = F)

# read in county-level population data
county.pop <- read.csv('data/ACS_15_5YR_B01003_with_ann_countypop.csv', stringsAsFactors = F)
colnames(county.pop)[4] <- 'county.pop'
county.pop <- county.pop %>% select(-HD02_VD01)

saveRDS(county.pop, 'data/countypop.RDS')

## airports data
airports <- read.csv('data/airports.txt', header = FALSE, stringsAsFactors = F)
colnames(airports) <- c('id', 'name', 'city', 'country', 'IATA_FAA', 'ICAO', 'lat', 'lon', 'altitude', 'timezone', 'DST', 'Tzdatabase', 'Type', 'Source')

airports <- airports %>% filter(country == 'United States') %>% 
  select(name, city, country, IATA_FAA, lat, lon)

# major airports: large and medium hubs
airports.cats <- read.csv('data/All NPIAS Airports-Table 1.csv', stringsAsFactors = F)
airports.cats <- airports.cats %>% filter(hub == 'L' | hub == 'M') %>% select(state, city, airport, locid, hub)

airports.major <- merge(airports.cats, airports %>% select(lat, lon, IATA_FAA), by.x = 'locid', by.y = 'IATA_FAA', all.x = T)
airports.major <- airports.major %>% filter(state != 'PR')

###### UFO dataset #####
ufo <- read.csv('data/ufo.csv', stringsAsFactors = F)

# create unique id for each event (96244 events as of latest update on Feb 10, 2017)
ufo$id <- row.names(ufo)

# harmonize state abbreviations (50 states + DC)
length(unique((ufo$state)))
table(ufo$state)
ufo$state <- toupper(ufo$state)

# clean up dates
ufo <- ufo %>% 
  separate(date, into = c('event.date', 'event.time'), sep = ' ') # 22 have no date, 1170 have no time

ufo$event.date <- as.Date(ufo$event.date, format = '%m/%d/%y')
ufo$event.year <- as.numeric(format(ufo$event.date, format="%Y"))
ufo$event.month <- format(ufo$event.date, format="%b")
ufo$event.day <- format(ufo$event.date, format="%d")

ufo$posted.date <- as.Date(ufo$posted, format = '%m/%d/%y')
ufo$posted.year <- as.numeric(format(ufo$posted.date, format="%Y"))
ufo$posted.month <- format(ufo$posted.date, format="%b")
ufo$posted.day <- format(ufo$posted.date, format="%d")

# fix early event dates (like 1968 miscoded as 2068)
# note: assuming 1900s but events dates on site (http://www.nuforc.org/webreports/ndxevent.html) indicate a small handful prior to the 1900s
ufo$event.year <- ifelse(ufo$event.year > 2017, ufo$event.year - 100, ufo$event.year) 
ufo$event.date <- as.Date(paste(ufo$event.year, ufo$event.day, ufo$event.month, sep = '-'), "%Y-%d-%b")

ufo$event.dow <- weekdays(ufo$event.date)

# order month names
ufo$event.month <- factor(ufo$event.month, levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), ordered = T)

# extract notes by NUFORC staff
ufo$summary2 <- ufo$summary
ufo <- ufo %>% 
  separate(summary2, into = c('summary2', 'notes'), sep = 'NUFORC Note:')

ufo <- ufo %>% 
  separate(notes, into = c('notes', 'extra'), sep = 'PD')

ufo$hoax <- ifelse(grepl("hoax", ufo$summary, ignore.case=TRUE), 1, 0)
ufo <- ufo %>% select(-summary2, -extra)
ufo$has.note <- ifelse(ufo$hoax == 1 | is.na(ufo$note) == F, 1, 0)

## merge ufo data with state pop
ufo <- merge(ufo, state.pop %>% select(state, name, region = region.y, census2010pop, grep("popestimate", names(state.pop)), state.area.sqmiles = area), by = 'state', all.x = T)
ufo %>% filter(is.na(census2010pop) == T) # all merged

## merge ufo data with state rural
nameVec <- names(state.rural)
nameVec <- gsub('pop','state.pop', nameVec)
nameVec <- gsub('area','state.area', nameVec)

names(state.rural) <- nameVec

ufo <- merge(ufo, state.rural %>% select(-state.x, -statename, -state.area, -region, -capital), by.x = 'state', by.y = 'state.y', all.x = T)

nameVec <- names(ufo)
nameVec <- gsub('popestimate','state.pop', nameVec)
nameVec <- gsub('census2010pop','state.pop2010.census', nameVec)

names(ufo) <- nameVec

## harmonize some city names
ufo$city.new <- ufo$city
ufo$city.new <- gsub('St\\.', 'Saint', ufo$city.new)
ufo$city.new <- gsub('Ft\\.', 'Fort ', ufo$city.new)

ufo$city.new <- ifelse(grepl("New York City", ufo$city, ignore.case=TRUE), 'New York', 
                            ifelse(grepl("Washington", ufo$city, ignore.case=TRUE) & ufo$state == 'DC', 'Washington',
                                   ifelse(grepl("Los Angeles", ufo$city, ignore.case=TRUE), 'Los Angeles',
                                          ifelse(grepl("Lakewood", ufo$city, ignore.case=TRUE) & ufo$state == 'CO', 'Jefferson',
                                                 ifelse(grepl("Winston-Salem", ufo$city, ignore.case=TRUE) & ufo$state == 'NC', 'Winston Salem', ufo$city.new)))))

ufo$city.new <- ifelse(ufo$city.new == 'Fort  Lauderdale', 'Fort Lauderdale',
                       ifelse(ufo$city.new == 'Centennial' & ufo$state == 'CO', 'Arapahoe',
                              ifelse(ufo$city.new == 'Hilton Head', 'Hilton Head Island',
                                     ifelse(ufo$city.new == "Coeur d'Alene", 'Coeur D Alene',
                                            ufo$city.new))))

saveRDS(ufo, 'data/ufo.RDS')

##### getting coordinates #####

# city-state geocode using google maps api for california -- not used
# ufo.recent <- ufo %>% filter(event.year >= 2016 & state == 'CA')
# x <- geocode(paste(ufo.recent$city, ufo.recent$state, 'USA', sep = ', '))
# 
# ufo.recent <- cbind(ufo.recent, x)
# write.csv(ufo.recent, 'files/ufo_ca.csv', row.names = F)

## geocoding - 2016 data
# use zipcode package to match city-state pairs for 2016

data('zipcode')
city.state <- zipcode %>% group_by(city, state) %>% 
  summarise(lat = mean(latitude, na.rm = T), lng = mean(longitude, na.rm = T))

## first, merge by state
ufo.2016 <- ufo %>% filter(event.year == 2016) 
length(ufo.2016$id) # 5194 2016 events
length(unique(ufo.2016$id)) # 5194 2016 events

ufo.2016.matches <- merge(ufo.2016, city.state, by = 'state', all.x = T)

## then, match cities to states
ufo.2016.matches$match <- ifelse(tolower(ufo.2016.matches$city.y) == tolower(ufo.2016.matches$city.new), 1, 0)

ufo.2016.matches <- ufo.2016.matches %>% filter(match == 1) 
ufo.2016.matches %>% group_by(id) %>% summarise(n = n()) %>% filter(n > 1) # duplicate
ufo.2016.matches <- ufo.2016.matches %>% filter(city.y != 'Mccomb')

## matched vs. unmatched
nrow(ufo.2016.matches) # 4596
nrow(ufo.2016) # 5194

ufo.2016 <- merge(ufo.2016, ufo.2016.matches %>% select(id, lat, lng, match), by = 'id', all.x = T)

ufo.2016 %>% filter(is.na(match) == T) %>% group_by(city.new, state) %>% summarise(n = n()) %>% arrange(desc(n)) 

ufo.2016 %>% filter(is.na(lat) == T) %>% summarise(n = n()) # 583 not geocoded

## get fips codes
data(zip_codes)

zip_codes$id <- paste(zip_codes$city, zip_codes$state)

# top fips codes by city-state combo
zips <- zip_codes %>% group_by(id, city, state, fips) %>% 
  summarise(n = n()) %>% arrange(desc(n)) %>%
  ungroup() %>%
  group_by(id) %>%
  slice(1) %>%
  ungroup()

ufo.2016$city.merge <- tolower(ufo.2016$city.new)
zips$city.merge <- tolower(zips$city)
zips <- zips %>% filter(id != 'McComb MS')

ufo.2016 <- merge(ufo.2016, zips %>% select(city.merge, state, fips),
                  by = c('city.merge', 'state'), all.x = T)

ufo.2016 %>% filter(is.na(fips) == T) %>% summarise(n = n()) 
ufo.2016 %>% filter(is.na(fips) == T & is.na(lat) == F) # saint vs. st., of course!
ufo.2016[ufo.2016$id == 49746, ]$fips <- 29169 # one-time hack-y fix
ufo.2016 %>% filter(is.na(fips) == T) %>% summarise(n = n()) # should be 597

## merge in county median household income data
ufo.2016 <- merge(ufo.2016, county.income, by.x = 'fips', by.y = 'geo.id2', all.x = T)
ufo.2016 %>% filter(is.na(county.hhinc) == T & is.na(fips) == F) # unmerged are the places without fips codes

## merge in county election data
ufo.2016 <- merge(ufo.2016, election %>% select(-X, -FIPS), by.x = 'fips', by.y = 'combined_fips', all.x = T)
ufo.2016 %>% filter(is.na(votes_dem_2016) == T & is.na(fips) == F) # unmerged are the places without fips

## merge in county pop
ufo.2016 <- merge(ufo.2016, county.pop %>% select(GEO.id2, county.pop), by.x = 'fips', by.y = 'GEO.id2', all.x = T)
ufo.2016 %>% filter(is.na(county.pop) == T & is.na(fips) == F) # unmerged are the places without fips

# merge in county urban/rural population
nameVec <- names(county.rural)
nameVec <- gsub('pop','county.pop', nameVec)
nameVec <- gsub('area','county.area', nameVec)

names(county.rural) <- nameVec

ufo.2016 <- merge(ufo.2016, county.rural %>% select(-state, -statename, -county), by = 'fips', all.x = T)
ufo.2016 %>% filter(is.na(county.pop_rural) == T & is.na(fips) == F) # unmerged are the places without fips

## calculate distance to nearest major (large or medium hub) airport
ufo.2016.airports <- ufo.2016 %>% filter(is.na(lat) == F)

sp.ufo.2016.airports <- ufo.2016.airports
sp.airports.major <- airports.major
coordinates(sp.ufo.2016.airports) <- ~lng+lat
coordinates(sp.airports.major) <- ~lon+lat

d <- gDistance(sp.ufo.2016.airports, sp.airports.major, byid = T)
min.d <- apply(d, 2, function(x) order(x, decreasing=F)[1])

ufo.2016.airports.dist <- cbind(ufo.2016.airports, airports.major[min.d, ], apply(d, 2, function(x) sort(x, decreasing=F)[1]))

colnames(ufo.2016.airports.dist) <- c(colnames(ufo.2016.airports), 'airport.id', 'airport.state', 'airport.city', 'airport', 'airport.size', 'airport.lat', 'airport.lng', 'dist.airport')

ufo.2016 <- merge(ufo.2016, ufo.2016.airports.dist %>% 
                    select(id, airport.id, airport.state, airport.city, airport, airport.size, airport.lat, airport.lng, dist.airport), by = 'id', all.x = T)

saveRDS(ufo.2016, 'data/ufo_2016.RDS')


