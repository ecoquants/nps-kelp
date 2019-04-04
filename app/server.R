shinyServer(function(input, output) {
  
  get_data <- reactive({
    req(input$sel_island)
    req(input$sel_species)
    
    d %>% 
      filter(
        IslandName         == input$sel_island,
        AlternateTaxonName == input$sel_species)
  })
  
  output$myplot <- renderPlotly({
    
    g <- plot_kfm_timeseries(get_data(), input$sel_species)
    ggplotly(g)
    
  })
  
})
