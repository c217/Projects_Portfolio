#read the database
library(tidyverse)
hostel <- data.table::fread("/Users/claire/Documents/Documents/STUDIES/6. M2 TIDE/Pré_rentrée/SQL:R/Projet R/Hostel.csv")

glimpse(hostel) 


#1/ Pre-processing (and imputation of missing values)


#convert all text to lowercase
library('dplyr')
hostel <-hostel %>% 
  mutate(across(where(is.character), tolower))
#type of each variable
glimpse(hostel)
#column to drop
hostel <- select(hostel,-c(V1))
#to keep only the distance and convert to numeric type
library(stringr)
hostel <- hostel %>% mutate(Distance = as.numeric(str_replace(hostel$Distance,"km from city centre","")))
glimpse(hostel) #verify if the distance is dbl type

#Looking for the columns which has missing values
library(Hmisc)
describe(hostel)

'''
summary.score : 15 missing values
rating.band : 15
atmosphere : 15
cleanliness : 15
facilities : 15
location.y : 15
security : 15
staff : 15
valueformoney : 15
lon : 44
lat : 44
'''
 
#Category the distances (in order to be able to group by distance for the imputations) (for example if the distance is 5.5km >> 5km)
library(dplyr) 
hostel$Distance_round <- round(hostel$Distance)
 
'''
summary.score : 15 missing values, impute group_by(city) et group_by(group_distance) 
rating.band : 15 impute by summary.score
atmosphere : 15 , impute group_by(city) et group_by(group_distance) 
cleanliness : 15 , impute group_by(city) et group_by(group_distance) 
facilities : 15 , impute group_by(city) et group_by(group_distance) 
location.y : 15 , impute group_by(city) et group_by(group_distance) 
security : 15 , impute group_by(city) et group_by(group_distance) 
staff : 15 , impute group_by(city) et group_by(group_distance) 
valueformoney : 15 , impute group_by(city) et group_by(group_distance) 
lon : 44 , impute group_by(city) et group_by(group_distance) 
lat : 44 , impute group_by(city) et group_by(group_distance) 
'''


#IMPUTATION OF MISSING VALUES

#summary.score : substitute NA by the median by city (and by the distance, optional)
library(scales)
library(dplyr) 
hostel <- hostel %>%
  group_by(City) %>%
  group_by(Distance_round) %>%
  mutate_at(vars(summary.score),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x))
  
#rating.band : summary.score equivalents
library(stringr)
hostel$rating.band <- as.factor(ifelse(hostel$summary.score>=9, 'superb',
                                       ifelse(hostel$summary.score < 9 & hostel$summary.score >= 8, 'fabulous',
                                              ifelse(hostel$summary.score < 8 & hostel$summary.score >= 7, 'very good',
                                                     ifelse(hostel$summary.score < 7 & hostel$summary.score >= 6, 'good',
                                                            ifelse(hostel$summary.score<6, 'rating', 'NA'))))))

#atmosphere : #cleanliness : #facilities : #location.y : #security : #staff : #valueformoney : substitute NA by the median by city (and by the distance, optional)
hostel <- hostel %>%
  group_by(City) %>%
  group_by(Distance_round) %>%
  mutate_at(vars(atmosphere),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x)) %>%
  mutate_at(vars(cleanliness),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x)) %>%
  mutate_at(vars(facilities),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x)) %>%
  mutate_at(vars(location.y),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x)) %>%
  mutate_at(vars(security),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x)) %>%
  mutate_at(vars(staff),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x)) %>%
  mutate_at(vars(valueformoney),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x))

#lon : substitute NA by the median by city (and by the distance, optional) 
hostel <- hostel %>%
  group_by(City) %>%
  group_by(Distance_round) %>%
  mutate_at(vars(lon),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x))

#lat : substitute NA by the median by city (and by the distance, optional) 
hostel <- hostel %>%
  group_by(City) %>%
  group_by(Distance_round) %>%
  mutate_at(vars(lat),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x))

#Verify if there are still some NA ?
describe(hostel)



#NEW DF AVEC IMPUTATION: HOSTEL_IMPUTATION
#Export the df to excel
install.packages("writexl")
library("writexl")
write_xlsx(hostel,"C:\\Users\\Pénichon\\Desktop\\M2_TIDE\\Pre_rentree\\R_SQL(R)\\Projet\\hostel_imputation.xlsx")
#Export the df to csv
write_csv(hostel,"C:\\Users\\Pénichon\\Desktop\\M2_TIDE\\Pre_rentree\\R_SQL(R)\\Projet\\hostel_imputation.csv")




