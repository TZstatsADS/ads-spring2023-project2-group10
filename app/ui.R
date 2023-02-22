
library(viridis)
library(dplyr)
library(tibble)
library(tidyverse)
library(shinythemes)
library(sf)
#library(RCurl)
#library(tmap)
#library(rgdal)
library(leaflet)
library(shiny)
library(shinythemes)
library(plotly)
library(ggplot2)
library(shinydashboard)


# Define UI ----
body <- dashboardBody(
    
    tabItems(
        # ------------------ Home ----------------------------------------------------------------
        
        tabItem(tabName = "Home", fluidPage(
            fluidRow(box(width = 15, title = "Introduction", status = "primary",
                         solidHeader = TRUE, h3("Business and Salary Impact of COVID-19 in NYC"),
                         h4("Project by Brendan, Xinyu, Jinghan, Sicheng, and Haoyang"),
                         h5("This application visualizes business activity data, COVID-related data, and salary data to help the user see a holistic view of how the economy in NYC has changed in the context of COVID-19. Data was sourced from NYC Open Data."),
                         )),
            fluidRow(box(width = 15, title = "Intended Audience", status = "primary", solidHeader=TRUE,
                         h5("Economists or researchers that are interested in economic trends throughout the past 4 years would be interested in using our application to identify overall patterns to dive deeper into. "))),
            fluidRow(box(width = 15, title = "How to interpret the application", status = "primary",
                         solidHeader = TRUE,
                         h5("All of our visualizations can be filtered by borough, allowing users to focus on any particular borough of New York that they may be particularly interested in."),
                         tags$div(tags$ul(
                             tags$li("The choropleth map of business activity visualizes the amount of active business licenses in each ZIP code, and the slider allows the user to choose which year to visualize. It is apparent that after the pandemic hit, the amount of legally operating businesses throughout New York has decreased."),
                             tags$li("The health issues tab gives an idea of how the pandemic has affected New York over time, and acts as a proxy for the severity of the pandemic. The weighted version shows case counts/deaths as a proportion of the borough’s population."),
                             tags$li("The salary/worktime data visualizes how salaries have changed in major agencies over the years of the pandemic. These visualizations provide a high-level overview of whether there has been a change in salary trends before and after the pandemic.")
                             
                         ))
            ))
        )), # end of home 
        # ------------------ Map-----------------------------------
        tabItem(tabName = "Map", fluidPage(
          titlePanel("Choropleth Map of Active Business Licenses"),
          sidebarLayout(
            
            # Sidebar panel for inputs ----
            sidebarPanel(
              sliderInput("year", "Year", min = 2019.5, max = 2023, value = 2019.5,step=0.5),
              # Input: Select for the borough ----
              selectInput(inputId = "map_borough",
                          label = "Choose a borough:",
                          choices = c("All","Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island")),
            ),
            mainPanel(
                      plotOutput("choropleth"))
          )
        )
                
        ),
        
        #------------------Covid 19 Health Issues----------------------------
        tabItem(tabName = "Health_Issue", fluidPage(
            
            # App title ----
            titlePanel("COVID-related Health Issues"),
            
            # Sidebar layout with input and output definitions ----
            sidebarLayout(
                
                # Sidebar panel for inputs ----
                sidebarPanel(
                    
                  # Input: Select for the borough ----
                  selectInput(inputId = "borough",
                              label = "Choose a borough:",
                              choices = c("Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island", "All")),
                  selectInput(inputId = "weight",
                              label = "Whether the data is weighted by the population:",
                              choices = c("Unweighted", "Weighted"))
                   
                ),
                
                # Main panel for displaying outputs ----
                mainPanel(
                    
                  # Output: Plot on Covid case count ----
                  plotOutput(outputId = "case_plot"),
                  
                  # Output: Plot on hospitalization count ----
                  plotOutput(outputId = "hosp_plot"),
                  
                  # Output: Plot on death count ----
                  plotOutput(outputId = "death_plot"),
                  
                  # Output: Barplot on 2020 cumulative counts
                  plotOutput(outputId = "barplot_2020"),
                  
                  # Output: Barplot on 2021 cumulative counts
                  plotOutput(outputId = "barplot_2021"),
                  
                  # Output: Barplot on 2022 cumulative counts
                  plotOutput(outputId = "barplot_2022")
                    
                )
            )
        )
        ), 

        #------------------Salary and Worktime----------------------------
        tabItem(tabName = "Salary_Worktime", fluidPage(
            
            # App title ----
            titlePanel("Salary and Worktime"),
            
            # Sidebar layout with input and output definitions ----
            sidebarLayout(
                
                # Sidebar panel for inputs ----
                sidebarPanel(
                    # Input: Select for the borough ----
                    
                    
                    # Input: Select for the borough ----
                    selectInput(inputId = "Boroughs",
                                label = "Choose a borough:",
                                choices = c("Manhattan", "Bronx", "Brooklyn", "Queens"))
                    
                ),
                
                # Main panel for displaying outputs ----
                mainPanel(
                  # Output: Plot on Salary----
                  plotOutput(outputId = "salary_plot"),
                  
                  # Output: Plot on working hours  ----
                  plotOutput(outputId = "work_plot"),
                  plotOutput(outputId = "leave_plot")
                    
                )
            )
        )
        ),
        


        
        # ------------------ Appendix --------------------------------
        tabItem(tabName = "Appendix", fluidPage( 
            HTML(
                "<h2> Data Sources </h2>
                <h4> <p><li>NYC Covid 19 Data: <a href='https://github.com/nychealth/coronavirus-data'>NYC covid 19 github database</a></li></h4>
                <h4><li>NYC COVID-19 Policy : <a href='https://www1.nyc.gov/site/coronavirus/businesses/businesses-and-nonprofits.page' target='_blank'> NYC Citywide Information Portal</a></li></h4>
                <h4><li>NYC Business data : <a href='https://data.cityofnewyork.us/Business/Legally-Operating-Businesses/w7w3-xahh' target='_blank'>NYC Open Data</a></li></h4>
                <h4><li>NYC Business Application Data : <a href='https://data.cityofnewyork.us/Business/License-Applications/ptev-4hud' target='_blank'>NYC Open Data</a></li></h4>
                <h4><li>NYC Minority Owned Business : <a href='https://data.cityofnewyork.us/Business/M-WBE-LBE-and-EBE-Certified-Business-List/ci93-uc8s' target='_blank'>NYC Health + Hospitals</a></li></h4>
                <h4><li>NYC Geo Data : <a href='https://github.com/ResidentMario/geoplot-data-old' target='_blank'> Geoplot Github</a></li></h4>"
            ),
            
            titlePanel("Disclaimers "),
            
            HTML(
                " <p>We drew our business insights from NYC Open data, specifically business expiration databases. We recognized that there would be a lag between when the business is closed and when the expiration date, status are updated.</p>",
                " <p>Thus our app may understate the number of businesses that were actually closed. Furthermore, due to the lag between the time point where the business were closed, with when the expiration date be updated, there could be some uncertainty to define on which day, month the businesses were fully closed
 </p>"),
            
            titlePanel("Acknowledgement  "),
            
            HTML(
                " <p>This application is built using R shiny app.</p>",
                "<p>The following R packages were used in to build this RShiny application:</p>
                <li>Shinytheme</li>
                <li>Tidyverse</li>
                <li>Dyplr</li><li>Tibble</li><li>Rcurl</li><li>Plotly</li>
                <li>ggplot2</li>"
            ),
            
            titlePanel("Contacts"),
            
            HTML(
                " <p>For more information please feel free to contact</p>",
                " <p>Wendy Doan(ad3801@columbia.edu) </p>",
                " <p>Qizhen Yang(qy2446@columbia.edu)</p>",
                " <p>Yandong Xiong(yx2659@columbia.edu) </p>",
                " <p>TQiao Li(ql2403@columbia.edu)</p>",
                " <p>James Smiley(jbs2253@columbia.edu) </p>")
        )) # end of tab
        
    ) # end of tab items
) # end of body



ui <- dashboardPage(
    title="Covid 19 and The effect on Business in NYC",
    skin = "blue", 
    dashboardHeader(title=span("Covid 19 and NYC Business",style="font-size: 16px")),
    
    dashboardSidebar(sidebarMenu(
        menuItem("Home", tabName = "Home", icon = icon("home")),
        menuItem("Map", tabName = "Map", icon = icon("compass")),
        menuItem("Health Issue", tabName = "Health_Issue", icon = icon("yin-yang")),
        menuItem("Salary and Worktime", tabName = "Salary_Worktime", icon = icon("dollar-sign")),
        menuItem("Appendix", tabName = "Appendix", icon = icon("fas fa-asterisk"))
    )),
    body 
)