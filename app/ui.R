shinyUI(fluidPage(
  
  titlePanel("NPS Kelp Forest Monitoring"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "sel_island", "Island",
        islands, multiple=T),
      selectInput(
        "sel_species", "Species",
        species)),
    
    mainPanel(
      plotlyOutput("myplot")
    )
  )
))
