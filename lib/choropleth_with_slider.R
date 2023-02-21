lop = read.csv("Cleaned_LOP_numeric_year.csv")


# install_github('arilamstein/choroplethrZip@v1.5.0')

library(choroplethr)
library(choroplethrZip)
library(shiny)
# FUNCTION# CUSTOM gradient attempt

generate_choropleth <- function(input_value) {
  # Filter the dataset based on the input value
  df <- subset(lop, year == input_value)
  
  # Create the choropleth map
  (zip_choropleth(df,
                  title = "Active business licenses by ZIP code",
                  legend = "Quantity",
                  num_colors = 1,
                  county_zoom = 36061) + scale_fill_gradient(limits = range(lop$value)))  #+ scale_color_manual(values=c("#004400", "#00FF90"))#+ scale_colour_brewer(palette = "Greens")
  
}




ui <- fluidPage(
  sliderInput("year", "Year", min = 2019.5, max = 2023, value = 2019.5,step=0.5),
  plotOutput("choropleth")
)

server <- function(input, output) {
  output$choropleth <- renderPlot({
    generate_choropleth(input$year) +  scale_fill_continuous(type = "viridis")
  })
}

shinyApp(ui, server)