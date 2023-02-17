server <- function(input, output) {
  # function to select data (2018 or 2019)
  which_year <- function(x){
    if (x == 2018) return(data_2018)
    else return(data_2019)
  }
  ##########################
  ## Code for FIRST PANEL ##
  ##########################
  
  # Datatable output
  output$top_out <- renderTable({
    # request data for input year
    data_selected <- which_year(input$year1)
    # rename vars to make table fit
    names(data_selected) <- c("Overall Rank",	"Country or Region",	"Score", "GDP per capita",	
                              "Social Support",	"Healthy life expectancy",	"Freedom to make life choices",	
                              "Generosity",	"Perceptions of corruption")
    # determine if user is searching
    if(!(input$search == "")){
      # check if reverse ordering is true
      if(input$reverse_order == TRUE){
        # low values first
        dat <- data_selected[order(data_selected[, input$var], decreasing = FALSE),]
        dat <- cbind("Variable Rank" = 1:156, dat)
        # select countries matching the search
        a <- grep(input$search, dat[, 3], ignore.case = TRUE)
        dat[a,]
      }
      else {
        # high values first
        dat <- data_selected[order(data_selected[, input$var], decreasing = TRUE),]
        dat <- cbind("Variable Rank" = 1:156, dat)
        # select countries matching the search
        a <- grep(input$search, dat[,3], ignore.case = TRUE)
        dat[a,]
      }
      
    } else {
      # check if reverse ordering is true
      if(input$reverse_order == TRUE){
        # low values first
        dat <- data_selected[order(data_selected[, input$var], decreasing = FALSE),] %>%
          head(input$top)
        cbind("Variable Rank" = 1:input$top, dat)}
      else {
        # high values first
        dat <- data_selected[order(data_selected[, input$var], decreasing = TRUE),] %>%
          head(input$top)
        cbind("Variable Rank" = 1:input$top, dat)}
    }
  },bordered = TRUE, hover = TRUE)
  
  ###########################
  ## Code for SECOND PANEL ##
  ###########################
  
  # Stacked bar plot output
  output$barplot_out <- renderPlotly({
    # wait for click
    if(input$render == 0)
      return()
    isolate({
      # get user input countries' data from selected year
      data_tem <- which_year(input$year2) %>%
        filter(Country.or.region %in% input$country)
      # reshape data to fit bar plot
      data_reshaped <- melt(data_tem[, -c(1,3)], id.vars = "Country.or.region")
      # make bar plot with respect to variable values
      p1 <- ggplot(data_reshaped, aes(x = Country.or.region, y = value, fill = variable)) + 
        labs(x = "Countries", y="Sum of Variable Scores") +
        geom_bar(stat = "identity")
      # use plotly to make the plot interactive
      ggplotly(p1)
    })
  })
  
  # gif output 
  output$gif_out <- renderImage({
    # wait for click
    if(input$render == 0)
      return()
    isolate({
      # make a file with gif extension
      plot_outfile <- tempfile(fileext=".gif")
      # get data of countries matching user input
      selected_countries <- data_all %>%
        filter(Country.or.region %in% input$country)
      # plot scores of countries for each year
      p2 <- ggplot(selected_countries, aes(x = Year,y= Score, color = Country.or.region)) +
        geom_line() + geom_point() + transition_reveal(Year)
      # make it animate
      animate(p2, duration = 2, fps = 2, renderer = gifski_renderer())
      # save as gif
      anim_save("plot_outfile.gif")
      # get the gif
      list(src = "plot_outfile.gif",contentType = 'image/gif')
    })
  })
  
  ##########################
  ## Code for THIRD PANEL ##
  ##########################
  
  # plot selected columns and insert linear model line with conf.int
  plot_scatter <- reactive({
    which_year(input$year3) %>%
      ggplot(aes_string(input$x, input$y)) + geom_point() + geom_smooth(method = lm)})
  # Scatter plot output
  output$scatterplot_out <- renderPlotly({
    # use plotly to make the plot interactive
    ggplotly(plot_scatter())
  })
  
  # test correlation of user input columns
  correlate <- reactive({
    data_selected <- which_year(input$year3)
    t <- cor.test(data_selected[, input$x],data_selected[, input$y])
  })
  # Correlation coefficient output
  output$cor_out <- renderText(paste("r =", round(correlate()$estimate,3)))
  # P-value output
  output$pval_out <- renderText(paste("p-value =", round(correlate()$p.value,4)))
  
  ###########################
  ## Code for FOURTH PANEL ##
  ###########################
  
  # predict score of a made up country
  country_score<- reactive({
    # Note: lm() function is used to form this model
    rating_scale <- 10
    (1.7952 + input$gdp*(1.684/rating_scale)*0.7754 + (input$ssupport*(1.624/rating_scale)*1.1242) + 
        (input$lifexp*(1.141/rating_scale)*1.0781) + (input$ftmlc*(0.631/rating_scale)*1.4548) + 
        (input$genr*(0.566/rating_scale)*0.4898) + (input$crrp*(0.453/rating_scale)*0.9723))
  })
  # Score output
  output$score_out <- renderText({
    # make it zero if all user input is zero
    paste("Score:", if(country_score() == 1.7952){0} else country_score())
  })
  
  # calculate rank of user's country
  country_rank <- reactive({
    # take only Country names and scores from the data.
    d <- data.frame("Country" = as.vector(data_2019$Country.or.region), 
                    "Score" = data_2019$Score, stringsAsFactors = FALSE)
    # add user's country
    d <- rbind(d, c(input$CountryName, country_score()))
    # order. high scores first
    d <- d[order(d$Score, decreasing = TRUE),]
    # get index of user's country
    which(d$Country %in% input$CountryName)
  })
  
  # Rank output
  output$rank_out <- renderText({
    if(input$cal == 0)
      return()
    isolate({
      # prompt to name the country if not
      if(input$CountryName == "") paste("Name the country to see the rank!")
      # do not rank if not rated
      else if(country_score() == 1.7952)
        paste("Not ranked: Score is zero!")
      # first place
      else if(country_rank() == 1) paste(input$CountryName, "is the happiest country in the world!")
      # make sure it is not last place
      else if(!(country_rank() == 157))
        paste0(input$CountryName, " is the ", country_rank(), ". happiest country in the world! ",
               "Just between ", data_2019$Country.or.region[country_rank()], " and " ,
               data_2019$Country.or.region[country_rank()+1], ".")
      # last place
      else paste(input$CountryName, "is the least happy country in the world!")
    })
  })
}