#' Start the SNOTEL shiny interface
#'
#' @export
#' @examples
#' # snotel_explorer()

snotel_explorer <- function(){
  if(!requireNamespace(c("DT",
                         "plotly",
                         "shinydashboard",
                         "leaflet"), quietly = TRUE)){
    stop("Packages \"DT, plotly, shinydashboard and leaflet\" are needed 
         for this function to work. Please install it.",
         call. = FALSE)
  }
  
  appDir <- sprintf("%s/shiny/snotel_explorer",path.package("snotelr"))
  shiny::runApp(appDir, display.mode = "normal",launch.browser=TRUE)
}
