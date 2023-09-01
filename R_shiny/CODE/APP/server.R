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



# ******************************************************FUNCTION*****************************************************

# Functions for server :

#DESCRIPTIVE ANALYSIS****************************************************************************

#1/ One variable analysis :

#1.1/ For quantitatives variable :
quant_analysis <- function(data_var, var_name, histo, boxp, summ, plot){
  #frequence : 
  if (histo==1){
    hist <- hist(data_var, 
                 col = c("skyblue"),
                 main = paste(str_c("Histogramme of the variable", var_name, sep=' ')),
                 ylab = "Effectifs",
                 xlab = var_name)
    return(hist)
  }
  #Position setting :
  #boxplot 
  if (boxp==1){
    boxplot <- boxplot(data_var, col = c("skyblue"),main = str_c("Boxplot of the variable",var_name, sep=' '), ylab = var_name)
    return(boxplot)}
  #summary :
  if (summ==1){
    summtools <- summarytools::descr(data_var)
    return(summtools)}
  #dispersion setting :
  #Filled Density Plot
  if (plot==1){
    d <- density(data_var)
    plot_d <- plot(d, main=str_c("Kernel Density of", var_name, sep=' ')) + polygon(d, col="skyblue", border="red")
    return(plot_d)}
}



#2/ quali and quanti variables analysis (group_by City and Rating_Band):

#2.1/group_by City :
#boxplot :
boxplot_groupby <- function(a,b = hostel$City, ylab, xlab){ 
  res <- boxplot(a ~ b,
                 col = c("skyblue"),
                 main = paste(str_c("Boxplot")),
                 ylab = ylab, xlab = xlab)
  return(res)
}

#Spider chart and bar plot for 1 city :
ind_spider_chart <- function(data, city, spider_chart){
  library(fmsb)
  hostel_imputation2<- subset(data, select=c(City, Atmosphere, Cleanliness, Facilities, Location, Security, Staff, Value_For_Money))
  hostel_imputation2 <- as.data.frame(hostel_imputation2)
  b <- hostel_imputation2 %>% group_by(City) %>% summarise_all(funs(mean))
  b<- as.data.frame(b)
  b_<-b[b$City == city,] 
  b_ <- rbind(rep(10,5) , rep(0,5) , b_)
  rownames(b_) <- NULL
  
  if(spider_chart=='Yes'){
    return(radarchart(b_[,2:8], axistype=1, title = str_c(city,'(6 to 10)', sep=' '), plwd=3, plty=1 ,cglcol="grey", cglty=1, axislabcol="black", caxislabels=seq(6,10,1), cglwd=0.8, vlcex=0.8, pcol='skyblue'))
  }
  
  if(spider_chart == 'No'){
    return(b_[,2:8] %>% slice(3) %>% t() %>% as.data.frame() %>% add_rownames() %>% arrange(V1) %>% mutate(rowname=factor(rowname, rowname)) %>%
             ggplot( aes(x=rowname, y=V1)) +
             geom_segment( aes(x=rowname ,xend=rowname, y=0, yend=V1), color="grey") +
             geom_point(size=5, color="skyblue") +
             coord_flip() +
             
             theme(
               panel.grid.minor.y = element_blank(),
               panel.grid.major.y = element_blank(),
               axis.text = element_text( size=12 ),
               legend.position="none"
             ) +
             ylim(8,10) +
             ylab(city) +
             xlab(""))
    
  }
}


#all spider chart :
all_spider_chart <- function(){
  library(fmsb)
  hostel_imputation2<- subset(hostel, select=c(City, Atmosphere, Cleanliness, Facilities, Location, Security, Staff, Value_For_Money))
  hostel_imputation2 <- as.data.frame(hostel_imputation2)
  b <- hostel_imputation2 %>% group_by(City) %>% summarise_all(funs(median))
  b<- as.data.frame(b)
  b <- rbind(rep(10,10) , rep(7,10) , b)
  # Prepare color
  library(colormap)
  colors_border=colormap(colormap=colormaps$viridis, nshades=6, alpha=1)
  colors_in=colormap(colormap=colormaps$viridis, nshades=6, alpha=0.3)
  
  # Prepare title
  mytitle <- c("Fukuoka-city", "Hiroshima", "Kyoto", "Osaka", "Tokyo")
  
  # Split the screen in 6 parts
  par(mar=rep(0.8,4))
  par(mfrow=c(2,3))
  
  # Loop for each plot
  for(i in 1:5){
    # Custom the radarChart !
    radarchart( b[c(1,2,i+2),2:8], axistype=1,
                #custom polygon
                pcol=colors_border[i] , pfcol=colors_in[i] , plwd=4, plty=1 , 
                #custom the grid
                cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(6,10,1), cglwd=0.8,
                #custom labels
                vlcex=0.9,
                #title
                title=mytitle[i]
    )
    if(i==5){break}}
}


