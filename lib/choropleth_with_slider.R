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
                 county_zoom = 36061)
}




ui <- fluidPage(
  sliderInput("year", "Year", min = 2019.5, max = 2023, value = 2020.0),
  plotOutput("choropleth")
)

server <- function(input, output) {
  output$choropleth <- renderPlot({
    generate_choropleth(input$year)
  })
}

shinyApp(ui, server)