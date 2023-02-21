#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###############################Install Related Packages #######################
if (!require("shiny")) {
    install.packages("shiny")
    library(shiny)
}
if (!require("leaflet")) {
    install.packages("leaflet")
    library(leaflet)
}
if (!require("leaflet.extras")) {
    install.packages("leaflet.extras")
    library(leaflet.extras)
}
if (!require("dplyr")) {
    install.packages("dplyr")
    library(dplyr)
}
if (!require("magrittr")) {
    install.packages("magrittr")
    library(magrittr)
}
if (!require("mapview")) {
    install.packages("mapview")
    library(mapview)
}
if (!require("leafsync")) {
    install.packages("leafsync")
    library(leafsync)
}
##### data cleaning for health data
health <- read.csv("../data/health_clean_data.csv", stringsAsFactors = FALSE)
plot_data <- read.csv("../data/ggplot_data.csv", stringsAsFactors = FALSE)
plot_wei_data <- read.csv("../data/ggplot_weighted_data.csv", stringsAsFactors = FALSE)
health$date_of_interest <- as.Date(health$date_of_interest)
plot_data$date <- as.Date(plot_data$date)
plot_wei_data$date <- as.Date(plot_wei_data$date)
MN_pop <- 1576876
BX_pop <- 1481409
QN_pop <- 2422938
SI_pop <- 493494
BK_pop <- 2712360
##### data scleaning for payroll data



shinyServer(function(input, output) {
 
 
  ####################### Tab Health ##################
  
  data <- reactive({
    res2020 <- apply(health[health$date_of_interest< "2021-01-01", -1], 
                     2, sum)
    sum_2020 <- data.frame(borough = rep(c("Bronx", "Brooklyn", 
                                           "Manhattan", "Queens", 
                                           "Staten Island"), 3), 
                           total_count = res2020, 
                           type = rep(c("Case", "Death", 
                                        "Hospitalized"), each = 5))
    res2021 <- apply(health[health$date_of_interest < "2022-01-01" 
                            & health$date_of_interest >= "2021-01-01", 
                            -1], 2, sum)
    sum_2021 <- data.frame(borough = rep(c("Bronx", "Brooklyn", 
                                           "Manhattan", "Queens", 
                                           "Staten Island"), 3), 
                           total_count = res2021, 
                           type = rep(c("Case", "Death", 
                                        "Hospitalized"), each = 5))
    res2022 <- apply(health[health$date_of_interest>= "2022-01-01", -1], 
                     2, sum)
    sum_2022 <- data.frame(borough = rep(c("Bronx", "Brooklyn", 
                                           "Manhattan", "Queens", 
                                           "Staten Island"), 3), 
                           total_count = res2022, 
                           type = rep(c("Case", "Death", 
                                        "Hospitalized"), each = 5))
    if ("Unweighted" %in% input$weight) {
      final_data <- plot_data
      bar_2020 <- sum_2020
      bar_2021 <- sum_2021
      bar_2022 <- sum_2022
    }
    if ("Weighted" %in% input$weight) {
      final_data <- plot_wei_data
      bar_2020 <- sum_2020
      bar_2020$total_count <- bar_2020$total_count / 
        rep(c(BX_pop, BK_pop, MN_pop, QN_pop, SI_pop), 3)
      bar_2021 <- sum_2021
      bar_2021$total_count <- bar_2021$total_count / 
        rep(c(BX_pop, BK_pop, MN_pop, QN_pop, SI_pop), 3)
      bar_2022 <- sum_2022
      bar_2022$total_count <- bar_2022$total_count / 
        rep(c(BX_pop, BK_pop, MN_pop, QN_pop, SI_pop), 3)
    }
    if ( "Manhattan" %in% input$borough){
      data = final_data[final_data$borough == "Manhattan", ]
      bar_2020 = bar_2020[bar_2020$borough == "Manhattan", ]
      bar_2021 = bar_2021[bar_2021$borough == "Manhattan", ]
      bar_2022 = bar_2022[bar_2022$borough == "Manhattan", ]
      data_list <- list(data, bar_2020, bar_2021, bar_2022)
      return(data_list)
    }
    if ( "Bronx" %in% input$borough){
      data = final_data[final_data$borough == "Bronx", ]
      bar_2020 = bar_2020[bar_2020$borough == "Bronx", ]
      bar_2021 = bar_2021[bar_2021$borough == "Bronx", ]
      bar_2022 = bar_2022[bar_2022$borough == "Bronx", ]
      data_list <- list(data, bar_2020, bar_2021, bar_2022)
      return(data_list)
    }
    if ( "Brooklyn" %in% input$borough){
      data = final_data[final_data$borough == "Brooklyn", ]
      bar_2020 = bar_2020[bar_2020$borough == "Brooklyn", ]
      bar_2021 = bar_2021[bar_2021$borough == "Brooklyn", ]
      bar_2022 = bar_2022[bar_2022$borough == "Brooklyn", ]
      data_list <- list(data, bar_2020, bar_2021, bar_2022)
      return(data_list)
    }
    if ( "Queens" %in% input$borough){
      data = final_data[final_data$borough == "Queens", ]
      bar_2020 = bar_2020[bar_2020$borough == "Queens", ]
      bar_2021 = bar_2021[bar_2021$borough == "Queens", ]
      bar_2022 = bar_2022[bar_2022$borough == "Queens", ]
      data_list <- list(data, bar_2020, bar_2021, bar_2022)
      return(data_list)
    }
    if ( "Staten Island" %in% input$borough){
      data = final_data[final_data$borough == "Staten Island", ]
      bar_2020 = bar_2020[bar_2020$borough == "Staten Island", ]
      bar_2021 = bar_2021[bar_2021$borough == "Staten Island", ]
      bar_2022 = bar_2022[bar_2022$borough == "Staten Island", ]
      data_list <- list(data, bar_2020, bar_2021, bar_2022)
      return(data_list)
    }
    if ( "All" %in% input$borough) {
      data = final_data
      data_list <- list(data, bar_2020, bar_2021, bar_2022)
      return(data_list)
    }
  })
  
  output$case_plot <- renderPlot({
    data_list = data()
    ggplot(data = data_list[[1]], aes(x=date, y=case)) +
      geom_line(aes(colour=borough))
    
  })
  
  output$hosp_plot <- renderPlot({
    data_list = data()
    ggplot(data = data_list[[1]], aes(x=date, y=hospitalized)) +
      geom_line(aes(colour=borough))
  })
  
  output$death_plot <- renderPlot({
    data_list = data()
    ggplot(data = data_list[[1]], aes(x=date, y=death)) +
      geom_line(aes(colour=borough))
  })
  
  output$barplot_2020 <- renderPlot({
    data_list = data()
    ggplot(data_list[[2]], aes(x = factor(borough), y = total_count, 
                               fill = type, colour = type)) + 
      geom_bar(stat = "identity", position = "dodge")
  })
  
  output$barplot_2021 <- renderPlot({
    data_list = data()
    ggplot(data_list[[3]], aes(x = factor(borough), y = total_count, 
                               fill = type, colour = type)) + 
      geom_bar(stat = "identity", position = "dodge")
  })
  
  output$barplot_2022 <- renderPlot({
    data_list = data()
    ggplot(data_list[[4]], aes(x = factor(borough), y = total_count, 
                               fill = type, colour = type)) + 
      geom_bar(stat = "identity", position = "dodge")
  })
  
})
  ####################### Salary and Worktime ##################       
  
  
 

