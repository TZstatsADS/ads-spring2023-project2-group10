lop = read.csv("../data/Cleaned_LOP_numeric_year.csv")


# install_github('arilamstein/choroplethrZip@v1.5.0')

library(choroplethr)
library(choroplethrZip)
library(shiny)
library(ggplot2)

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


ui <- navbarPage("Pandemic consequences in NYC",
                 
                 
                 tabPanel(
                   "Preface",
                   tags$img(
                     src = "https://media.cntraveler.com/photos/63483e15ef943eff59de603a/3:2/w_3000,h_2000,c_limit/New%20York%20City_GettyImages-1347979016.jpg",
                     width = "100%",
                     style = "opacity: 0.99"
                   ),
                   fluidRow(
                     absolutePanel(
                       style = "background-color: white",
                       top = "40%",
                       left = "25%",
                       right = "25%",
                       height = 170,
                       tags$p(
                         style = "padding: 5%; background-color: white; font-family: alegreya; font-size: 120%",
                         "Intro, pandemic context, what we looked at."
                       )
                     )
                   ),
                 ),
                 tabPanel(
                   "Legally Operating Businesses",
                   
                   sidebarLayout(
                     
                     # Sidebar panel for inputs ----
                     sidebarPanel(
                       sliderInput("year", "Year", min = 2019.5, max = 2023, value = 2019.5,step=0.5),
                       # Input: Select for the borough ----
                       selectInput(inputId = "map_borough",
                                   label = "Choose a borough:",
                                   choices = c("All","Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island")),
                     ),
                     mainPanel("mainPanel",
                               plotOutput("choropleth"))
                   ),
                   
                   
                   
                 )
)




server <- function(input, output) {
  output$choropleth <- renderPlot({
    generate_choropleth(input$year,input$map_borough) +  scale_fill_continuous(type = "viridis",limits=range(lop$value))
  })
}

shinyApp(ui, server)