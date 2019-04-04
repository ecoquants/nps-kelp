library(tidyverse)
library(plotly)
library(shiny)
library(glue)
library(cowplot)
library(here)
here <- here::here

# setwd(here("app"))
source("functions.R")

# paths
data_csv <- "data/KFM_1mQuadrat_Summary_1982-2017.txt"
spp_csv  <- "data/KFM_SpeciesName.txt"

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

species <- d %>% 
  filter(SurveyYear == max(d$SurveyYear)) %>% 
  distinct(AlternateTaxonName) %>% 
  arrange(AlternateTaxonName) %>% 
  pull(AlternateTaxonName)

islands <- sort(unique(d$IslandName))