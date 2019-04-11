library(tidyverse)
library(here)
library(glue)
library(zeallot)

# paths
data_csv      <- here("app/data/KFM_1mQuadrat_Summary_1982-2017.txt")
spp_csv       <- here("app/data/KFM_SpeciesName.txt")
data_spp_rds  <- here("app/data/KFM_1mQuadrat_Summary_1982-2017_SpeciesName.rds")

if (!file.exists(data_spp_csv)){
  
  # This table is needed to get the sub categories of species such as adult, juvinile
  sppNames <- read_csv(spp_csv)
  
  d <- read_csv(
    data_csv, 
    col_types = cols(SurveyDate = col_datetime(format = "%m/%d/%Y %H:%M:%S"))) %>%
    # Join the table by sci name and common name to get AlternateTaxonName
    left_join(
      sppNames %>% 
        select(-Species), 
      by=c("ScientificName", "CommonName")) %>%
    filter(IslandCode != "CL") %>% # remove San Clemente
    mutate(SurveyDate = lubridate::date(SurveyDate))
  
  write_rds(d, data_spp_rds)
} else {
  d <- read_rds(data_spp_rds)
}

d <- d %>% 
  group_by(island = IslandName, species = AlternateTaxonName) %>% 
  summarize(
    n_records = n()) %>% 
  ungroup()
#View(d)  

make_page <- function(i){ # i=39
  
  island  <- d$island[i]
  species <- d$species[i]
  
  fstr <- function(s){
    s %>% 
      str_replace_all(" ", "_") %>% 
      str_replace_all("/", "_")
  }
  html    <- here(glue("docs/{fstr(island)}-{fstr(species)}.html"))
  message(glue("{species} at {island} -> \n  {html}"))

  rmarkdown::render(
    input       = "_page_template.Rmd",
    params      = list(
      island  = island, 
      species = species),
    output_file = html)
}

#walk(1:nrow(d), make_page)
walk(39:nrow(d), make_page)