#2/ Descriptive analysis of hostel_imputation (and treatment of outliers)


#read the dataset (option1)
library("readxl")
hostel_imputation <- read_excel("C:\\Users\\Pénichon\\Desktop\\M2_TIDE\\Pre_rentree\\R_SQL(R)\\Projet\\hostel_imputation.xlsx")
hostel_imputation<- as.data.frame(hostel_imputation)
#read the dataset (option2)
install.packages("tidyverse")
library('tidyverse')
hostel_imputation <- data.table::fread("C:/Users/Pénichon/Desktop/M2_TIDE/Pre_rentree/R_SQL(R)/Projet/hostel_imputation.csv")
hostel_imputation <- as_tibble(hostel_imputation)


#BEFORE : Determinate the type of variable 
#categorical : ordinal or nominal
#quantitative : continue or discrete 

'''
hostel.name(chr) = Quali nominal
City(chr) = Quali nominal
price.from(int) = Quant continue
Distance(dbl) = Quant continue
summary.score(dbl) = Quant continue
rating.band(chr) = Quali ordinal
atmosphere(dbl) = Quant continue
cleanliness(dbl) = Quant continue
facilities(dbl) = Quant continue
location.y(dbl) = Quant continue
security(dbl) = Quant continue
staff(dbl) = Quant continue
valueformoney(dbl) = Quant continue
lon(dbl) = Quant continue
lat(dbl) = Quant continue
Distance_round(int) = Quant discrete
'''

###### first : GENERAL ANALYSIS first
summary(hostel_imputation)
library(Hmisc)
describe(hostel_imputation)
library(funModeling)
df_status(hostel_imputation)


###### then : ANALYSIS OF EACH VARIABLE (and detect/deal with OUTLIERS) 

#function for quantitative analysis
install.packages( pkgs = "summarytools")
library(psych)
library(summarytools)
library(stringr) 
library(scales)
library(dplyr)
library(funModeling)
library(ggpubr)
library(raster)
library(fmsb)
library(Hmisc)
library(ggplot2)


quant_analysis <- function(data_var, var_name, histo, boxp, summ, plot){
  #frequence
  if (histo==1){
    hist <- hist(data_var, 
                 col = c("skyblue"),
                 main = paste(str_c("Histogramme of the variable", var_name, sep=' ')),
                 ylab = "Effectifs",
                 xlab = var_name)
    return(hist)
  }
  #Position setting
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



##City (categorical)
#effectif
table_city <- table(hostel_imputation$City)
#proportion
prop.table(table_city) 
#Barplot
library(funModeling)
summarytools::freq(hostel_imputation$City) 
funModeling::freq(hostel_imputation$City, plot=TRUE)


##price.from (quantitative)
summarytools::descr(hostel_imputation$price.from)
boxplot(hostel_imputation$price.from, col = c("skyblue"),main = "Boxplot", ylab = "Quantiles")
#drop the two price.from outliers
hostel_imputation<-hostel_imputation[hostel_imputation$price.from <= 10000,]
#frequence : On a une distribution qui suit une loi normale
quant_analysis(data_var=hostel_imputation$price.from, var_name='price.from', histo=1, boxp=0, summ=0, plot=0) 
#Position setting
#boxplot 
quant_analysis(data_var=hostel_imputation$price.from, var_name='price.from', histo=0, boxp=1, summ=0, plot=0) 
#summary
quant_analysis(data_var=hostel_imputation$price.from, var_name='price.from', histo=0, boxp=0, summ=1, plot=0) 
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$price.from, var_name='price.from', histo=0, boxp=0, summ=0, plot=1) 



##Distance (quantitative)
summarytools::descr(hostel_imputation$Distance)
#frequence 
quant_analysis(data_var=hostel_imputation$Distance, var_name='Distance', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$Distance, var_name='Distance', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$Distance, var_name='Distance', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$Distance, var_name='Distance', histo=0, boxp=0, summ=0, plot=1)


##summary.score (quantitative)
summarytools::descr(hostel_imputation$summary.score)
#frequence 
quant_analysis(data_var=hostel_imputation$summary.score, var_name='summary.score', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$summary.score, var_name='summary.score', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$summary.score, var_name='summary.score', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$summary.score, var_name='summary.score', histo=0, boxp=0, summ=0, plot=1)


##rating.band (categorical)
#effectif
table_city <- table(hostel_imputation$rating.band)
#proportion
prop.table(table_city)
#Barplot
library(funModeling)
summarytools::freq(hostel_imputation$rating.band)
funModeling::freq(hostel_imputation$rating.band, plot=TRUE)


