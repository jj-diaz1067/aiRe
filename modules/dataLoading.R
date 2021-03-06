# https://www.rstudio.com/resources/cheatsheets/

dataLoadingUI <- function(id, label = "Data Loading") {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
             actionButton(ns('Delete'),"Borrar Actual"),
             radioButtons(ns("desiredFormat"), "Por favor elija el formato de sus datos",
                          choices = c("Documento por contaminante" = 1,"Documento por estación" = 2 ),
                          selected = 1, inline = FALSE),
             radioButtons(ns("temporality"), "Por favor elija la perioricidad de sus datos",
                          choices = c("Automática (horaria)" = 1,"Manual" = 2 ),
                          selected = 1, inline = FALSE),
             uiOutput(ns('optionsUI'))),
    mainPanel(
             selectInput(ns("dataBase"), label = h3("Seleccione una base datos"), 
                         choices = list("Ninguna" = 0, "PM2.5" = 1, "PM10" = 2), 
                         selected = 1),
             hr(),
             dataTableOutput(ns("summary")))
  )
}

dataLoading <- function(input, output, session) {
  
  newDatabase <- observe({
    input$Delete
    if(input$Delete == 0)return(NULL)
    isolate({
      if(input$Delete>=1){
    database$datapm10 = data.frame(Fecha...Hora = character())
    database$datapm2.5 = data.frame(Fecha...Hora = character())
    database$data = NULL
      }
    })
  })
  # Database is an object with the following atributes
  # datapm10: dataframe with the pm10 data
  # datapm2.5: dataframe with the pm2.5 data
  # data: dataframe with the current data the system is working with
  # currentData: name of the data currently loades in data 
  # dataType: named array with databases name and it's type: auto' or 'manual' according of the type of the data, NA if this value has not been set
  database <- reactiveValues(datapm10 = read.csv("databases/PM10_1998_2016_Encsv.csv", sep=";", row.names=NULL, stringsAsFactors=TRUE),
                             datapm2.5 = read.csv("databases/PM2.5_1998_2016_Encsv.csv", sep=";", row.names=NULL, stringsAsFactors=TRUE),
                             data = NULL,
                             dataType = c(pm10 = NA, pm2.5 = NA),
                             dataFlags = NULL)
  database[['data']] <- database[['datapm2.5']]
  database$currentData = 'pm2.5'
  
  #TODO Change this when the database changes
  database$dataType['pm10'] = 'manual'
  database$dataType['pm2.5'] = 'auto'
  database$datapm2.5[,1] = as.POSIXct(as.character(database$data[,1]), format="%d/%m/%Y %H:%M")
  database$datapm10[,1] = as.POSIXct(as.character(database$datapm10[,1]), format="%d/%m/%Y %H:%M")
  
  switchDatabase <- observe({
    input$dataBase
    if(is.null(input$dataBase))return(NULL)
    isolate({
      if(input$dataBase == 1){
        database$currentData = "pm2.5"
        database$data = database$datapm2.5
      }else if(input$dataBase == 2){
        database$currentData = "pm10"
        database$data = database$datapm10
      }
    })
  })
  
  
  changeDatabase <- observe({
    input$add
    if(is.null(input$add))return(NULL)
    if(input$add== 0)return(NULL)
    isolate({
      #Document per contaminant
      if(input$desiredFormat == 1){
        if(input$newdatabase == 2){
          database$datapm10 = read.csv(file$datapath, sep=";", row.names=NULL, stringsAsFactors=TRUE)
          database$datapm10["Fecha...Hora"] = as.POSIXct(database$datapm10[["Fecha...Hora"]], format="%d/%m/%Y %H:%M")
          database$data = database$datapm10
          database$currentData = "pm10"
        }
      }
      if(input$desiredFormat == 2){
        file <- input$file
        if (is.null(file)){
          return(NULL)
        }
        data = read.csv(file$datapath,sep = ";", stringsAsFactors = F)
        if(input$newdatabase == 1){
          newData = as.list(database$datapm10)
          newData[["Fecha...Hora"]] = as.character(data[,1])
          newData[input$StationName] = data['PM10']
          database$datapm10 = as.data.frame(newData)
          database$datapm10["Fecha...Hora"] = as.POSIXct(database$datapm10[["Fecha...Hora"]], format="%d/%m/%Y %H:%M")
          database$data = database$datapm10
          database$currentData = "pm10"
          if(temporality== 1){
            database$dataType['pm10'] = 'auto'
          } else{
            database$dataType['pm10'] = 'manual'
          }
        }
        if(input$newdatabase == 1){
          newData = as.list(database$datapm2.5)
          newData[["Fecha...Hora"]] = as.character(data[,1])
          newData[input$StationName] = data['PM2.5']
          database$datapm2.5 = as.data.frame(newData)
          database$datapm2.5["Fecha...Hora"] = as.POSIXct(database$datapm2.5[["Fecha...Hora"]], format="%d/%m/%Y %H:%M")
          database$data = database$datapm2.5
          database$currentData = "pm2.5"
          if(temporality== 1){
            database$dataType['pm2.5'] = 'auto'
          } else{
            database$dataType['pm2.5'] = 'manual'
          }
 
        }

      }
    })
    
  })
  
  output$summary = renderDataTable({
    if(input$dataBase == 1){
      database$data = database$datapm2.5
      database$data
    }
    else if (input$dataBase == 2){
      database$data = database$datapm10
      database$data
    }
  })
  
  output$optionsUI <- renderUI({
    ns <- session$ns
    if(input$desiredFormat == 2){
      tagList(
        textInput(ns('StationName'), "Nombre de la estación"),
        fileInput(ns('file'), 'Por favor suba un archivo CSV con el formato sugerido',
                  accept=c('text/csv','.csv')),
        selectInput(ns('newdatabase'), "Seleccione contaminante", c( "PM2.5" = 1,"PM10" = 2)),
        actionButton(ns('add'),"Agregar")
      )
    }else{
      tagList(
        fileInput(ns('file'), 'Por favor suba un archivo CSV con el formato sugerido',
                  accept = c('text/csv','.csv')),
        selectInput(ns('newdatabase'), "Seleccione contaminante", c( "PM2.5" = 1,"PM10" = 2)),
        actionButton(ns('add'),"Agregar")
      )
    }
  })
  return(database)
}

