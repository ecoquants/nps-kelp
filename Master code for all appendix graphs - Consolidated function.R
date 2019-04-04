# Order by species number, lower number, lower complexity/taxanomic ranking

# Species with null values in current year (2017) do not need to be graphed, otherwise pull species from data sheets every year.

# enter year, based on year, exlcude species with null values in graphs up to that year

# Two tables will need to be linked:
#   Graphing by sci name as title. Some spp have adult and juvy.
#   Need to link the data


# Thanks to Tom Philippi for the cowplot suggestion on how to make a separate legend
# for each island graph
# https://stackoverflow.com/questions/14840542/place-a-legend-for-each-facet-wrap-grid-in-ggplot2

#Install packages (only needs to be done once)
# install.packages("readr")
# install.packages("ggplot2")
# install.packages("lubridate")
# install.packages("glue")
# install.packages("cowplot")
# install.packages('dplyr')
#Load packages (must be done every time R starts up)
library(readr)
library(ggplot2)
library(lubridate)
library(glue)
library(cowplot)
library(dplyr)
library(here)
here <- here::here

#set the working directory
#setwd("C:/Users/RRudolph/Documents/R Projects/KFM")
#setwd("/Users/bbest/github/nps-kelp")
#dir_data <- "/Users/bbest/Gdrive Ecoquants/projects/nps-ecoquants/kelp-forest/KFM_Summary_Tables"
dir_data <- here("app/data")

# CHANGE THESE VARIABLES
dataTable <- file.path(dir_data, "KFM_1mQuadrat_Summary_1982-2017.txt")
currentYear <- 2017
island <- "CL"
# This table is needed to get the sub categories of species such as adult, juvinile
sppNames <- read_csv("KFM_SpeciesName.txt")

# Main data table needed to make the graphs
inTable <- read_csv(dataTable, 
                    col_types = cols(SurveyDate = col_datetime(format = "%m/%d/%Y %H:%M:%S")))

# Join the table by sci name and common name to get AlternateTaxonName
inTable <- inTable %>%
  left_join(sppNames %>% select(-Species), by=c("ScientificName", "CommonName")) %>%
  # Remove anything that is San Clemente
  # TODO: check want to remove San Clemente?
  filter(IslandCode != island) %>%
  mutate(SurveyDate = lubridate::date(SurveyDate))

#str(inTable)