##atmosphere (quantitative)
summarytools::descr(hostel_imputation$atmosphere)
#frequence 
quant_analysis(data_var=hostel_imputation$atmosphere, var_name='atmosphere', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$atmosphere, var_name='atmosphere', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$atmosphere, var_name='atmosphere', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$atmosphere, var_name='atmosphere', histo=0, boxp=0, summ=0, plot=1)


##cleanliness (quantitative)
summarytools::descr(hostel_imputation$cleanliness)
#frequence 
quant_analysis(data_var=hostel_imputation$cleanliness, var_name='cleanliness', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$cleanliness, var_name='cleanliness', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$cleanliness, var_name='cleanliness', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$cleanliness, var_name='cleanliness', histo=0, boxp=0, summ=0, plot=1)


##facilities (quantitative)
summarytools::descr(hostel_imputation$facilities)
#frequence
quant_analysis(data_var=hostel_imputation$facilities, var_name='facilities', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$facilities, var_name='facilities', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$facilities, var_name='facilities', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$facilities, var_name='facilities', histo=0, boxp=0, summ=0, plot=1)


##location.y (quantitative) 
summarytools::descr(hostel_imputation$location.y)
#frequence
quant_analysis(data_var=hostel_imputation$location.y, var_name='location.y', histo=1, boxp=0, summ=0, plot=0)
#Position setting 
#summary
quant_analysis(data_var=hostel_imputation$location.y, var_name='location.y', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$location.y, var_name='location.y', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$location.y, var_name='location.y', histo=0, boxp=0, summ=0, plot=1)


##security (quantitative) 
summarytools::descr(hostel_imputation$security)
#frequence
quant_analysis(data_var=hostel_imputation$security, var_name='security', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$security, var_name='security', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$security, var_name='security', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$security, var_name='security', histo=0, boxp=0, summ=0, plot=1)


##staff (quantitative)
summarytools::descr(hostel_imputation$staff)
#frequence
quant_analysis(data_var=hostel_imputation$staff, var_name='staff', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$staff, var_name='staff', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$staff, var_name='staff', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$staff, var_name='staff', histo=0, boxp=0, summ=0, plot=1)


##valueformoney (quantitative)
summarytools::descr(hostel_imputation$valueformoney)
#frequence
quant_analysis(data_var=hostel_imputation$valueformoney, var_name='valueformoney', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$valueformoney, var_name='valueformoney', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$valueformoney, var_name='valueformoney', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$valueformoney, var_name='valueformoney', histo=0, boxp=0, summ=0, plot=1)


##lon (quantitative)
summarytools::descr(hostel_imputation$lon)
boxplot(hostel_imputation$lon, col = c("skyblue"),main = "Boxplot", ylab = "Quantiles")
#longitude max du japon : 154 
#longitude min du japon :123
#replace lon for the hostels that are not located in Japan by NA
hostel_imputation$lon[hostel_imputation$lon <= 122 | hostel_imputation$lon >= 155] <- NA 
#then impute lon variable by the median of others grouped by city
hostel_imputation <- hostel_imputation %>%
  group_by(City) %>%
  mutate_at(vars(lon),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x))