#4/ 2 quanti var :

#correlation plot between 2 variables :
#correlation squatter plot :
library("ggpubr")
corr_scatt_plot <- function(x, y, data, city){
  if (city == 'all') {
    hostel_imputation_ <- data }
  if (city != 'all') {
    hostel_imputation_ <- data  %>% filter(City == city)}
  ggscatter(hostel_imputation_, x = x, y = y, 
            add = "reg.line", conf.int = TRUE, 
            cor.coef = TRUE, cor.method = "pearson",
            xlab = x, ylab = y)
}

#Corr matrix between all numeric variable :
#correlation matrix : 
library(psych)
corr_plot <- function(data, city){
  if (city == 'all') {
    hostel_imputation_ <- data  
  }
  if (city != 'all') {
    hostel_imputation_ <- data  %>% filter(City == city)
  }
  corPlot(hostel_imputation_[, unlist(lapply(hostel_imputation_, is.numeric))], cex = 1, 
          scale = FALSE, stars = TRUE)
}

#RESEARCH BAR*****************************************************************************************
#1/ qualit and quanti :

#1.1/Group_by City

#Choose the best city(min or max) :

best_city <- function(var,data, min, max){
  best_city <- data %>%
    group_by(City) %>%
    summarise_at(vars(var), list(median = median)) %>%
    arrange(median)
  if (max == 1){
    return(apply(best_city, 2, FUN=max))}
  if (min == 1){
    return(apply(best_city, 2, FUN=min))
  }
}

# Foresee budget by city

choice_city <- function(city, var,data){
  hostel_imputation_ <- data
  
  mean_budget <- hostel_imputation_ %>%
    group_by(City) %>%
    summarise_at(vars(var), list(median = median)) %>%
    arrange(median)
  if (city == 'fukuoka-city'){
    return(subset(mean_budget,City=='fukuoka-city'))}
  if (city == 'hiroshima'){
    return(subset(mean_budget,City=='hiroshima'))}
  if (city == 'kyoto'){
    return(subset(mean_budget,City=='kyoto'))}
  if (city == 'osaka'){
    return(subset(mean_budget,City=='osaka'))}
  if (city == 'tokyo'){
    return(subset(mean_budget,City=='tokyo'))}
}


# Best hostel in your favorite city by variable

best_hostel_in_city <- function(data, data_var, decrease, city){
  best_hostel <- data[order(data_var,decreasing = decrease), ]
  best_hostel <- best_hostel %>%
    filter(City == city)
}


# SERVER

