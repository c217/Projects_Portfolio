#Import librairies
library(shiny)
library(bslib)
library(tidyverse)
library(plotly)
library(tidyquant)
library(leaflet)
library(DT)


library(psych)
library(summarytools)
library("stringr") 
library(scales)
library(dplyr)
library(funModeling)
library("ggpubr")
library(raster)
library(fmsb)
library(Hmisc)
library(colormap)
library(V8)
library(ggplot2)

# Import data
hostel <- data.table::fread("hostel_after_imputation_VF.csv")
hostel<- as_tibble(hostel)

hostel_map <- data.table::fread("hostel_imputation_map.csv")

hostel <- hostel[,-16]

colnames(hostel) <- c("Hostel_Name", "City", "Price", "Distance", "Summary_Score", "Rating_Band", "Atmosphere", "Cleanliness", "Facilities", "Location", "Security", "Staff", "Value_For_Money", "lon", "lat")
rating <- subset( hostel, select = c("Summary_Score", "Atmosphere", "Cleanliness", "Facilities", "Location", "Security", "Staff", "Value_For_Money", "City"))
var_best_city <- subset( hostel, select = c("Summary_Score","Atmosphere", "Cleanliness", "Facilities", "Security", "Value_For_Money"))
var_cheapest <- subset( hostel, select = c("Price"))

# Theme
my_theme <- bs_theme(bg = "#ffff ", fg = "#113580 ", primary = "#113580 ")