#frequence
quant_analysis(data_var=hostel_imputation$lon, var_name='lon', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$lon, var_name='lon', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$lon, var_name='lon', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot (NE FONCTIONNE PAS CAR VALEURS MANQUANTES)
quant_analysis(data_var=hostel_imputation$lon, var_name='lon', histo=0, boxp=0, summ=0, plot=1)


##lat (quantitative) 
summarytools::descr(hostel_imputation$lat)
boxplot(hostel_imputation$lat, col = c("skyblue"),main = "Boxplot", ylab = "Quantiles")
#longitude max du japon : 46
#longitude min du japon : 20
#replace lat for the hostels that are not located in Japan by NA
hostel_imputation$lat[hostel_imputation$lat <= 19 | hostel_imputation$lat >= 47] <- NA
#then impute lat variable
hostel_imputation <- hostel_imputation %>%
  group_by(City) %>%
  mutate_at(vars(lat),~ifelse(is.na(.x), median(.x, na.rm = TRUE), .x))
#frequence
quant_analysis(data_var=hostel_imputation$lat, var_name='lat', histo=1, boxp=0, summ=0, plot=0)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$lat, var_name='lat', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$lat, var_name='lat', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot (NE FONCTIONNE PAS CAR VALEURS MANQUANTES)
quant_analysis(data_var=hostel_imputation$lat, var_name='lat', histo=0, boxp=0, summ=0, plot=1)


##Distance_round (categorical)
summarytools::descr(hostel_imputation$Distance_round)
#frequence
quant_analysis(data_var=hostel_imputation$Distance_round, var_name='Distance_round', histo=1, boxp=0, summ=0, plot=0)
funModeling::freq(hostel_imputation$Distance_round, plot=TRUE)
#Position setting
#summary
quant_analysis(data_var=hostel_imputation$Distance_round, var_name='Distance_round', histo=0, boxp=0, summ=1, plot=0)
#boxplot 
quant_analysis(data_var=hostel_imputation$Distance_round, var_name='Distance_round', histo=0, boxp=1, summ=0, plot=0)
#dispersion setting : filled density plot
quant_analysis(data_var=hostel_imputation$Distance_round, var_name='Distance_round', histo=0, boxp=0, summ=0, plot=1)


###### finally : analysis BETWEEN VARIABLES

#quantitative and categorical


#grouped by City
install.packages("psych")
library(psych)
describeBy(hostel_imputation, group=hostel_imputation$City)
#boxplot
boxplot_groupby <- function(a,b = hostel_imputation$City, ylab, xlab){ 
  res <- boxplot(a ~ b,
                 col = c("skyblue"),
                 main = paste(str_c("Boxplot for variable", ylab, "by", xlab, sep=' ')),
                 ylab = ylab, xlab = xlab)
  return(res)
}
boxplot_groupby(a = hostel_imputation$price.from, b = hostel_imputation$City, ylab='price.from', xlab="City")
boxplot_groupby(a = hostel_imputation$Distance, ylab='Distance', xlab="City")
boxplot_groupby(a = hostel_imputation$summary.score, ylab='summary.score', xlab="City")
boxplot_groupby(a = hostel_imputation$atmosphere, ylab='atmosphere', xlab="City")
boxplot_groupby(a = hostel_imputation$cleanliness, ylab='cleanliness', xlab="City")
boxplot_groupby(a = hostel_imputation$facilities, ylab='facilities', xlab="City")
boxplot_groupby(a = hostel_imputation$location.y, ylab='location.y', xlab="City")
boxplot_groupby(a = hostel_imputation$security, ylab='security', xlab="City")
boxplot_groupby(a = hostel_imputation$staff, ylab='staff', xlab="City")
boxplot_groupby(a = hostel_imputation$valueformoney, ylab='valueformoney', xlab="City")


#significance test (for the price in two different cities)
anova <- function(a,b=hostel_imputation$City){ 
  anova <- aov(a ~ b, data=hostel_imputation)
  return(summary(anova))
}
anova(a = hostel_imputation$price.from, b = hostel_imputation$City)


#1 CHOOSE THE BEST CITY (min or max)

library(dplyr)
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


best_city(var='valueformoney',data=hostel_imputation, min=0, max=1)


#1.1 FORESEE THE BUDGET BY CITY

library("dplyr")
choice_city <- function(city, var,data){
  hostel_imputation_ <- data %>%  filter(price.from <= 12750)
  
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


c_c <- choice_city(city='osaka', var='price.from',data=hostel_imputation)


#1.2 BEST HOSTEL IN FAVORITE CITY BY VARIABLE

best_hostel_in_city <- function(data, data_var, decrease, city){
  best_hostel <- data[order(data_var,decreasing = decrease), ] 
  best_hostel <- best_hostel %>% 
    filter(City == city)
}
b_h_i_c<-best_hostel_in_city(data=hostel_imputation, data_var=hostel_imputation$price.from, decrease=FALSE, city='osaka')


#1.3 BEST HOSTEL IN BEST CITY

best_hostel_in_best_city <- function(var,data, min, max, data_var, all){
  #best hostel in best city
  #funct1
  if(all==FALSE) {
    best_city <- data%>%
      group_by(City) %>%                        
      summarise_at(vars(var), list(median = median)) %>%
      arrange(median)
    #best_city
    if (max == 1){
      b_c <- apply(best_city, 2, FUN=max)
      decrease <- TRUE}
    if (min == 1){
      b_c <- apply(best_city, 2, FUN=min)
      decrease <- FALSE}
    #funct2
    best_hostel <- data[order(data_var,decreasing = decrease), ] 
    best_hostel <- best_hostel %>% 
      filter(City == str_c(b_c[1]))
    return(best_hostel)}
  
  #best hostel in Japan
  if (all ==TRUE) {
    best_city <- data
    #best_city
    if (max == 1){
      decrease <- TRUE}
    if (min == 1){
      decrease <- FALSE}
    #funct2
    best_hostel <- data[order(data_var,decreasing = decrease), ] 
    return(best_hostel)}
}

b_h_i_b_c<-best_hostel_in_best_city(var='cleanliness',data=hostel_imputation, min=0, max=1, data_var=hostel_imputation$cleanliness, all=FALSE)



#Spider chart and bar plot for 1 city

ind_spider_chart <- function(data, city, spider_chart){
  library(fmsb)
  hostel_imputation2<- subset(data, select=c(City, atmosphere, cleanliness, facilities, location.y, security, staff, valueformoney))
  hostel_imputation2 <- as.data.frame(hostel_imputation2)
  b <- hostel_imputation2 %>% group_by(City) %>% summarise_all(funs(mean))
  b<- as.data.frame(b)
  b_<-b[b$City == city,] 
  b_ <- rbind(rep(10,5) , rep(0,5) , b_)
  rownames(b_) <- NULL
  
  if(spider_chart==TRUE){
    radarchart(b_[,2:8], axistype=1, title = str_c(city,'(6 to 10)', sep=' '), plwd=3, plty=1 ,cglcol="grey", cglty=1, axislabcol="black", caxislabels=seq(6,10,1), cglwd=0.8, vlcex=0.8, pcol='skyblue')
  }
  
  if(spider_chart == FALSE){
    b_[,2:8] %>% slice(3) %>% t() %>% as.data.frame() %>% add_rownames() %>% arrange(V1) %>% mutate(rowname=factor(rowname, rowname)) %>%
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
      ylim(7,10) +
      ylab(city) +
      xlab("")
  }
}
ind_spider_chart(data=hostel_imputation, city='hiroshima', spider_chart=TRUE)


#all spider charts (for all the cities)
all_spider_chart <- function(){
  library(fmsb)
  hostel_imputation2<- subset(hostel_imputation, select=c(City, atmosphere, cleanliness, facilities, location.y, security, staff, valueformoney))
  hostel_imputation2 <- as.data.frame(hostel_imputation2)
  b <- hostel_imputation2 %>% group_by(City) %>% summarise_all(funs(median))
  b<- as.data.frame(b)
  b <- rbind(rep(10,10) , rep(6,10) , b)
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
    # Custom the radarChart
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
all_spider_chart()



#grouped by rating.band
install.packages("psych")
library(psych)
describeBy(hostel_imputation, group=hostel_imputation$rating.band)
#boxplot 
boxplot_groupby(a = hostel_imputation$price.from, b=hostel_imputation$rating.band, ylab='price.from', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$Distance, b=hostel_imputation$rating.band, ylab='Distance', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$summary.score, b=hostel_imputation$rating.band, ylab='summary.score', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$atmosphere, b=hostel_imputation$rating.band, ylab='atmosphere', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$cleanliness, b=hostel_imputation$rating.band, ylab='cleanliness', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$facilities, b=hostel_imputation$rating.band, ylab='facilities', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$location.y, b=hostel_imputation$rating.band, ylab='location.y', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$security, b=hostel_imputation$rating.band, ylab='security', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$staff, b=hostel_imputation$rating.band, ylab='staff', xlab="rating.band")
boxplot_groupby(a = hostel_imputation$valueformoney, b=hostel_imputation$rating.band, ylab='valueformoney', xlab="rating.band")


#two categorical variables

#tableau
table_City_rating<-table(hostel_imputation$rating.band,hostel_imputation$City)
prop.table(table_City_rating, 2)
#independence test
chisq.test(hostel_imputation$rating.band,hostel_imputation$City)




#two quantitative variables

#correlation between 2 variables
#function for correlation scatter plot
library("ggpubr")
corr_scatt_plot <- function(x, y, data, city){
  if (city == 'all') {
    hostel_imputation_ <- data  %>% filter(price.from <= 12750)}
  if (city != 'all') {
    hostel_imputation_ <- data  %>% filter(price.from <= 12750) %>% filter(City == city)}
  ggscatter(hostel_imputation_, x = x, y = y, 
            add = "reg.line", conf.int = TRUE, 
            cor.coef = TRUE, cor.method = "pearson",
            xlab = x, ylab = y)
}
#price.from and Distance
hostel_imputation <- as_tibble(hostel_imputation)
corr_scatt_plot(x="Distance", y='price.from', data=hostel_imputation, city='all') 
dev.off()
#price.from and cleanliness
hostel_imputation <- as_tibble(hostel_imputation)
corr_scatt_plot(x="cleanliness", y='price.from', data=hostel_imputation, city='all')
dev.off()
#price.from and summary.score
hostel_imputation <- as_tibble(hostel_imputation)
corr_scatt_plot(x="summary.score", y='price.from', data=hostel_imputation, city='all')
dev.off()
#Distance and summary.score
hostel_imputation <- as_tibble(hostel_imputation)
corr_scatt_plot(x="summary.score", y='Distance', data=hostel_imputation, city='all')
dev.off()

#Corr between all numeric variables
library(psych)
corr_plot <- function(data, city){
  if (city == 'all') {
    hostel_imputation_ <- data  
    }
  if (city != 'all') {
    hostel_imputation_ <- data %>% filter(City == city)
  }
  corPlot(hostel_imputation_[, unlist(lapply(hostel_imputation_, is.numeric))], cex = 1, 
          scale = FALSE, stars = TRUE)
}


hostel_imputation <- as_tibble(hostel_imputation)
corr_plot(data=hostel_imputation, city="osaka") #do it for other cities too
dev.off()




################## MACHINE LEARNING ###########################

#GOAL : predict 'price.from'

#1/PRE-PROCESSING

#impute MISSING VALUES AND OUTLIERS : same as in descriptive analysis > no NA and OUTLIERS anymore (done before)

library(Hmisc) 
df_status(hostel_imputation)

#ENCODING of the categorical variables
#City : We use One-hot-encoder
hostel_imputation$City <- as.factor(hostel_imputation$City)
hostel_imputation <- one_hot(as.data.table(hostel_imputation))
hostel_imputation <- subset( hostel_imputation, select = -c(City_hiroshima))
hostel_imputation <- rename(hostel_imputation,c('City_fukuoka_city'='City_fukuoka-city'))
#rating.band : manually
library(stringr)
hostel_imputation2 <- hostel_imputation
hostel_imputation$rating.band <- as.factor(ifelse(hostel_imputation$rating.band=='superb', '5',
                                                  ifelse(hostel_imputation$rating.band =='fabulous', '4',
                                                         ifelse(hostel_imputation$rating.band =='very good', '3',
                                                                ifelse(hostel_imputation$rating.band =='good', '2',
                                                                       ifelse(hostel_imputation$rating.band=='rating', '1', 'NA'))))))

install.packages('mltools')
library(mltools)
library(data.table)
library(tidyverse) 
library(dplyr)


#NORMALIZATION
install.packages("dgof")
library("dgof")


#Distance
#1 Kolmogoroff-Smirnoff Test to determine if each variable has a normal distribution
ks.test(hostel_imputation$Distance, "pnorm")
"""	
One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$Distance
D = 0.80748, p-value < 2.2e-16
alternative hypothesis: two-sided

From the output we can see that the test statistic is 0.80748 and the corresponding 
p-value is 2.2e-16. Since the p-value is less than .05, we reject the null hypothesis. 
We have sufficient evidence to say that the sample data does not come from a normal 
distribution.
"""
#2 Normalization (Min-max scaling method)
"""
Another efficient way of Normalizing values is through the Min-Max Scaling method.
With Min-Max Scaling, we scale the data values between a range of 0 to 1 only. Due to 
this, the effect of outliers on the data values suppresses to a certain extent. 
Moreover, it helps us have a smaller value of the standard deviation of the data scale.
In the below example, we have used 'caret' library to pre-process and scale the data. 
The preProcess() function enables us to scale the value to a range of 0 to 1 using 
method = c('range') as an argument. The predict() method applies the actions of the 
preProcess() function on the entire data frame as shown below.
"""
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$Distance), method=c("range"))
hostel_imputation$Distance <- predict(process, as.data.frame(hostel_imputation$Distance))


#summary.score
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$summary.score, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$summary.score
D = 0.99903, p-value < 2.2e-16
alternative hypothesis: two-sided

From the output we can see that the test statistic is 0.99903 and the corresponding 
p-value is 2.2e-16. Since the p-value is less than .05, we reject the null hypothesis. 
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$summary.score), method=c("range"))
hostel_imputation$summary.score <- predict(process, as.data.frame(hostel_imputation$summary.score))


