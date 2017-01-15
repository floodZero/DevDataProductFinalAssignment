library(shiny)
library(ggplot2)
library(dplyr)

shinyServer(function(input, output) {
  # Initialize data
  dataset <- reactive({
    data("mtcars")
    mtcars$am <- as.factor(mtcars$am)
    levels(mtcars$am) <-c("Automatic", "Manual")
    mtcars$cyl <- as.factor(mtcars$cyl)
    mtcars$vs <- as.factor(mtcars$vs)
    mtcars$gear <- as.factor(mtcars$gear)
    mtcars$carb <- as.factor(mtcars$carb)
    
    mtcars
  })
  
  ## Part of Tab 1
  output$radioEDAFeature <- renderUI({
    dataMtcars <- dataset()
    
    radioButtons("edaFeature", "Select Feature to examine",
                 choices = names(dataMtcars)[grep("mpg", x= names(dataMtcars), invert = TRUE)],
                 selected = "am"
                 )
  })
  
  output$graphType <- renderUI({
    selectedVar <-ifelse(is.null(input$edaFeature), "am", input$edaFeature)
    
    if (is.factor(dataset()[selectedVar][,1])) {
      radioButtons("graphType", "Shape of Graphs", 
                   choices = c("Violin", "Boxplot")
      )
    } else {
      radioButtons("graphType", "Shape of Graphs", 
                   choices = c("Dotplot")
      )
    }
  })

  output$edaPlot <- renderPlot({
    selectedGraphType <- ifelse(is.null(input$graphType), "Violin", input$graphType)

    plotGeom <- switch(selectedGraphType,
                       "Violin" = geom_violin(size=1),
                       "Boxplot" = geom_boxplot(size=1),
                       "Dotplot" = geom_dotplot()
    )

    xAxis <-ifelse(is.null(input$edaFeature), "am", input$edaFeature)
    dataMtcars <- dataset()

    edaplot <- ggplot(data=dataMtcars,aes_string(y="mpg",x=xAxis,fill=xAxis))
    if (!is.factor(dataMtcars[xAxis][,1])) {
      edaplot <- ggplot(data=dataMtcars,aes_string(y="mpg",x=xAxis))
    }
    edaplot <- edaplot +
      plotGeom +
      xlab(xAxis) +
      ylab("Mpg")

    edaplot
  })

  ## Part of Tab 2
  output$chkbxModelFeature <- renderUI({
    dataMtcars <- dataset()
    checkboxGroupInput("chkModelFeature", "Select Feature to examine",
                 choices = names(dataMtcars)[grep("mpg", x= names(dataMtcars), invert = TRUE)],
                 selected = "am"
    )
  })
  
  model <- reactive({
    fit <- NULL
    dataMtcars <- dataset()
    if (input$fitAutomation == "Manual") {
      factors <- ifelse(is.null(input$chkModelFeature), c("am"), input$chkModelFeature)
      formula <- paste("mpg~", paste(factors, collapse="+")) 
      fit <- lm(formula, data = dataMtcars)
    }
    else if(input$fitAutomation == "Automated") {
      fit = step(lm(mpg ~ ., data = dataMtcars),trace=0,steps=100)
    }
    
    fit
  })

  output$modelSummary <- renderPrint({
    input$buildButton
    
    isolate({
      fit <- model()
      summary(fit)
    })
  })
  
  output$diagnosticsPlot <- renderPlot({
    input$buildButton
    
    isolate({
      fit <- model()
      par(mfrow = c(2,2))
      plot(fit)
    })
  })
})
