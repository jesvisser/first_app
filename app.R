# setwd("C:/Users/Jessica.Visser/Documents/R scripts/first_app")

### Set up
library(data.table)
library(Rcpp)
library(dplyr)
library(readr)
library(magrittr)
library(lubridate)
library(stringr)
library(shiny)
library(ggplot2)
library(rsconnect)

### define shiny user interface ----
ui <- fluidPage(
  selectInput(inputId = "variable",
              label = "Variable:",
              choices = c("Steps", "Distance")),
  plotOutput("plot")
)

### define shiny server function ----
server <- function(input, output) {
  
  # Load data ----
  activity <- fread("./Data/fitbit_export_20190604.csv",
                    skip = 1,
                    nrows = 31,
                    dec = ".",
                    data.table = FALSE)
  
  # Transform data
  activity %<>% 
    mutate_all(gsub, pattern = ",", replacement = "") %>%
    mutate(Date = dmy(Date)) %>%
    mutate_at(vars(-Date), as.numeric)
  
  # Create plot
  output$plot <- renderPlot({
    activity %>%
      ggplot(aes_string(x = "Date", y = input$variable)) +
      geom_col()
  })
}


### shinyApp ----
shinyApp(ui = ui, server = server)