#atmosphere
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$atmosphere, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$atmosphere
D = 0.98526, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$atmosphere), method=c("range"))
hostel_imputation$atmosphere <- predict(process, as.data.frame(hostel_imputation$atmosphere))


#cleanliness
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$cleanliness, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$cleanliness
D = 0.99658, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$cleanliness), method=c("range"))
hostel_imputation$cleanliness <- predict(process, as.data.frame(hostel_imputation$cleanliness))


#facilities
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$facilities, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$facilities
D = 0.99069, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$facilities), method=c("range"))
hostel_imputation$facilities <- predict(process, as.data.frame(hostel_imputation$facilities))


#location.y :
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$location.y, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$location.y
D = 0.99703, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$location.y), method=c("range"))
hostel_imputation$location.y <- predict(process, as.data.frame(hostel_imputation$location.y))


#security
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$security, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$security
D = 0.99409, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$security), method=c("range"))
hostel_imputation$security <- predict(process, as.data.frame(hostel_imputation$security))


#staff
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$staff, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$staff
D = 0.99118, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$staff), method=c("range"))
hostel_imputation$staff <- predict(process, as.data.frame(hostel_imputation$staff))



#valueformoney
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$valueformoney, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$valueformoney
D = 0.99997, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$valueformoney), method=c("range"))
hostel_imputation$valueformoney <- predict(process, as.data.frame(hostel_imputation$valueformoney))