# Create function to generate the graphs
generate_graphs <- function(inDF, inLevels, prefix, currentYear){
  
  # inDF = inTable
  # inLevels = c("San Miguel Island", "Santa Rosa Island","Santa Cruz Island", "Anacapa Island",  "Santa Barbara Island")
  # prefix = "1mQuadrat"

  # Only get a list of species that are from the most current year (such as 2017)
  inTable_year <- inDF %>%
    filter(SurveyYear == currentYear)
  
  #inDF$IslandName <- factor(inDF$IslandName, levels=inLevels)
  
  species <- unique(inTable_year$AlternateTaxonName)
  i <- 1
  for (spp in species) { # spp = species[1]
    species_count <- length(species)
    
    print(glue("Generating graph for: {spp}, {i} of {species_count}"))
    
    print("Subsetting by species")
    # Subselect just one of the species from the list
    spp_sub <- inDF %>%
      filter( AlternateTaxonName == spp)
    
    # Get the rank for naming the file
    rank <- unique(spp_sub$Species)
    rank <- rank[1]
    
    theme_set(theme_cowplot(font_size=4)) # reduce default font size
    
    print("Making ggList")
    # Use a function to get a list of all the graphs needed to join to make one page of graphs
    ggList <- lapply(split(spp_sub, spp_sub$IslandName), function(i) {
      ggplot(i, aes(x = SurveyYear, y = MeanDensity_sqm, color = SiteCode, linetype = SiteCode)) +
        geom_point(size = 1, alpha = 0.5, show.legend = FALSE)+
        geom_line(size = 0.5, alpha = 0.5)+
        #facet_wrap(~IslandCode, scales = "free_y", ncol = 1) +
        #facet_wrap("LongOrder", scales = "free_y") +
        #facet_grid(rows = vars(IslandCode), scales = "free_y") +
        #geom_smooth(method = loess, size = 0.4) +
        
        ggtitle(glue("{spp}")) +
        #ylab('Percent Cover')+
        #ylab(expression("#/600 m"^"3"))+
        ylab(expression("Mean density/m"^"2"))+
        theme(legend.position = "right", legend.text = element_text(size = 1), legend.title = element_text(size = 9), legend.key.size = unit(1, 'cm')) +
        guides(color=guide_legend(ncol=1, keyheight = 0.5)) +
        theme_bw() + 
        theme(panel.grid.minor.x = element_blank())+
        scale_x_continuous(breaks = seq(1980, 2020, by = 1),expand = c(0.01,0.01)) +
        scale_y_continuous(limits=c(0, max(spp_sub$MeanDensity_sqm) * 1.1)) +
        scale_colour_manual("Site Code", values = c('Red','green3','Blue','Black','Red','green3','Blue','Black','purple3','darkorange2')) +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1), axis.title.x = element_blank()) + 
        theme(plot.title = element_text(size = 10, hjust = 1))+
        scale_linetype_manual("Site Code", values = c('solid','solid','solid','solid','dashed','dashed','dashed','dashed','solid','solid'))
    })
    
    # This is totally screwing up the graph shifting everything down. Can't figure out why.
    # title <- ggdraw() +
    #   draw_label(glue("{spp}"), fontface='plain')
    
    # plot as grid in 1 columns
    print("Plotting with cowplot")
    cowplot::plot_grid(plotlist = ggList,
                       ncol = 1,
                       align = 'v',
                       labels =  levels(inDF$IslandName),
                       label_fontface = "plain",
                       label_size = 12)
    
    # This is needed because some species names have special characters in them
    # and windows wont save file names with those characters in the file name
    print("Renaming species")
    spp_rename <- gsub("(>|/)", "", spp)
    
    # Save the file to disk in the Graphs folder
    print("Saving with ggsave")
    ggsave(filename = glue("Graphs\\{prefix}_{rank}_{spp_rename}.jpg"), 
           plot = last_plot(),
           width = 7.5,
           height = 10,
           units = "in")
    
    i <- i + 1
  }
}

###### All species, no filters
generate_graphs(inTable, c("San Miguel Island", "Santa Rosa Island","Santa Cruz Island", "Anacapa Island",  "Santa Barbara Island"), "1mQuadrat")

##### subset data to just miracle mile and red abalone#####
MM<-subset(inTable, inTable$SiteCode=='MM'& inTable$ScientificName=='Haliotis rufescens')

generate_graphs(MM, c("San Miguel Island"), "Band_Haliotis_rufescens_MM")


######Just red abalone excluding MM#########
Red_abalone<-subset(inTable, inTable$ScientificName=='Haliotis rufescens')

#exclude Miracle Mile
Red_abalone<-subset(Red_abalone, Red_abalone$SiteCode!='MM')
generate_graphs(Red_abalone,c("San Miguel Island", "Santa Rosa Island","Santa Cruz Island", "Anacapa Island",  "Santa Barbara Island"), "Band_Haliotis_rufescens_excluding_MM")


#####RPC articulated coralline algae#####
ACA<-subset(inTable, inTable$CommonName=='articulated coralline algae')

generate_graphs(ACA ,c("San Miguel Island", "Santa Rosa Island","Santa Cruz Island", "Anacapa Island",  "Santa Barbara Island"), "RandomPointContact_Articulated")

######RPC encrusting coralline algae#####
ECA<-subset(inTable, inTable$CommonName=='encrusting coralline algae')

generate_graphs(ECA ,c("San Miguel Island", "Santa Rosa Island","Santa Cruz Island", "Anacapa Island",  "Santa Barbara Island"), "RandomPointContact_Encrusting")
