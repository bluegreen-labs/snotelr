#' Start the SNOTEL shiny interface
#'
#' @keywords GUI
#' @export
#' @examples
#' # snotel_explorer()

snotel_explorer <- function(){
  appDir = sprintf("%s/shiny/snotel_explorer",path.package("snotelr"))
  shiny::runApp(appDir, display.mode = "normal",launch.browser=TRUE)
}