#lon
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$lon, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$lon
D = 1, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$lon), method=c("range"))
hostel_imputation$lon <- predict(process, as.data.frame(hostel_imputation$lon))



#lat
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$lat, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$lat
D = 0.99706, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$lat), method=c("range"))
hostel_imputation$lat <- predict(process, as.data.frame(hostel_imputation$lat))



#Distance_round
#1 Kolmogoroff-Smirnoff Test 
ks.test(hostel_imputation$Distance_round, "pnorm")
"""
	One-sample Kolmogorov-Smirnov test

data:  hostel_imputation$Distance_round
D = 0.8449, p-value < 2.2e-16
alternative hypothesis: two-sided
"""
#2 Normalization (Min-max Scaling method)
library(caret)
process <- preProcess(as.data.frame(hostel_imputation$Distance_round), method=c("range"))
hostel_imputation$Distance_round <- predict(process, as.data.frame(hostel_imputation$Distance_round))


##Variable selection
library(psych)

corr_plot <- function(data, city){
  if (city == 'all') {
    hostel_imputation_ <- data  %>% filter(price.from <= 12750)
  }
  if (city != 'all') {
    hostel_imputation_ <- data  %>% filter(price.from <= 12750) %>% filter(City == city)
  }
  corPlot(hostel_imputation_[, unlist(lapply(hostel_imputation_, is.numeric))], cex = 1, 
          scale = FALSE, stars = TRUE)
}

