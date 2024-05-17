###############
# Species accumulation curve of GBIF occurence data for bees in and around UBCBG
# Terrell Roulston
# May 16, 2024
###############

# make sure all libs are installed
library(rgbif) # access GBIF data
library(tidyverse) # data manipulation and grammar
library(iNEXT) # species accumulation curve

# requires a FREE GBIF account
# enter user info
user='username'
pwd='password123'
email='johndoe@gmail.com'

# this code pulls the unique GBIF taxon keys for your species of interest
gbif_taxon_keys <- 
  c('Apidae', 'Halictidae', 'Andrenidae', 'Megachilidae', 'Colletidae', 'Melittidae') %>% # the 6 bee families in BC
  name_backbone_checklist()  %>% # match to backbone
  filter(!matchType == "NONE") %>% # get matched names
  pull(usageKey) 

# create the occurrence data pull request
occ_download(
  pred_in("taxonKey", gbif_taxon_keys),
  pred_in("basisOfRecord", c('PRESERVED_SPECIMEN','HUMAN_OBSERVATION','OBSERVATION','MACHINE_OBSERVATION')),
  pred("country", "CA"),
  pred('geometry', 'POLYGON((-123.27631 49.23986,-123.22736 49.23986,-123.22736 49.2833,-123.27631 49.2833,-123.27631 49.23986))'),  
  pred("hasCoordinate", TRUE),
  format = "SIMPLE_CSV",
  user=user,pwd=pwd,email=email
)

# run this before you run the get line to ensure that you dont create a fatal error
occ_download_wait('0019233-240506114902167')

ubc_bee <- occ_download_get('0019233-240506114902167') %>%
  occ_download_import() # dont push data to git

unique(ubc_bee$species) # the unique species names
length(unique(ubc_bee$species)) # number of unique species


# create a vector of species abundances, their identies do not matter
ubc_bee_rare <- ubc_bee %>% 
  filter(species != '') %>% 
  group_by(species) %>% 
  summarise(n = n()) %>% 
  select(n) %>% 
  unlist() %>% 
  as.numeric()

# calculate species accumulation
out <-iNEXT(ubc_bee_rare,
            q = 0,
            datatype = "abundance",
            se = T,
            conf = 0.95,
            endpoint = 2000,
            knots = 80)

#return the 'out' object  to get more information on accumulation results
print(out$AsyEst)

# plot species accumulation curve
ggiNEXT(out, type = 1, se = T, facet.var="None", grey = T) 

