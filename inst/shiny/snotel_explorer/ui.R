# load libraries
require(shiny, quietly = TRUE)
require(shinydashboard, quietly = TRUE)
require(leaflet, quietly = TRUE)
require(plotly ,quietly = TRUE)
require(DT, quietly = TRUE)

# source about page content
about <- source('about.r')
help <- source('help.r')

# type
state <- c(
  "All" = "ALL",
  "CA" = "CA",
  "UT" = "UT",
  "AK" = "AK",
  "CO" = "CO",
  "ID" = "ID",
  "NM" = "NM",
  "NV" = "NV",
  "AZ" = "AZ",
  "WA" = "WA",
  "OR" = "OR",
  "WY" = "WY",
  "MT" = "MT",
  "SD" = "SD",
  "TC" = "TC")

# interface elements
header <- dashboardHeader(
  title = "SNOTEL Explorer",
  tags$li(a(href = 'https://bluegreenlabs.org',
            img(src = 'https://bluegreenlabs.org/img/logo_text_small.png',
                title = "BlueGreen Labs",
                height = "30px"),
                style = "padding-top:10px; padding-bottom:10px;"),
          class = "dropdown")
  )

sidebar <- dashboardSidebar(
  collapsed = TRUE,
  includeCSS("custom.css"),
  sidebarMenu(
    menuItem("Explore data",
             tabName = "explorer",
             icon = icon("bar-chart-o")),
    menuItem("About SNOTEL",
             tabName = "about",
             icon = icon("info-circle")),
    menuItem("About the package",
             tabName = "help",
             icon = icon("info-circle")),
    menuItem("code on GitHub", icon = icon("github"),
             href = "https://github.com/bluegreen-labs/snotelr")
  )
)

body <- dashboardBody(
  tags$head(
    tags$style(HTML('
        /* logo */
        .skin-blue .main-header .logo {
                              background-color: #0b2735;
                              }

        /* logo when hovered */
        .skin-blue .main-header .logo:hover {
                              background-color: #0b2735;
                              }

        /* navbar (rest of the header) */
        .skin-blue .main-header .navbar {
                              background-color: #0b2735;
                              }
                              '
        )),
    tags$script(
      HTML("
          window.onload = function() {
            resizeMap();
            resizeTable();
          }
          window.onresize = function() {
            resizeMap();
            resizeTable();
          }
          Shiny.addCustomMessageHandler ('triggerResize',function (val) {
            window.dispatchEvent(new Event('resize'));
          });
          function resizeMap(){
            var h = window.innerHeight - $('.navbar').height() - 280;
            $('#map').height(h);
          }
          function resizeTable(){
            var h = window.innerHeight - $('.navbar').height() - 500;
            $('#time_series_plot').height(h);
          }"
      )
    )
  ),
  tags$head(includeCSS("styles.css")),
  tabItems(
    tabItem(
      # the Interactive map and subset interface
      # and time series plotting interface
      tabName = "explorer",
      tabBox(
        side = "left",
        width=12,
        selected = "Map & Site selection",
        tabPanel("Map & Site selection", icon = icon("globe"),
                 fluidRow(
                   valueBoxOutput("site_count"),
                   valueBoxOutput("year_count"),
                   column(4,
                          selectInput("state", "State", state)
                   )
                 ),
                 fluidRow(
                   column(12,
                          box(width=NULL,
                              leafletOutput("map")
                          )
                    )
                )
        ),
        tabPanel("Plot data", icon = icon("bar-chart-o"),
                 fluidRow(
                   column(4,
      box(width = NULL,
          selectInput("primary", "Primary variable",
                      c("Snow Water Equivalent (mm)" = "snow_water_equivalent",
                        "temperature (C)" = "temperature_mean",
                        "precipitation (mm)" = "precipitation"),
                        width="100%"),
          selectInput("covariate", "Covariate",
                      c("temperature (C)" = "temperature_mean",
                        "precipitation (mm)" = "precipitation",
                        "Snow Water Equivalent (mm)" = "snow_water_equivalent"),
                        width="100%"),
          selectInput("plot_type",
                      "Plot Type",
                      c("Time Series"="daily",
                        "Yearly Summary"="yearly",
                        "Snow Phenology"="snow_phen"),
                      width="100%"))),
                   column(8,
                          box(width = NULL,
                              DT::dataTableOutput("table")
                          ))
                 ),
                 fluidRow(
                   column(12,
                          box(width = NULL,
                              plotlyOutput("time_series_plot")
                          )
                   )
                 )
        )
      )
    ),
    tabItem(
      # the about page
      tabName = "about",
      tabPanel("About", box(width=NULL,about$value))
    ),
    tabItem(
      # the about page
      tabName = "help",
      tabPanel("Help", box(width=NULL,help$value))
    )
  )
)

ui <- dashboardPage(skin = "blue", header, sidebar, body)