#tranform the df to tbl_df :
hostel_imputation <- as_tibble(hostel_imputation)
corr_plot(data=hostel_imputation, city="all")


#corr with the target (price.from)
'''
City_fukuoka_city = 0.06
City_kyoto = -0.15
City_osaka = -0.11
City_tokyo = 0.21
Distance = -0.04
summary.score = 0.13
atmosphere = 0.13
cleanliness = 0.16
facilities = 0.09
location.y = 0.11
security = 0.11
staff = 0.13
valueformoney = 0.02
lon = 0.08
lat = 0.02
Distance_round = -0.03
'''
#select by corr
'''
drop :
City_osaka, lon, atmosphere, summary.score, facilities, security, staff, valueformoney
'''
hostel_imputation <- subset( hostel_imputation, select = -c(City_osaka, lon, atmosphere, summary.score, facilities, security, staff, valueformoney))
summary(hostel_imputation)


install.packages("forecastML")
library(forecastML)
library(dplyr)
library(DT)
library(ggplot2)
install.packages("glmnet")
library(glmnet)


#split test and train 
#75% of the sample size
smp_size <- floor(0.75 * nrow(hostel_imputation))
# set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(hostel_imputation)), size = smp_size)
train <- hostel_imputation[train_ind, ]
test <- hostel_imputation[-train_ind, ]
dim(train)
dim(test)



#2/MODELING


#1 LINEAR REGRESSION

lr = lm(price.from ~ City_fukuoka_city + City_kyoto + City_tokyo + Distance + cleanliness + location.y + lat + Distance_round , data = train)
summary(lr)
#1.2 Model evaluation
#Step 1 - create the evaluation metrics function
eval_metrics = function(model, df, predictions, target){
  resids = df[,target] - predictions
  resids2 = resids**2
  N = length(predictions)
  r2 = as.character(round(summary(model)$r.squared, 2))
  adj_r2 = as.character(round(summary(model)$adj.r.squared, 2))
  print(adj_r2) #Adjusted R-squared
  print(as.character(round(sqrt(sum(resids2)/N), 2))) #RMSE
}
# Step 2 - predicting and evaluating the model on train data
predictions = predict(lr, newdata = train)
eval_metrics(lr, train, predictions, target = 'price.from')
# Step 3 - predicting and evaluating the model on test data
predictions = predict(lr, newdata = test)
eval_metrics(lr, test, predictions, target = 'price.from')
"""
On the other hand, R-squared value is around 9 percent for both train and test data, 
which indicates bad performance
"""
#1.3 Regularization
"""
Linear regression algorithm works by selecting coefficients for each independent variable 
that minimizes a loss function. However, if the coefficients are large, they can lead to 
over-fitting on the training dataset, and such a model will not generalize well on the 
unseen test data. To overcome this shortcoming, we'll do regularization, which penalizes 
large coefficients. The following sections of the guide will discuss various regularization 
algorithms
"""
cols_reg = c('City_fukuoka_city', 'City_kyoto', 'City_tokyo', 'Distance', 'cleanliness', 'location.y', 'lat', 'Distance_round', 'price.from')
dummies <- dummyVars(price.from ~ ., data = hostel_imputation[,cols_reg])
train_dummies = predict(dummies, newdata = train[,cols_reg])
test_dummies = predict(dummies, newdata = test[,cols_reg])
print(dim(train_dummies)); print(dim(test_dummies))



