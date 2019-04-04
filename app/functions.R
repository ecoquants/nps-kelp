#' Title
#'
#' @param d dataframe with fields: SurveyYear, MeanDensity_sqm, SiteCode
#'
#' @return ggplot object
#' @export
#'
#' @examples
plot_kfm_timeseries <- function(d, sp){
  theme_set(theme_cowplot(font_size=4)) # reduce default font size
  
  #browser()
  
  g <- ggplot(d, aes(x = SurveyYear, y = MeanDensity_sqm, color = SiteCode, linetype = SiteCode)) +
    geom_point(size = 1, alpha = 0.7, show.legend = FALSE)+
    geom_line(size = 0.5, alpha = 0.7) +
    #facet_wrap(~IslandCode, scales = "free_y", ncol = 1) +
    #facet_wrap("LongOrder", scales = "free_y") +
    #facet_grid(rows = vars(IslandCode), scales = "free_y") +
    #geom_smooth(method = loess, size = 0.4) +
    ggtitle(glue("{sp}")) +
    #ylab('Percent Cover')+
    #ylab(expression("#/600 m"^"3"))+
    ylab("Mean density (n/m^2)") #+
    #theme(legend.position = "right", legend.text = element_text(size = 1), legend.title = element_text(size = 9), legend.key.size = unit(1, 'cm')) +
    #guides(color=guide_legend(ncol=1, keyheight = 0.5)) +
    #theme_bw() + 
    #heme(panel.grid.minor.x = element_blank()) +
    #scale_x_continuous(breaks = seq(1980, 2020, by = 1),expand = c(0.01,0.01)) +
    #scale_y_continuous(limits=c(0, max(d$MeanDensity_sqm, na.rm = T) * 1.1)) +
    #scale_colour_manual("Site Code", values = c('Red','green3','Blue','Black','Red','green3','Blue','Black','purple3','darkorange2')) +
    #scale_linetype_manual("Site Code", values = c('solid','solid','solid','solid','dashed','dashed','dashed','dashed','solid','solid')) + 
    #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1), axis.title.x = element_blank()) + 
    #theme(plot.title = element_text(size = 10, hjust = 1))
  ggplotly(g)
}