# USER INTERFACE
shinyUI(fluidPage(navbarPage(title = "Japanese Hostel", theme = my_theme, position = "static-top", 
                           
                           # Information
                           tabPanel("Information",
                                    icon = icon("fa-solid fa-circle-info",verify_fa = FALSE), align="center",
                                    headerPanel(h3("Welcome to our Japan hostel interface!")),
                                    br(),
                                    br(),
                                    fluidRow(
                                      column(width = 12,
                                             align = "center",
                                             tags$p("On this dynamic interface, you will find details about the cost of hostels, their 
                          location, how far they are from the city center and their rating according to multiple 
                          criteria. You will find below the list of current variables. You will be able to adjust 
                          the parameters to fit your needs to find the hotel or city that best suits you. 
                          The interface is designed so that you can establish your own comparison and you will 
                          therefore be able to obtain a wide range of graphs and statistical tables."),
                                             tags$p("Variables :", br(),
                                                    "- Hostel_Name (name of the hotel)", br(),
                                                    "- City (city)", br(),
                                                    "- Rating_Band (categorical rating)", br(),
                                                    "- Price (price)", br(),
                                                    "- Distance (distance to the city center)", br(),
                                                    "- Summary_Score (average score)", br(),
                                                    "- Atmosphere (atmosphere score)", br(),
                                                    "- Cleanliness (score for cleanliness)", br(),
                                                    "- Facilities (score for facilities)", br(),
                                                    "- Location (score for location)", br(),
                                                    "- Security (score for security)", br(),
                                                    "- Staff (score for the staff)", br(),
                                                    "- Value_For_Money (score for value for money)", br(),
                                                    "- lon (hotel location - longitude)", br(),
                                                    "- lat (hotel location - latitude)", br()),
                                             tags$p("You will be able to access all the information about the hostels, locate and 
                                             discover them via a map. You can also see the database with the number of observations 
                                             and the filters you want. In the recommendation menu, you will be able to have 
                                             recommendations of cities and hostels (best city by variable, best city with cheapest hostels, 
                                             median budget by city and best hostels in your favorite city). 
                                             Finally, you can get four types of descriptive analysis : by variable but also by crossed variables 
                                             (there are four combinations that are possible : two categorical variables, two quantitative variables, 
                                             one categorical and one quantitative). Be careful, you may receive an error message if there is an 
                                             incompatibility between the variable type and the display type."),
                                             br(),
                                             br(),
                                             tags$p("Have a good exploration !")

                                      )
                                    )),
                           
                           # Map
                           
                           tabPanel("Map", 
                                    icon = icon("fa-regular fa-map-location-dot",verify_fa = FALSE),
                                    headerPanel(h3("Map of Japan",align="center")),
                                    tags$style(type = "text/css", "#map {height: calc(90vh - 80px) !important;}"),
                                    leafletOutput("map"),
                                    absolutePanel(top = 250, right = 70,
                                                  selectInput(inputId = "cities",
                                                              label = "City",
                                                              choices = c("All"= "All",      
                                                                          "Tokyo" = "tokyo",
                                                                          "Osaka" = "osaka",
                                                                          "Hiroshima"="hiroshima",
                                                                          "Kyoto"="kyoto",
                                                                          "Fukuoka-City"="fukuoka-city"),
                                                              selected = "osaka"),
                                                  
                                                  sliderInput("summary_score", "Summary Score",
                                                              min(hostel_map$Summary_Score, na.rm = TRUE),
                                                              max(hostel_map$Summary_Score, na.rm = TRUE),
                                                              value = range(hostel_map$Summary_Score, na.rm = TRUE)),
                                                  sliderInput("price", "Price",
                                                              min(hostel_map$Price, na.rm = TRUE),
                                                              max(hostel_map$Price, na.rm = TRUE),
                                                              value = range(hostel_map$Price, na.rm = TRUE)),
                                                  sliderInput("distance", "Distance",
                                                              min(hostel_map$Distance, na.rm = TRUE),
                                                              max(hostel_map$Distance, na.rm = TRUE),
                                                              value = range(hostel_map$Distance, na.rm = TRUE))
                                    )
                           ),
                           
                           
                           # Database
                           tabPanel("Database",icon = icon("fa-regular fa-database",verify_fa = FALSE),
                                    headerPanel(h3("Database of Japanese Hostel",align="center")),
                                    div(DT::dataTableOutput("hostel"), style = "font-size: 65%; width: 65%")
                           ),
                           
                           
                           navbarMenu("Recommendation", 
                                      icon = icon("fa-regular fa-magnifying-glass",verify_fa = FALSE),
                                      
                                      
                                      # Best city by variable
                                      tabPanel("Best city by variable", icon = icon("fa-solid fa-city",verify_fa = FALSE),
                                               tabPanel("Best city by variable", headerPanel(h3("Best city by variable",align="center")),
                                                        br(),
                                                        br(),
                                                        fluidRow(
                                                          column(width = 12,
                                                                 align = "center",
                                                                 uiOutput("u_selector"),
                                                                 textOutput("best_city_max"),
                                                                 br(),
                                                                 br(),
                                                                 tags$p("Interpretation : (city name) is the best city with the highest 
                                                     median for the variable (variable name). The median (number) is interpreted 
                                                     as: 50% of the data is above the median and 50% is below the median.")
                                                          )
                                                        )
                                               )
                                      ),
                                      
                                      
                                      
                                      # Best city with cheapest hostels
                                      tabPanel("Best city with cheapest hostels", icon = icon("fa-solid fa-yen-sign",verify_fa = FALSE),
                                               tabPanel("Best city with cheapest hostels", headerPanel(h3("Best city with cheapest hostels",align="center")),
                                                        br(),
                                                        br(),
                                                        fluidRow(
                                                          column(width = 12,
                                                                 align = "center",
                                                                 uiOutput("u_selector_1"),
                                                                 textOutput("best_city_cheapest"),
                                                                 br(),
                                                                 br(),
                                                                 tags$p("Interpretation : Fukuoka-City is the best city with the lowest median 
                                                     for the price variable. The median is interpreted as: 50% of the data 
                                                     is above the median and 50% is below the median. Fukuoka-City is 
                                                     therefore the city with the most cheapest hostels. 
                                                     Indeed, 50% of hotels are priced below 2200 yen.")
                                                          )
                                                        )
                                               )
                                      ),
                                      
                                      # Foresee budget by city
                                      tabPanel("Foresee budget by city", icon = icon("fa-solid fa-piggy-bank",verify_fa = FALSE),
                                               tabPanel("Foresee budget by city", headerPanel(h3("Foresee budget by city",align="center")),
                                                        fluidPage(
                                                          titlePanel("Filters"),
                                                          sidebarLayout(
                                                            sidebarPanel(
                                                              selectInput(inputId = "City_foresee",label = "City",
                                                                          choices = c("Tokyo" = "tokyo",
                                                                                      "Osaka" = "osaka",
                                                                                      "Hiroshima"="hiroshima",
                                                                                      "Kyoto"="kyoto",
                                                                                      "Fukuoka-City"="fukuoka-city")
                                                                          #selected = hostel_map$City[1]
                                                              ) 
                                                            ),
                                                            mainPanel(
                                                              tabsetPanel(
                                                                tabPanel("", dataTableOutput("foresee_budget"))
                                                              )
                                                            )
                                                          )
                                                        )
                                                        )
                                               ),
                                      
                                      # Best hostel in your favorite city by variable
                                      tabPanel("Best hostel in your favorite city by variable", icon = icon("fa-solid fa-hotel",verify_fa = FALSE),
                                               tabPanel("Best hostel in your favorite city by variable", headerPanel(h3("Best hostel in your favorite city by variable",align="center")),
                                                        fluidPage(
                                                          titlePanel("Filters"),
                                                          sidebarLayout(
                                                            sidebarPanel(
                                                              selectInput(inputId = "Var_bhic",label = "Variable",
                                                                          choices = c("No" = 0,
                                                                                      "City"= 2,
                                                                                      "Price" = 3,
                                                                                      "Distance" = 4,
                                                                                      "Summary_Score"=5,
                                                                                      "Atmosphere"=7,
                                                                                      "Cleanliness"= 8,
                                                                                      "Facilities" = 9,
                                                                                      "Location" = 10,
                                                                                      "Security"=11,
                                                                                      "Staff"=12,
                                                                                      "Value_For_Money"=13),
                                                                          selected = 2
                                                              ),
                                                              selectInput(inputId = "Decrease_bhic",label = "Decrease",
                                                                          choices = c("Yes" = TRUE,
                                                                                      "No"= FALSE)
                                                                         
                                                              ),
                                                              selectInput(inputId = "City_bhic",label = "City",
                                                                          choices = c("Tokyo" = "tokyo",
                                                                                      "Osaka" = "osaka",
                                                                                      "Hiroshima"="hiroshima",
                                                                                      "Kyoto"="kyoto",
                                                                                      "Fukuoka-City"="fukuoka-city")
                                                                          
                                                              ) 
                                                            ),
                                                            mainPanel(
                                                              tabsetPanel(
                                                                tabPanel("", dataTableOutput("bhic"), style = "font-size: 65%; width: 50%")
                                                              )
                                                            )
                                                          )
                                                        )
                                                        )
                                               )
                                      ),
                           
                    
                           
                           #Menu Descriptive analysis
                           navbarMenu("",title = "Descriptive analysis", icon = icon("fa-solid fa-list-ul",verify_fa = FALSE),
                                      
                                      
                                      tabPanel("One variable analysis", icon = icon("fa-regular fa-chart-column",verify_fa = FALSE),
                                               tabPanel("One variable analysis", headerPanel(h3("One variable analysis",align="center"))), 
                                               fluidPage(
                                                 titlePanel("Filters"),
                                                 sidebarLayout(
                                                   sidebarPanel(
                                                     selectInput(inputId = "Var_10",label = "Variable",
                                                                 choices = c("City"= 2,
                                                                             "Price" = 3,
                                                                             "Distance" = 4,
                                                                             "Summary_Score"=5,
                                                                             "Rating_Band"=6,
                                                                             "Atmosphere"=7,
                                                                             "Cleanliness"= 8,
                                                                             "Facilities" = 9,
                                                                             "Location" = 10,
                                                                             "Security"=11,
                                                                             "Staff"=12,
                                                                             "Value_For_Money"=13,
                                                                             "lon"=14,
                                                                             "lat"=15),
                                                                 selected = 8
                                                                 
                                                                
                                                     ),
                                                     selectInput(inputId = "Plot_type_10",label = "Plot type",
                                                                 choices = c("Histogram"= "Histogram",
                                                                             "Boxplot" = "Boxplot",
                                                                             "Distribution" = "Distribution"),
                                                                 selected = "Boxplot"
                                                                 
                                                     ),
                                                     uiOutput("u_selector_10")
                                                     
                                                   ),
                                                   mainPanel(
                                                     tabsetPanel(
                                                       tabPanel("", plotOutput("One_var_plot"))
                                                     )
                                                   )
                                                 )
                                               )
                                      ), 
                                      tabPanel("Qualitative and quantitative variables analysis", icon = icon("fa-regular fa-chart-column",verify_fa = FALSE),
                                               tabPanel("quali and quanti variables analysis", headerPanel(h3("Qualitative and quantitative variables analysis",align="center"))),
                                               fluidPage(
                                                 titlePanel("Filters"),
                                                 sidebarLayout(
                                                   sidebarPanel(
                                                     selectInput(inputId = "Var_20",label = "Variable (for Boxplot)",
                                                                 choices = c("No" = 0,
                                                                             "City"= 2,
                                                                             "Price" = 3,
                                                                             "Distance" = 4,
                                                                             "Summary_Score"=5,
                                                                             "Rating_Band"=6,
                                                                             "Atmosphere"=7,
                                                                             "Cleanliness"= 8,
                                                                             "Facilities" = 9,
                                                                             "Location" = 10,
                                                                             "Security"=11,
                                                                             "Staff"=12,
                                                                             "Value_For_Money"=13,
                                                                             "lon"=14,
                                                                             "lat"=15)
                                                                 
                                                     ),
                                                     selectInput(inputId = "Group_by_20",label = "By (for Boxplot)",
                                                                 choices = c("No"=0,
                                                                             "City"= 2,      
                                                                             "Rating_Band" = 6)
                                                                 
                                                                 
                                                     ),
                                                     selectInput(inputId = "Plot_type_20",label = "Plot type",
                                                                 choices = c("Boxplot"="Boxplot",
                                                                             "Spider chart"= "Spider chart",
                                                                             "Point plot"= "Point plot",
                                                                             "All spider chart" = "All spider chart"),
                                                                 selected = "All spider chart"
                                                     ),
                                                     selectInput(inputId = "City_20",label = "City (for spider chart)",
                                                                 choices = c("All"= "All",      
                                                                             "Tokyo" = "tokyo",
                                                                             "Osaka" = "osaka",
                                                                             "Hiroshima"="hiroshima",
                                                                             "Kyoto"="kyoto",
                                                                             "Fukuoka-City"="fukuoka-city")
                                                               
                                                     )
                                            
                                                   ),
                                                   mainPanel(
                                                     tabsetPanel(
                                                       tabPanel("", plotOutput("Quali_quanti_plot"))
                                                   
                                                     )
                                                   )
                                                 )
                                               )
                                      ),
                                      tabPanel("Two qualitative variables analysis", icon = icon("fa-regular fa-chart-column",verify_fa = FALSE),
                                               tabPanel("Two qualitative variables analysis", headerPanel(h3("Frequency (in %) between City and Rating_Band variables",align="center"))),
                                               fluidRow(column(width = 12,
                                                               align = "center",
                                                               "" , dataTableOutput('cross_quali_var')
                                                   
                                                 )
                                               )
                                      ),
                                      tabPanel("Two quantitative variable analysis", icon = icon("fa-regular fa-chart-column",verify_fa = FALSE),
                                               tabPanel("Two quantitative variable analysis", headerPanel(h3("Two quantitative variable analysis",align="center"))),
                                               fluidPage(
                                                 titlePanel("Filters"),
                                                 sidebarLayout(
                                                   sidebarPanel(
                                                     selectInput(inputId = "Var_X_30",label = "Variable X (for Correlation plot)",
                                                                 choices = c("No" = "No",
                                                                             "Price" = "Price",
                                                                             "Distance" = "Distance",
                                                                             "Summary_Score"="Summary_Score",
                                                                             "Atmosphere"="Atmosphere",
                                                                             "Cleanliness"= "Cleanliness",      
                                                                             "Facilities" = "Facilities",
                                                                             "Location" = "Location",
                                                                             "Security"="Security",
                                                                             "Staff"="Staff",
                                                                             "Value_For_Money"="Value_For_Money",
                                                                             "lon"="lon",
                                                                             "lat"="lat"),
                                                                 selected = "Price"
                                                     ),
                                                     selectInput(inputId = "Var_Y_30",label = "Variable Y (for Correlation plot)",
                                                                 choices = c("No" = "No",
                                                                             "Price" = "Price",
                                                                             "Distance" = "Distance",
                                                                             "Summary_Score"="Summary_Score",
                                                                             "Atmosphere"="Atmosphere",
                                                                             "Cleanliness"= "Cleanliness",      
                                                                             "Facilities" = "Facilities",
                                                                             "Location" = "Location",
                                                                             "Security"="Security",
                                                                             "Staff"="Staff",
                                                                             "Value_For_Money"="Value_For_Money",
                                                                             "lon"="lon",
                                                                             "lat"="lat"),
                                                                 selected = "Summary_Score"
                                                     ),
                                                     selectInput(inputId = "Plot_type_30",label = "Plot type",
                                                                 choices = c("Correlation plot"="Correlation plot",
                                                                             "Correlation matrix"= "Correlation matrix"),
                                                                 selected = "Correlation plot"
                                                     ),
                                                     selectInput(inputId = "City_30",label = "City",
                                                                 choices = c("All"= "all",      
                                                                             "Tokyo" = "tokyo",
                                                                             "Osaka" = "osaka",
                                                                             "Hiroshima"="hiroshima",
                                                                             "Kyoto"="kyoto",
                                                                             "Fukuoka-City"="fukuoka-city")
                                                               
                                                     )
                                                   ),
                                                   mainPanel(
                                                     tabsetPanel(
                                                       tabPanel("", plotOutput("corr"))
                                                     )
                                                   )
                                                 )
                                               )
                                      )        
                           ), 
                           inverse=TRUE,
                           fluid=TRUE)
))