#2 RIDGE REGRESSION

library(glmnet)
x = as.matrix(train_dummies)
y_train = train$price.from
x_test = as.matrix(test_dummies)
y_test = test$price.from
lambdas <- 10^seq(2, -3, by = -.1)
ridge_reg = glmnet(x, y_train, nlambda = 25, alpha = 0, family = 'gaussian', lambda = lambdas)
summary(ridge_reg)
cv_ridge <- cv.glmnet(x, y_train, alpha = 0, lambda = lambdas)
optimal_lambda <- cv_ridge$lambda.min
optimal_lambda
# Compute R^2 from true and predicted values
eval_results <- function(true, predicted, df) {
  SSE <- sum((predicted - true)^2)
  SST <- sum((true - mean(true))^2)
  R_square <- 1 - SSE / SST
  RMSE = sqrt(SSE/nrow(df))
  # Model performance metrics
  data.frame(
    RMSE = RMSE,
    Rsquare = R_square
  )
}
# Prediction and evaluation on train data
predictions_train <- predict(ridge_reg, s = optimal_lambda, newx = x)
eval_results(y_train, predictions_train, train)
# Prediction and evaluation on test data
predictions_test <- predict(ridge_reg, s = optimal_lambda, newx = x_test)
eval_results(y_test, predictions_test, test)



#3 LASSO REGRESSION

lambdas <- 10^seq(2, -3, by = -.1)
# Setting alpha = 1 implements lasso regression
lasso_reg <- cv.glmnet(x, y_train, alpha = 1, lambda = lambdas, standardize = TRUE, nfolds = 5)
# Best 
lambda_best <- lasso_reg$lambda.min 
lambda_best
lasso_model <- glmnet(x, y_train, alpha = 1, lambda = lambda_best, standardize = TRUE)
predictions_train <- predict(lasso_model, s = lambda_best, newx = x)
eval_results(y_train, predictions_train, train)
predictions_test <- predict(lasso_model, s = lambda_best, newx = x_test)
eval_results(y_test, predictions_test, test)



#4 ELASTICNET REGRESSION

# Set training control
train_cont <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 5,
                           search = "random",
                           verboseIter = TRUE)
# Train the model
elastic_reg <- train(price.from ~ .,
                     data = train,
                     method = "glmnet",
                     preProcess = c("center", "scale"),
                     tuneLength = 10,
                     trControl = train_cont)
# Best tuning parameter
elastic_reg$bestTune
# Make predictions on training set
predictions_train <- predict(elastic_reg, x)
eval_results(y_train, predictions_train, train) 
# Make predictions on test set
predictions_test <- predict(elastic_reg, x_test)
eval_results(y_test, predictions_test, test)



#5 SVM REGRESSION

library(e1071)
model = svm(price.from ~ ., data = hostel_imputation)
set.seed(1)
library(caret)
install.packages('kernlab')
library(kernlab)
model <- train(
  price.from ~ .,
  data = hostel_imputation,
  method = 'svmRadial'
)
model
#5.2 pre-processing with Caret
set.seed(1)
model2 <- train(
  price.from ~ .,
  data = hostel_imputation,
  method = 'svmRadial',
  preProcess = c("center", "scale")
)
model2
#5.3
set.seed(1)
inTraining <- createDataPartition(hostel_imputation$price.from, p = .80, list = FALSE)
training <- hostel_imputation[inTraining,]
testing  <- hostel_imputation[-inTraining,]
set.seed(1)
model3 <- train(
  price.from ~ .,
  data = training,
  method = 'svmRadial',
  preProcess = c("center", "scale")
)
model3
test.features = subset(testing, select=-c(price.from))
test.target = subset(testing, select=price.from)[,1]
predictions = predict(model3, newdata = test.features)
# RMSE
sqrt(mean((test.target - predictions)^2))









