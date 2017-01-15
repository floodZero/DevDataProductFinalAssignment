library(shiny)

shinyUI(fluidPage(
  titlePanel("mtcars data correlation between MPG and other variables"),
  tabsetPanel(tabPanel("EDA",
                       fluidPage(
                         br(),
                         sidebarLayout(sidebarPanel(
                           uiOutput('radioEDAFeature'),
                           uiOutput('graphType')
                         ),
                         mainPanel(plotOutput("edaPlot")))
                       )),
              tabPanel("Regression Analysis",
                       fluidPage(
                         br(),
                         sidebarLayout(sidebarPanel(
                           radioButtons("fitAutomation", "How to  select model",
                                        choices = c("Manual", "Automated")
                           ),
                           # uiOutput('chkbxModelFeature'),
                           checkboxGroupInput("chkModelFeature", "Select Feature to examine",
                                    choices = c("am", "cyl", "disp"),
                                    selected = "am"
                                    ),
                           actionButton("buildButton", "Build")
                         ),
                         mainPanel(
                           h3("Model"),
                           verbatimTextOutput("modelSummary"),
                           h3("Diagnostics"),
                           plotOutput("diagnosticsPlot")))
                       )))
))