shinyServer(function(input, output, session) {
  
  # Map
  
  # Filters
  data_react <- reactive({
    hostel_1 <- hostel_map[which(!is.na(hostel_map$lon))]
    if (input$cities == "All"){hostel_map}
    else {
      hostel_map[(hostel_map$City == input$cities) 
                 & (hostel_map$Summary_Score >= input$summary_score[1])
                 & (hostel_map$Summary_Score <= input$summary_score[2])
                 & (hostel_map$Price >= input$price[1])
                 & (hostel_map$Price <= input$price[2])
                 & (hostel_map$Distance >= input$distance[1])
                 & (hostel_map$Distance <= input$distance[2])
      ]}
  })
  
  
  
  
  output$map <- renderLeaflet({
    leaflet(data=data_react()) %>%
      #set the view for Japan 
      setView(lng = 138.2529, lat = 36.2048, zoom = 5) %>%
      addTiles() %>%
      addMarkers(clusterOptions = markerClusterOptions(),
                 lng = data_react()$lon,
                 lat = data_react()$lat, 
                 label = data_react()$Hostel_Name)
  })
  
  
  
  
  # Database
  
  # Display database
  output$hostel = DT::renderDataTable(hostel, 
                                      options = list(autoWidth = FALSE), 
                                      filter = list(position = 'top', clear = FALSE)
  )
  
  # Recommendation 
  
  # Best city by variable (maximum)
  
  df <- reactive(var_best_city)
  
  output$u_selector <- renderUI({
    df_local <- req(df())
    selectInput("user_selected","Choose a variable",
                choices=names(df_local),
                selected = names(df_local)[[1]])
  })
  
  
  output$best_city_max <- renderText({
    df_local <- req(df())
    u_sel <- req(input$user_selected)
    
    best_city <- function(var,data, min, max){
      best_city <- data %>%
        group_by(City) %>%
        summarise_at(vars(var), list(median = median)) %>%
        arrange(median)
      if (max == 1){
        return(apply(best_city, 2, FUN=max))}
      if (min == 1){
        return(apply(best_city, 2, FUN=min))
      }
    }
    
    bc<-best_city(var=input$user_selected,data=hostel, min=0, max=1) 
    bc
    
  })
  
  # Best city with cheapest hostels (min)
  df1 <- reactive(var_cheapest)
  
  output$u_selector_1 <- renderUI({
    df_local_1 <- req(df1())
    selectInput("user_selected_1","",
                choices=names(df_local_1),
                selected = names(df_local_1)[[1]])
  })
  
  
  output$best_city_cheapest <- renderText({
    df_local_1 <- req(df1())
    u_sel_1 <- req(input$user_selected_1)
    
    best_city <- function(var,data, min, max){
      best_city <- data %>%
        group_by(City) %>%
        summarise_at(vars(var), list(median = median)) %>%
        arrange(median)
      if (max == 1){
        return(apply(best_city, 2, FUN=max))}
      if (min == 1){
        return(apply(best_city, 2, FUN=min))
      }
    }
    
    bc1<-best_city(var=input$user_selected_1,data=hostel, min=1, max=0) 
    bc1
  })
  
  
  # Foresee the budget by City : 
  output$foresee_budget <- renderDataTable({
    city <- input$City_foresee
    choice_city(city=city, var='Price',data=hostel)
  })
  
  
  # Best hostel in your favorite city by variable
  output$bhic <- renderDataTable({
    colm <- as.numeric(input$Var_bhic)
    decrease <- input$Decrease_bhic
    city <- input$City_bhic
    
    best_hostel_in_city(data=hostel, data_var=unlist(hostel[,colm]), decrease=decrease, city=city)
  }) 
  

  
  # Descriptive Analysis
  
  
  #1/ One variable analysis 
  output$One_var_plot <- renderPlot({
    colm <- as.numeric(input$Var_10)
    plot <- input$Plot_type_10
    if (plot == "Histogram")
    {quant_analysis(data_var=hostel[,colm], var_name='', histo=1, boxp=0, summ=0, plot=0)}
    if (plot == "Boxplot")
    {quant_analysis(data_var=hostel[,colm], var_name='', histo=0, boxp=1, summ=0, plot=0)}
    if (plot == "Distribution")
    {funModeling::freq(hostel[,colm], plot=TRUE)}
  })
  
  
  #2/ Qualitative and quantitative variables analysis
  output$Quali_quanti_plot <- renderPlot({
    colm <- as.numeric(input$Var_20)
    by <- as.numeric(input$Group_by_20)
    plot <- input$Plot_type_20
    city <- input$City_20
    if (plot == "Boxplot") #colm != 0 & by!=0 & city == "All"
    {boxplot_groupby(a=unlist(hostel[,colm]), b = unlist(hostel[,by]), ylab='', xlab="")}
    if (plot == "Spider chart") #colm == 0 & by==0 & & city != "All"
    {ind_spider_chart(data=hostel, city=city, spider_chart='Yes')}
    if (plot == "Point plot") #colm == 0 & by==0 & city != "All"
    {ind_spider_chart(data=hostel, city=city, spider_chart='No')}
    if (plot == "All spider chart") #colm == 0 & by==0  & city == "All"
    {all_spider_chart()}
  })
  
  
  #3/ Two qualitative variables :
  output$cross_quali_var <- DT::renderDataTable({
    table_City_rating<-table(hostel$Rating_Band,hostel$City)  
    a <- as.data.frame(round(prop.table(table_City_rating)*100, 2))
    colnames(a) <- c("Rating_Band", "City","Freq")
    a <- a[order(a$Freq,decreasing = TRUE), ]
    a
  })
  
  
  #4/ Two quantitative variables analysis :
  output$corr <- renderPlot({
    colm_x <- input$Var_X_30
    colm_y <- input$Var_Y_30
    plot <- input$Plot_type_30
    city <- input$City_30
    hostel_ <- as_tibble(hostel)
    if (plot == "Correlation plot") #colm != 0 & by!=0 & city == "All"
    {return(corr_scatt_plot(x=colm_x, y=colm_y, data=hostel_, city=city))}
    if (plot == "Correlation matrix") #colm == 0 & by==0 & & city != "All"
    {return(corr_plot(data=hostel_, city=city))}
    
  })
  
  
})
