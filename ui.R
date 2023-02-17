library(shiny)
source(file = 'source.R')
ui <- fluidPage(
  theme = shinytheme("flatly"),
  navbarPage(title = "Don't worry, be HAPPY!",
             ### INTRO PANEL ###
             tabPanel(title = "About App",
                      mainPanel(
                        br(),
                        h2("What is this app?"),
                        br(),
                        p("In this R Shiny application that we have created, a variety of activities can be carried 
                          out on a large scale. Our application gathers data on the well-being of people in different 
                          countries. The data information tab provides outcomes such as the total happiness score of 
                          a country, life expectancy, social support, and other factors, based on the year and the 
                          number of countries selected. Additionally, the variable chosen in the program can be sorted 
                          either in increasing or decreasing order based on the number of countries the user selects."),
                        br(),
                        p("Furthermore, the changes in the selected countries over the years can be observed through 
                          the presented graph. The graphic also displays the components that contribute to the given 
                          results. Users can compare all countries by selecting the desired variable, which is displayed 
                          in a different color. The summation of all the colors gives us the final score of the country. 
                          The 'Sum of Variable Scores' is consistent with the country's ranking, which was sorted in the 
                          first part of the application."),
                        br(),
                        p("The 'Relation between Variables' tab displays a scatter plot and the linear relationship 
                          (if any) between the independent variable x and the dependent variable y. Users can observe 
                          the positive or negative relationship through the drawn line, and changes over time can be 
                          seen by selecting the year. The shaded area surrounding the line represents the confidence 
                          interval. A narrower shaded area around the line indicates greater confidence in our data 
                          falling within the same range."),
                        br(),
                        p("In the final part of the application, it's up to the user. Users can choose the variables 
                          for a specific country and compare its ranking to other countries around the world. The final 
                          score is crucial in determining the ranking, and the coefficients for each component are 
                          provided in the formula. Have fun!"),
                        br()
                      )
             ),
             
             ### FIRST PANEL ###
             tabPanel(title = "Data Information",
                      sidebarPanel(width = "3",
                                   br(),
                                   selectInput(inputId = "year1", 
                                               label = "Year:",
                                               choices = c(2018, 2019)),
                                   numericInput(inputId = "top",
                                                label = "Number of Countries:",
                                                value = 10, min = 0, max = 156, step = 5),
                                   selectInput(inputId = "var", 
                                               label = "Sort via variable:",
                                               choices = c("Score", "GDP per capita",	
                                                           "Social Support",	"Healthy life expectancy",	"Freedom to make life choices",	
                                                           "Generosity",	"Perceptions of corruption")),
                                   checkboxInput(inputId = "reverse_order", 
                                                 label = "Reverse the order.", value = FALSE),
                                   HTML('<iframe width=100% height="315" src="https://www.youtube.com/embed/9OQ1sZE6bTg" 
                                   frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; 
                                        picture-in-picture" allowfullscreen></iframe>')
                      ),
                      mainPanel(
                        tags$blockquote("The happiness scores and rankings use data from the Gallup World Poll. 
                                        The scores are based on answers to the main life evaluation question asked in the poll. 
                                        This question, known as the Cantril ladder, asks respondents to think of a ladder with 
                                        the best possible life for them being a 10 and the worst possible life being a 0 and to 
                                        rate their own current lives on that scale."),
                        textInput(inputId = "search",
                                  label = "Search:",
                                  placeholder = "eg: Turkey"),
                        tableOutput("top_out")
                      )
             ),
             
             ### SECOND PANEL ###
             tabPanel(title = "Comparing Countries",
                      sidebarPanel(width = "auto",
                                   selectInput(inputId = "year2", label = "Year:",
                                               choices = c(2018, 2019)),
                                   selectInput(inputId = "country",
                                               multiple = TRUE,
                                               label = "Country (Select multiple to compare):",
                                               choices = countries,
                                               selected = c("Turkey", "United States", "Russia", "Finland", "China")),
                                   actionButton(inputId = "render",
                                                label = "Show Graphs"),
                                   
                                   
                      ),
                      
                      mainPanel(
                        fluidRow(
                          splitLayout(cellWidths = c("auto", "50%"),
                                      plotlyOutput("barplot_out"),
                                      imageOutput("gif_out",height = "100%")
                          )
                        ),
                        
                      ),
             ),
             
             ### THIRD PANEL ###
             tabPanel(title = "Relationship between variables",
                      sidebarPanel(
                        selectInput(inputId = "year3", label = "Year:",
                                    choices = c(2018, 2019)),
                        selectInput(inputId = "x", label = "x (independent variable)",
                                    choices = variables, selected = "GDP.per.capita"),
                        selectInput(inputId = "y", label = "y (dependent variable)",
                                    choices = variables)
                      ),
                      mainPanel(
                        plotlyOutput("scatterplot_out"),
                        textOutput("cor_out"),
                        textOutput("pval_out"),
                        helpText("Note:"),
                        helpText("r value indicates strength of relationship between variables: 
                                 Closer to 1 means strong positive relationship, closer to 0 means no 
                                 relationship and closer to -1 means strong negative relationship."),
                        helpText("If p-value is less than 0.05, it is safe to conclude that at 95% confidence
                                 level there is a relationship between variables x and y.")
                      )
             ),
             
             ### FOURTH PANEL ###
             tabPanel(title = "Create your own country!",
                      sidebarPanel(
                        textInput("CountryName", "Enter Your Country's Name"),
                        helpText("Very Weak = 0; Very Strong = 10"),
                        helpText("Higher rating means more positive!"),
                        sliderInput("gdp", "Rate your country's GDP per capita:",
                                    min = 0, max= 10, value= 0),
                        sliderInput("ssupport", "Rate your country's social support:",
                                    min = 0, max= 10 , value= 0),
                        sliderInput("lifexp", "Rate your country's healthy life expectancy:",
                                    min = 0, max= 10, value= 0),
                        sliderInput("ftmlc", "Rate your country's freedom to make life choices:",
                                    min = 0, max= 10, value= 0),
                        sliderInput("genr", "Rate your country's generosity:",
                                    min = 0, max= 10, value= 0),
                        sliderInput("crrp", "Rate your country's perceptions of corruption:",
                                    min = 0, max= 10, value= 0)
                      ),
                      mainPanel(
                        h4("You can create your utopic country, rate the variables and see the result!", color= "red"),
                        hr(),
                        tags$i("The formula used to calculate the score: 1.7952 + (GDP.per.capita*0.7754) + (Social support*1.1242) + 
                        (Healthy life expectancy*1.0781) + (Freedom to make life choices*1.4548) + (Generosity*0.4898) + 
                        (Perceptions of corruption*0.9723)"),
                        br(),
                        tags$i("The score below is used to find the rank of your country."),
                        br(),
                        textOutput("score_out"),
                        br(),
                        actionButton("cal", "Let's Go!"),
                        br(),
                        h4(tags$i(textOutput("rank_out")))
                      )
             ),
             
             ### REFERENCE PANEL ###
             tabPanel(title = "References",
                      mainPanel(
                        HTML('<img src="reference.png" alt="References">'),
                        br(),
                        br(),
                        h4(tags$i("1 -  Dataset retrived from Sustainable Development Solutions Network at Kaggle.com. 2020. 
                               World Happiness Report. [online] Available at: <https://www.kaggle.com/unsdsn/world-happiness> 
                               [Accessed 7 June 2020].")),
                        br(),
                        h4(tags$i("2 -  Ggplot2.tidyverse.org. 2020. Complete Themes - Ggtheme. [online] 
                               Available at: <https://ggplot2.tidyverse.org/reference/ggtheme.html> [Accessed 6 June 2020].")),
                        br(),
                        h4(tags$i("3 - Global happiness report. 2020. Roundtable. [online] 
                               Available at: <https://www.youtube.com/watch?v=9OQ1sZE6bTg&t=3s> [Accessed 6 June 2020].")),
                        br(),
                        h4(tags$i("4 - Plotly.com. 2020. Ggplot2 Graphing Library. [online] 
                               Available at: <https://plotly.com/ggplot2/> [Accessed 6 June 2020]..")),
                        br(),
                        h4(tags$i("5 - Shiny.rstudio.com. 2020. Shiny - Tutorial. [online] 
                               Available at: <https://shiny.rstudio.com/tutorial/>..")),
                        br(),
                        h4(tags$i("6 - Stack Overflow. 2020. 'R' Questions. [online] 
                                  Available at: <https://stackoverflow.com/questions/tagged/r>.")),
                        br(),
                        h4(tags$i("7 - Worldhappiness.report. 2020. Home. [online] 
                               Available at: <https://worldhappiness.report/> [Accessed 6 June 2020].")),
                      )
             )
  )
)