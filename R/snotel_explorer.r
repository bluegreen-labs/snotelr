#' Start the SNOTEL shiny interface
#'
#' @export
#' @examples
#' # snotel_explorer()

snotel_explorer <- function(){
  required_pkgs <- c("DT",
                     "plotly",
                     "shinydashboard",
                     "leaflet")
  required_str <- paste0("'",
                         paste(required_pkgs[-length(required_pkgs)], collapse = "', '"), 
                         "', and '", 
                         required_pkgs[length(required_pkgs)],
                         "'")
  a <- sapply(required_pkgs, 
         function(x) { 
           if(!requireNamespace(x, quietly = TRUE)) {
             stop("Packages ", required_str, " are needed 
                  for this function to work. Please install them.",
                  call. = FALSE)
           }
         }
  )
  
  appDir <- sprintf("%s/shiny/snotel_explorer",path.package("snotelr"))
  shiny::runApp(appDir, display.mode = "normal",launch.browser=TRUE)
}
