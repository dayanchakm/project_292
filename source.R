#load packages. install if missing
if(!require(ggplot2)) install.packages("ggplot2"); library(ggplot2)
if(!require(gganimate)) install.packages("gganimate"); library(gganimate)
if(!require(plotly)) install.packages("plotly"); library(plotly)
if(!require(dplyr)) install.packages("dplyr"); library(dplyr)
if(!require(reshape2)) install.packages("reshape2"); library(reshape2)
if(!require(shinythemes)) install.packages("shinythemes"); library(shinythemes)
if(!require(gifski)) install.packages("gifski"); library(gifski)

#read data with N/A values as NA
data_2018 <- read.csv("data/2018.csv", na.strings = c("N/A"))
data_2019 <- read.csv("data/2019.csv", na.strings = c("N/A"))
#combine data adding year
data18 <- data_2018 %>%
  mutate("Year" = 2018)
data19 <- data_2019 %>%
  mutate("Year" = 2019)
data_all <- rbind(data18, data19)

# store country names
countries <- sort(as.vector(data_2019$Country.or.region))
# store column names. exclude rank and country name
variables <- names(data_2019)[ -c(1,2)]