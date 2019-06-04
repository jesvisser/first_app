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

# Load data ----
activity <- fread("./Data/fitbit_export_20190604.csv",
                  skip = 1,
                  nrows = 31,
                  select = c("Date", "Steps", "Distance"),
                  dec = ".",
                  data.table = FALSE)

sleep <- fread("./Data/fitbit_export_20190604.csv",
               skip = 35,
               nrows = 30,
               select = c("End Time", "Asleep" = "Minutes Asleep"),
               dec = ".",
               data.table = FALSE)

# Transform data
sleep %<>% 
  rename(Date = `End Time`, Sleep = `Minutes Asleep`) %>%
  mutate(Date = dmy(word(Date, 1)))

activity %<>% 
  mutate_all(gsub, pattern = ",", replacement = "") %>%
  mutate(Date = dmy(Date)) %>%
  mutate_at(vars(-Date), as.numeric) %>%
  left_join(sleep, by = "Date")

rm(sleep)


### define shiny user interface ----
ui <- fluidPage(
  
  # App title
  titlePanel("My activity and sleep last month"),
  
  # Sidebar layout with input and output
  sidebarLayout(
    
    # Input(s)
    sidebarPanel(
      
      wellPanel(p("Hi there, welcome to my shiny app! It helps me to analyse my Fitbit data. Please select the data you wish to see in the plot")),
      
      wellPanel(
        selectInput(inputId = "x",
                    label = "Select x variable:",
                    choices = c("Date","Steps", "Sleep"),
                    selected = "Steps"),
        selectInput(inputId = "y",
                    label = "Select y variable:",
                    choices = c("Steps", "Sleep"),
                    selected = "Sleep")
      ),
      wellPanel(
         checkboxInput(inputId = "show_lm",
                       label = "Show linear model",
                       value = FALSE)
      )
    ),
    
    # Output(s)
    mainPanel(
      p("As I wear my Fitbit activity tracker, I collect data on the number of steps I take each day (Steps) and the minutes I sleep each day (Sleep). In this plot I can see how well I slept during the month May and also how active I have been. Would these 2 variables influence each other? Let's find out..."),
      plotOutput("plot")
    )
  )
)

### define shiny server function ----
server <- function(input, output) {
  
  output$plot <- renderPlot({
    
    # Create plot
    g <- ggplot(activity, aes_string(x = input$x, y = input$y)) +
      geom_point() +
      labs(title = "My steps and/or sleep during May 2019")
    
    # Show plot with or without linear model
    if(input$show_lm){
      g + geom_smooth(method ='lm')
    } else { 
        g 
      }
    
  })
}


### shinyApp ----
shinyApp(ui = ui, server = server)
