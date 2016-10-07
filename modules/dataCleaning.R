library(shiny)
dataCleaningUI <- function(id){
  ns <- NS(id) 
  titlePanel("Limpieza de datos")
  sidebarLayout(
    sidebarPanel(
      selectInput(ns("dataBase"), label = h3("Seleccione una base datos"), 
                  choices = list("PM2.5" = 1, "PM10" = 2), 
                  selected = 1),
      hr(),
      checkboxGroupInput(ns("generalRules"), label = h3("Reglas generales"), 
                         choices = list("Restriccion de cadenas de texto" = 1, "Valores negativos y ceros" = 2, "Limite de detección del equipo" = 3)
                         ),
      checkboxGroupInput(ns("particularRules"), label = h3("Reglas particulares a PM2.5"), 
                         choices = list("Asegurar PM10 > PM2.5" = 1)
      ),
      checkboxGroupInput(ns("densityRules"), label = h3("Reglas de densidad de datos"), 
                         choices = list("Eliminar datos aislados" = 1)
      )
      
    ),
    mainPanel(
      uiOutput(ns("summary"))
    )
  )
}

# dataBasePM2.5 = read.csv("PM2.5_1998_2014_Encsv.csv", sep=";", row.names=NULL, stringsAsFactors=TRUE)
dataCleaning <- function(input, output, session){
  datasetToUse <- reactive({
    
  })
  
  output$summary <- renderUI({
    
  })
}