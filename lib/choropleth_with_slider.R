lop = read.csv("Cleaned_LOP_numeric_year.csv")


# install_github('arilamstein/choroplethrZip@v1.5.0')

library(choroplethr)
library(choroplethrZip)
library(shiny)

# FUNCTION

generate_choropleth <- function(input_value) {
  # Filter the dataset based on the input value
  df <- subset(lop, year == input_value)
  
  # Create the choropleth map
  zip_choropleth(df,
                 title = "Active business licenses by ZIP code",
                 legend = "Quantity",
                 num_colors = 1,
                 county_zoom = 36061)   
  
}




ui <- fluidPage(
  sliderInput("year", "Year", min = 2019.5, max = 2023, value = 2019.5,step=0.5),
  plotOutput("choropleth")
)

server <- function(input, output) {
  output$choropleth <- renderPlot({
    generate_choropleth(input$year) +  scale_fill_continuous(type = "viridis",limits=range(lop$value))
  })
}

shinyApp(ui, server)