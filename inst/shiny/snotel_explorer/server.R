# load required libraries
library(shiny)
library(shinydashboard)
library(leaflet)
library(plotly)
library(DT)
library(data.table)
library(zoo)

# get the location of the package
path <- sprintf("%s/shiny/snotel_explorer", path.package("snotelr"))

# grab the latest site information from the Ameriflux site.
# use the metadata file if present and not older than 1 year!
df <- snotel_info()

myIcon <- icons(
  iconUrl = sprintf("%s/snow_icon.svg", path),
  iconWidth = 17,
  iconHeight = 17
)

# create a character field with html to call as marker
# popup. This includes a thumbnail of the site!S
df$preview <- apply(df, 1, function(x)
  paste(
    "<table width=200px, border=0px>",
    "<tr>",
    "<td><b>",
    x[3],
    "</b></td>",
    "</tr>",

    "<tr>",
    "<td>",
    "Elev.: ",
    x[9],
    " m",
    "</td>",
    "</tr>",

    "<tr>",
    "<td>",
    "Start Data: ",
    x[5],
    "</td>",
    "</tr>",

    "<tr>",
    "<td>",
    "End Data: ",
    x[6],
    "</td>",
    "</tr>",

    "</table>",
    sep = ""
  ))

# start server routine
server <- function(input, output, session) {

  # Reactive expression for the data subsetted
  # to what the user selected
  v1 <- reactiveValues()
  v2 <- reactiveValues()
  reset <- reactiveValues()
  row_clicked <- reactiveValues()

  # function to subset the site list based upon coordinate locations
  filteredData <- function() {
    if (!is.null(isolate(v2$lat))) {
      if (input$state == "ALL") {
        df[which(
          df$latitude < isolate(v1$lat) &
          df$latitude > isolate(v2$lat) &
          df$longitude > isolate(v1$lon) & df$longitude < isolate(v2$lon)
        ),]
      } else{
        df[which(
          df$latitude < isolate(v1$lat) &
          df$latitude > isolate(v2$lat) &
          df$longitude > isolate(v1$lon) &
          df$longitude < isolate(v2$lon) & df$state == input$state
        ),]
      }
    } else{
      if (input$state == "ALL") {
        return(df)
      } else{
        return(df[df$state == input$state,])
      }
    }
  }

  # fix the UI part of this code !!!!
  getValueData <- function(table) {
    nr_sites <- length(unique(table$site_id))
    output$site_count <- renderInfoBox({
      valueBox(nr_sites,
               "Sites",
               icon = icon("list"),
               color = "blue")
    })

    nr_years <- round(sum((df$end - df$start)/365, na.rm = TRUE))
    output$year_count <- renderInfoBox({
      valueBox(nr_years,
               "Snow Seasons",
               icon = icon("list"),
               color = "blue")
    })

  }

  # Use leaflet() here, and only include aspects of the map that
  # won't need to change dynamically (at least, not unless the
  # entire map is being torn down and recreated).
  output$map <- renderLeaflet({
    map <- leaflet(df) %>%
      addTiles(
        "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg",
        attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
        group = "World Imagery"
      ) %>%
      addProviderTiles("OpenTopoMap", group = "Open Topo Map") %>%
      addMarkers(lat = ~ latitude, lng = ~ longitude,
                 icon = myIcon, popup = ~ preview) %>%
      # Layers control
      addLayersControl(
        baseGroups = c("World Imagery","Open Topo Map"),
        position = c("topleft"),
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      setView(lng = -116,
              lat = 41,
              zoom = 4)
  })

  # Incremental changes to the map. Each independent
  # set of things that can change should be managed in its own observer.
  observe({

    leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>%
      addMarkers(
        lat = ~ latitude,
        lng = ~ longitude,
        icon = ~ myIcon,
        popup =  ~ preview
      )

    # update the data table in the explorer
    output$table <- DT::renderDataTable({
      tmp <- filteredData()[,-c(1,4,7:10,12)] # drop last column
      return(tmp)
    },
    selection = "single",
    options = list(
      lengthMenu = list(c(5, 10), c('5', '10')),
      pom = list('longitude')
    ),
    extensions = 'Responsive')

    # update value box
    getValueData(filteredData())

  })

  # grab the bounding box, by clicking the map
  observeEvent(input$map_click, {
    # if clicked once reset the bounding box
    # and show all data
    if (!is.null(isolate(v2$lat))) {
      # set bounding box values to NULL
      v1$lat <- NULL
      v2$lat <- NULL
      v1$lon <- NULL
      v2$lon <- NULL

      leafletProxy("map", data = filteredData()) %>%
        clearMarkers() %>%
        clearShapes() %>%
        addMarkers(
          lat = ~ latitude,
          lng = ~ longitude,
          icon = ~ myIcon ,
          popup =  ~ preview
        )

      getValueData(filteredData())

    } else{
      # grab bounding box coordinates
      # TODO: validate the topleft / bottom right order
      if (!is.null(isolate(v1$lat))) {
        v2$lat <- input$map_click$lat
        v2$lon <- input$map_click$lng
      } else{
        v1$lat <- input$map_click$lat
        v1$lon <- input$map_click$lng
        leafletProxy("map", data = filteredData()) %>%
          clearMarkers() %>%
          addMarkers(
            lat = ~ latitude,
            lng = ~ longitude,
            icon = ~ myIcon,
            popup =  ~ preview
          ) %>%
          addCircleMarkers(
            lng = isolate(v1$lon),
            lat = isolate(v1$lat),
            color = "red",
            radius = 3,
            fillOpacity = 1,
            stroke = FALSE
          )
      }
    }

    # if the bottom right does exist
    if (!is.null(isolate(v2$lat))) {
      # subset data based upon topleft / bottomright
      tmp <- filteredData()

      # check if the dataset is not empty
      if (dim(tmp)[1] != 0) {
        # update the map
        leafletProxy("map", data = tmp) %>%
          clearMarkers() %>%
          addMarkers(
            lat = ~ latitude,
            lng = ~ longitude,
            icon = ~ myIcon ,
            popup =  ~ preview
          ) %>%
          addRectangles(
            lng1 = isolate(v1$lon),
            lat1 = isolate(v1$lat),
            lng2 = isolate(v2$lon),
            lat2 = isolate(v2$lat),
            fillColor = "transparent",
            color = "grey"
          )

        # update the data table in the explorer
        output$table <- DT::renderDataTable({
          tmp <- filteredData()[, -c(1,4,7:10,12)] # drop last column
          return(tmp)
        },
        selection = "single",
        options = list(
          lengthMenu = list(c(5, 10), c('5', '10')),
          pom = list('longitude')
        ),
        extensions = c('Responsive'))

        # update the value box
        getValueData(filteredData())

      } else{
        # set bounding box values to NULL
        v1$lat <- NULL
        v2$lat <- NULL
        v1$lon <- NULL
        v2$lon <- NULL

        leafletProxy("map", data = filteredData()) %>%
          clearMarkers() %>%
          clearShapes() %>%
          addMarkers(
            lat = ~ latitude,
            lng = ~ longitude,
            icon = ~ myIcon,
            popup =  ~ preview
          )
      }
    }
  })

  downloadData <- function(myrow) {
    # if nothing is selected return NULL
    if (length(myrow) == 0) {
      return(NULL)
    }

    # grab the table
    df <- filteredData()

    # grab the necessary parameters to download the site data
    site <- df$site_id[as.numeric(myrow)]

    # Create a Progress object
    progress <- shiny::Progress$new()

    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())

    # download data message
    progress$set(message = "Status:", value = 0)
    progress$set(value = 0.2, detail = "Reading SNOTEL data")

    # download phenocam data from the server
    # first formulate a url, then download all data

    # check if previously downloaded data exists and load these
    # instead of reprocessing
    status <- list.files(getwd(),
                        pattern = sprintf("^snotel_%s\\.csv$", site))[1]

    # if the file does not exist, download it
    if (is.na(status)) {
      data <- try(snotel_download(site_id = site,
                                  internal = TRUE))
    }

    # if the download fails, print NULL
    if (inherits(data, "try-error")) {
      progress$set(value = 0.3, detail = "download error!")
      return(NULL)
    } else{
      
      # smooth productivity values
      progress$set(value = 0.5, detail = "Calculating snow phenology")

      # nee transition dates
      transitions <- snotel_phenology(data)

      # combine data in nested list
      output <- list(data, transitions)

      # return this structure
      progress$set(value = 1, detail = "Done")
      
      # return data
      return(output)
    }
  }

  # observe the state of the table, if changed update the data
  inputData <- reactive({
    downloadData(as.numeric(input$table_row_last_clicked))
  })

  # plot the data / MESSY CLEAN UP!!!
  output$time_series_plot <- renderPlotly({

    # set colours
    labels_covariate_col <- "rgb(231,41,138)"
    covariate_col <- "rgba(128,128,128,0.5)"
    primary_col <- "rgba(51,102,255,0.8)"
    envelope_col <- "rgba(128,128,128,0.05)"
    ltm_col <- "rgba(128,128,128,0.8)"

    # set axis labels
    labels <- c("SWE (mm)" = "snow_water_equivalent",
               "temperature (C)" = "temperature_mean",
               "precipitation (mm)" = "precipitation")
    primary_label <- names(labels)[which(labels == input$primary)]
    covariate_label <- names(labels)[which(labels == input$covariate)]

    # load data
    data <- inputData()
    plot_data <- data[[1]]
    transition_data <- data[[2]]

    if ( is.null(plot_data) || nrow(plot_data) == 0 ) {
      # format x-axis
      ax <- list(
        title = "",
        zeroline = FALSE,
        showline = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE
      )

      # Error message depending on the state of the table
      # if selected and no data, or no selection
      if (length(input$table_row_last_clicked) != 0) {
        p <- plot_ly(
          x = 0,
          y = 0,
          text = "NO DATA AVAILABLE, SELECT A NEW SITE FOR PLOTTING",
          mode = "text",
          type = "scatter",
          textfont = list(color = '#000000', size = 16)
        ) %>%
          layout(xaxis = ax, yaxis = ax)
      } else{
        p <- plot_ly(
          x = 0,
          y = 0,
          text = "SELECT A SITE FOR PLOTTING",
          mode = "text",
          type = "scatter",
          textfont = list(color = '#000000', size = 16)
        ) %>%
          layout(xaxis = ax, yaxis = ax)
      }

    } else{
      # subset data according to input / for some reason I can't call the
      # data frame columns using their input$... name
      plot_data$primary <- 
        plot_data[, which(colnames(plot_data) == input$primary)]

      # include cummulative values in plotting, should be easier to interpret
      # the yearly summary plots
      plot_data$covariate <- 
        plot_data[, which(colnames(plot_data) == input$covariate)]

      # gap fill the data under consideration
      plot_data$primary <- zoo::na.approx(plot_data$primary, na.rm = FALSE)
      plot_data$covariate <- zoo::na.approx(plot_data$covariate, na.rm = FALSE)

      # convert to date
      plot_data$date <- as.Date(plot_data$date)
      plot_data$doy <-as.numeric(format(plot_data$date,"%j"))
      plot_data$year <- as.numeric(format(plot_data$date,"%Y"))

      # convert to transition dates
      first_snow_melt <- as.Date(sprintf("%s-%s",transition_data$year,
                                             transition_data$first_snow_melt),
                                "%Y-%j")

      cont_snow_acc <- as.Date(sprintf("%s-%s",transition_data$year,
                                        transition_data$cont_snow_acc),
                                "%Y-%j")

      last_snow_melt <- as.Date(sprintf("%s-%s",transition_data$year,
                                      transition_data$last_snow_melt),
                              "%Y-%j")

      first_snow_acc <- as.Date(sprintf("%s-%s",transition_data$year,
                                      transition_data$first_snow_acc),
                              "%Y-%j")

      # convert the max accumulation date
      max_swe_date <- as.Date(sprintf("%s-%s",transition_data$year,
                                       transition_data$max_swe_doy),
                               "%Y-%j")
      
      # check the plotting type
      if (input$plot_type == "daily") {

        # format y-axis
        ay1 <- list(title = primary_label,
                   tickfont = list(color = primary_col),
                   titlefont = list(color = primary_col),
                   showgrid = FALSE)
        ay2 <- list(
          tickfont = list(color = covariate_col),
          titlefont = list(color = covariate_col),
          overlaying = "y",
          title = "",
          side = "right",
          showgrid = FALSE
        )
        
        # plot structure
        p <- plot_ly(
          data = plot_data,
          x = ~date,
          y = ~covariate,
          yaxis = "y2",
          mode = "lines",
          type = 'scatter',
          name = covariate_label,
          line = list(color = covariate_col)
        ) %>%
        add_trace(
            y = ~primary,
            mode = "lines",
            type = 'scatter',
            yaxis = "y1",
            line = list(color = primary_col),
            name = primary_label
          ) %>%
          add_trace(
            x = first_snow_melt,
            y = rep(0,length(first_snow_melt)),
            mode = "markers",
            type = 'scatter',
            yaxis = "y1",
            marker = list(color = "red", symbol = "square"),
            line = list(width = 0),
            name = "first snow melt"
          ) %>%
          add_trace(
            x = last_snow_melt,
            y = rep(0,length(last_snow_melt)),
            mode = "markers",
            type = 'scatter',
            yaxis = "y1",
            marker = list(color = "red", symbol = "circle"),
            line = list(width = 0),
            name = "last snow melt"
          ) %>%
          add_trace(
            x = first_snow_acc,
            y = rep(0,length(first_snow_acc)),
            mode = "markers",
            type = 'scatter',
            yaxis = "y1",
            marker = list(color = "blue", symbol = "circle"),
            line = list(width = 0),
            name = "first snow accumulation"
          ) %>%
          add_trace(
            x = cont_snow_acc,
            y = rep(0,length(cont_snow_acc)),
            mode = "markers",
            type = 'scatter',
            yaxis = "y1",
            marker = list(color = "blue", symbol = "square"),
            line = list(width = 0),
            name = "continuous snow accumulation"
          ) %>%
          add_trace(
            x = max_swe_date,
            y = transition_data$max_swe,
            mode = "markers",
            type = 'scatter',
            yaxis = "y1",
            marker = list(color = "green", symbol = "square"),
            line = list(width = 0),
            name = "maximum SWE"
          ) %>%
          layout(
            xaxis = list(title = "Date"),
            yaxis = ay1,
            yaxis2 = ay2,
            showlegend = TRUE,
            title = sprintf("Site ID: %s",
                  filteredData()[as.numeric(input$table_row_last_clicked),11])
          )
      } else if (input$plot_type == "yearly") {

        # convert date to year
        year <- format(as.Date(plot_data$date, "%Y-%m-%d"),"%Y")
        
        # long term mean flux data
        ltm <- plot_data %>% 
          group_by(doy) %>%
          summarise(mn = mean(primary),
                    sd = sd(primary),
                    doymn = mean(doy),
                    snowdoy = ifelse(mean(doy) < 182, mean(doy),
                                     mean(doy) - 366))
        
        p <- plot_ly(
          data = ltm,
          x = ~ snowdoy,
          y = ~ mn,
          mode = "lines",
          type = 'scatter',
          name = "LTM",
          line = list(color = "black"),
          inherit = FALSE
        ) %>%
          add_trace(
            x = ~ snowdoy,
            y = ~ ifelse((mn - sd) < 0, 0, mn - sd),
            mode = "lines",
            type = 'scatter',
            fill = "none",
            line = list(width = 0, color = "rgb(200,200,200)"),
            showlegend = FALSE,
            name = "SD"
          ) %>%
          add_trace(
            x = ~ snowdoy,
            y = ~ mn + sd,
            type = 'scatter',
            mode = "lines",
            fill = "tonexty",
            fillcolor = "rgb(200,200,200)",
            line = list(width = 0, color = "rgb(200,200,200)"),
            showlegend = TRUE,
            name = "SD"
          ) %>%
          add_trace(data = plot_data,
                    x = ~ ifelse(doy < 182, doy, doy - 366),
                    y = ~ primary,
                    split = ~ year,
                    type = "scatter",
                    mode = "lines",
                    name = year,
                    line = list(color = "Set1"),
                    showlegend = TRUE
          ) %>%
          layout(
            xaxis = list(title = "DOY"),
            yaxis = list(title = primary_label),
            title = sprintf("Site ID: %s",
                            filteredData()[as.numeric(input$table_row_last_clicked),11])
          )

      } else if (input$plot_type == "snow_phen") {
        if (is.null(transition_data)) {
          # format x-axis
          ax <- list(
            title = "",
            zeroline = FALSE,
            showline = FALSE,
            showticklabels = FALSE,
            showgrid = FALSE
          )
          p <- plot_ly(
            x = 0,
            y = 0,
            text = "NO SNOW PHENOLOGY DATA AVAILABLE",
            mode = "text",
            textfont = list(color = '#000000', size = 16)
          ) %>% layout(xaxis = ax, yaxis = ax)
        } else{

          if (nrow(transition_data) < 9) {
            # format x-axis
            ax <- list(
              title = "",
              zeroline = FALSE,
              showline = FALSE,
              showticklabels = FALSE,
              showgrid = FALSE
            )
            p <- plot_ly(
              x = 0,
              y = 0,
              text = "NOT ENOUGH DATA FOR A MEANINGFUL ANALYSIS",
              mode = "text",
              textfont = list(color = '#000000', size = 16)
            ) %>% layout(xaxis = ax, yaxis = ax)
          } else {

          # set colours
          sos_col <- "rgb(231,41,138)"
          eos_col <- "rgba(231,41,138,0.4)"
          gsl_col <- "rgba(102,166,30,0.8)"

          ay1 <-list(title = "DOY",
                     showgrid = FALSE)

          ay2 <-list(
            overlaying = "y",
            title = "Days",
            side = "left",
            showgrid = FALSE
          )

          # regression stats
          reg_sos <- lm(transition_data$first_snow_melt ~ transition_data$year)
          reg_eos <- lm(transition_data$cont_snow_acc ~ transition_data$year)

          # summaries
          reg_eos_sum <- summary(reg_eos)
          reg_sos_sum <- summary(reg_sos)

          # r-squared and slope
          r2_sos <- round(reg_sos_sum$r.squared, 2)
          slp_sos <- round(reg_sos_sum$coefficients[2, 1], 2)
          r2_eos <- round(reg_eos_sum$r.squared, 2)
          slp_eos <- round(reg_eos_sum$coefficients[2, 1], 2)

          p <- plot_ly(
            x = transition_data$year,
            y = transition_data$first_snow_melt,
            mode = "markers",
            type = "scatter",
            name = "EOS"
            ) %>%
            add_trace(
              x = transition_data$year,
              y = transition_data$cont_snow_acc,
              mode = "markers",
              type = "scatter",
              name = "SOS"
            ) %>%
            add_trace(
              x = transition_data$year[as.numeric(
                names(reg_sos$fitted.values))],
              y = reg_sos$fitted.values,
              mode = "lines",
              type = "scatter",
              name = sprintf("R2: %s| slope: %s", r2_sos, slp_sos),
              line = list(width = 2)
            ) %>%
            add_trace(
              x = transition_data$year[as.numeric(
                names(reg_eos$fitted.values))],
              y = reg_eos$fitted.values,
              type = "scatter",
              mode = "lines",
              name = sprintf("R2: %s| slope: %s", r2_eos, slp_eos),
              line = list(width = 2)
            ) %>%
            layout(
              xaxis = list(title = "Year"),
              yaxis = ay1,
              showlegend = TRUE
            )
          }
        }
      }
    }
  }) # end plot function
} # server function end
