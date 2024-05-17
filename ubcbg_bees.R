library(rgbif) # access GBIF data
library(tidyverse) # data manipulation and grammar
library(iNEXT) # species accumulation curve


user='terrell_roulston'
pwd='BumbleBee#123'
email='terrellroulston@gmail.com'


gbif_taxon_keys <- 
  c('Apidae', 'Halictidae', 'Andrenidae', 'Megachilidae', 'Colletidae', 'Melittidae') %>% # the 6 bee families in BC
  name_backbone_checklist()  %>% # match to backbone
  filter(!matchType == "NONE") %>% # get matched names
  pull(usageKey) 

occ_download(
  pred_in("taxonKey", gbif_taxon_keys),
  pred_in("basisOfRecord", c('PRESERVED_SPECIMEN','HUMAN_OBSERVATION','OBSERVATION','MACHINE_OBSERVATION')),
  pred("country", "CA"),
  pred('geometry', 'POLYGON((-123.27631 49.23986,-123.22736 49.23986,-123.22736 49.2833,-123.27631 49.2833,-123.27631 49.23986))'),  
  pred("hasCoordinate", TRUE),
  format = "SIMPLE_CSV",
  user=user,pwd=pwd,email=email
)


occ_download_wait('0019233-240506114902167')

ubc_bee <- occ_download_get('0019233-240506114902167') %>%
  occ_download_import()

unique(ubc_bee$species) # the unique species names
length(unique(ubc_bee$species)) # number of unique species


ubc_bee_rare <- ubc_bee %>% 
  filter(species != '') %>% 
  group_by(species) %>% 
  summarise(n = n()) %>% 
  select(n) %>% 
  unlist() %>% 
  as.numeric()

out <-iNEXT(ubc_bee_rare,
            q = 0,
            datatype = "abundance",
            se = T,
            conf = 0.95,
            endpoint = 2000,
            knots = 80)

DataInfo(ubc_bee_rare, datatype = 'abundance')

ggiNEXT(out, type = 1, se = T, facet.var="None", grey = T) 

