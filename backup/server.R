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

#### Choropleth map functions ####
lop = read.csv("Cleaned_LOP_numeric_year.csv")

#dir.create(normalizePath("~"))
library(devtools)
install.packages("libr/choroplethrZip-1.5.0.tar.gz",repos=NULL,lib=normalizePath("~"))
#install_github('arilamstein/choroplethrZip@v1.5.0')

library(choroplethr)
library(choroplethrZip,lib.loc = normalizePath("~"))
library(shiny)
library(ggplot2)
library(rsconnect)

# FUNCTION
yearstring <- function(yr){
  if (yr%%1 == 0){
    return(paste("Jan 1",yr))
  }
  else{
    return(paste("Jul 1",yr-0.5))
  }
}

borougher <- function(br){
  if ("All" %in% br){
    return(c(36005, 36047, 36061, 36081, 36085))
  }
  else if ("Manhattan" %in% br){
    return(36061)
  }
  else if ("Bronx" %in% br){
    return(36005)
  }
  else if ("Brooklyn" %in% br){
    return(36047)
  }
  else if ("Queens" %in% br){
    return(36081)
  }
  else{
    return(36085)
  }
}

generate_choropleth <- function(input_value, bor) {
  # Filter the dataset based on the input value
  df <- subset(lop, year == input_value)
  
  # Create the choropleth map
  zip_choropleth(df,
                 title = paste("Active business licenses by ZIP code as of",yearstring(input_value)),
                 legend = "Quantity",
                 num_colors = 1,
                 county_zoom = borougher(bor)) 
  # Bronx, Brooklyn, New York, Queens, Staten Island
  
}




####



##### data cleaning for health data
health <- read.csv("health_clean_data.csv", stringsAsFactors = FALSE)
plot_data <- read.csv("ggplot_data.csv", stringsAsFactors = FALSE)
plot_wei_data <- read.csv("ggplot_weighted_data.csv", stringsAsFactors = FALSE)
health$date_of_interest <- as.Date(health$date_of_interest)
plot_data$date <- as.Date(plot_data$date)
plot_wei_data$date <- as.Date(plot_wei_data$date)
MN_pop <- 1576876
BX_pop <- 1481409
QN_pop <- 2422938
SI_pop <- 493494
BK_pop <- 2712360
##### data scleaning for payroll data
Bx_swl <- read.csv('Bronx_plot.csv',stringsAsFactors = FALSE)
Bk_swl <- read.csv('Brooklyn_plot.csv',stringsAsFactors = FALSE)
Mh_swl <- read.csv('Manhattan_plot.csv',stringsAsFactors = FALSE)
Qn_swl <- read.csv('Queens_plot.csv',stringsAsFactors = FALSE)


shinyServer(function(input, output) {
  output$choropleth <- renderPlot({
    generate_choropleth(input$year,input$map_borough) +  scale_fill_continuous(type = "viridis",limits=range(lop$value))
  })
 
  ####################### Tab Health ##################
  
  data <- reactive({
    res2020 <- base::apply(health[health$date_of_interest< "2021-01-01", -1], 
                     2, sum)
    sum_2020 <- data.frame(borough = rep(c("Bronx", "Brooklyn", 
                                           "Manhattan", "Queens", 
                                           "Staten Island"), 3), 
                           total_count = res2020, 
                           type = rep(c("Case", "Death", 
                                        "Hospitalized"), each = 5))
    res2021 <- base::apply(health[health$date_of_interest < "2022-01-01" 
                            & health$date_of_interest >= "2021-01-01", 
                            -1], 2, sum)
    sum_2021 <- data.frame(borough = rep(c("Bronx", "Brooklyn", 
                                           "Manhattan", "Queens", 
                                           "Staten Island"), 3), 
                           total_count = res2021, 
                           type = rep(c("Case", "Death", 
                                        "Hospitalized"), each = 5))
    res2022 <- base::apply(health[health$date_of_interest>= "2022-01-01", -1], 
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
  
  swldata <- reactive({
    if ( "Manhattan" %in% input$Boroughs){
      data = Mh_swl
      return(data) 
    }
    if ( "Bronx" %in% input$Boroughs){
      data = Bx_swl
      return(data) 
    }
    if ( "Brooklyn" %in% input$Boroughs){
      data = Bk_swl
      return(data) 
    }
    if ( "Queens" %in% input$Boroughs){
      data = Qn_swl
      return(data) 
    }
  })
  
  output$salary_plot <- renderPlot({
    data = swldata()
    ggplot(data = data, aes(x=Fiscal_Year, y=`mean.Total_Salary.`, col=Agency_Name)) +
      geom_line() +
      ggtitle(paste('Mean Salary of 10 agencies in',input$Boroughs,'From 2014 to 2022')) +
      ylab("Mean Salary in $") + 
      geom_vline(xintercept = 2020, linetype = "dashed")
  })
  
  output$work_plot <- renderPlot({
    data = swldata()
    ggplot(data = data, aes(x=Fiscal_Year, y=`Total_Hours`, col=Agency_Name)) +
      geom_line() +
      ggtitle(paste('Mean working time of 10 agencies in',input$Boroughs,'From 2014 to 2022')) +
      ylab("Mean working time in Hr") + 
      geom_vline(xintercept = 2020, linetype = "dashed")
  })
  
  output$leave_plot <- renderPlot({
    data = swldata()
    ggplot(data = data, aes(x=Fiscal_Year, y=`Percent_Leave`, col=Agency_Name)) +
      geom_line() +
      ggtitle(paste('Resignation percentage of 10 agencies in',input$Boroughs,'From 2014 to 2022')) +
      ylab("Resignation percentage") + 
      geom_vline(xintercept = 2019, linetype = "dashed")
  })  
})
  ####################### Salary and Worktime ##################       
  
  
 


