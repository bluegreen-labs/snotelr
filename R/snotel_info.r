#' Downloads a SNOTEL site listing for further processing
#'
#' @param path path where to save the snotel information (site list)
#' 
#' @importFrom magrittr "%>%"
#' @importFrom stats na.action
#' @importFrom memoise memoise
#' @importFrom RSelenium remoteDriver
#' @importFrom wdman phantomjs
#' @importFrom xml2 read_html
#' @importFrom rvest html_table html_nodes
#' 
#' @export
#' @examples
#'
#' \dontrun{
#' # download the meta-data from the SNOTEL server
#' meta_data <- snotel_info()
#' 
#' # show a couple of lines
#' head(meta_data)
#'}

snotel_info <- memoise::memoise(function(path){
  
  # check if the phatomjs server is
  # installed and running
  server <- try(wdman::phantomjs(verbose = FALSE))
  
  # start remote driver
  remDr <- RSelenium::remoteDriver(browserName = "phantomjs",
                                   port = 4567L)
  
  # open a connection to the phantomjs server
  remDr$open(silent = TRUE)
  
  # navigate to the page and wait on load
  remDr$navigate('http://wcc.sc.egov.usda.gov/nwcc/yearcount?network=sntl&counttype=listwithdiscontinued&state=')
  
  # grab the loaded main html page
  main <- xml2::read_html(remDr$getPageSource()[[1]])
  
  # close the connection and clean up
  remDr$close()
  
  # stop server only if opened in this
  # session, otherwise skip
  if(!inherits(server, "try-error")){
    server$stop()
  }
  
  # set html element selector for the table
  # on the main page
  sel_data <- 'h5~ table+ table'
  
  # process the html file and extract stats
  df <- rvest::html_nodes(main,sel_data) %>%
    rvest::html_table() %>%
    data.frame()

  # extract site id from site name
  df$site_id <- as.numeric(gsub("[\\(\\)]",
                               "",
                               regmatches(df$site_name,
                                          regexpr("\\(.*?\\)",
                                                  df$site_name))
                               )
                          )

  # reformat the sitename (drop the site ID)
  df$site_name <- tolower(lapply(strsplit(df$site_name,"\\("),"[[",1))

  # clean up date format
  df$start <- as.Date(paste(df$start,"1"),"%Y-%B %d")
  df$end <- as.Date(paste(df$enddate,"1"),"%Y-%B %d")

  # drop old enddate column for consistency
  df <- df[,-grep("enddate",colnames(df))]

  # rename columns
  colnames(df)[which(colnames(df) == 'ntwk')] <- 'network'
  colnames(df)[which(colnames(df) == 'huc')] <- 'description'

  # drop some columns
  df <- df[-which(colnames(df) == 'ts' | colnames(df) == 'wyear')]
  df <- df[,c(1,2,3,9,4,11,5,6,7,8,10)]

  # convert elevation to m asl
  df$elev <- round(df$elev * 0.3048)

  # convert the end date
  df$end[df$end == "2100-01-01"] <- Sys.Date()

  if (base::missing(path)){
    # return data frame
    return(df)
  }else{
    # write to file
    utils::write.table(df,
                sprintf("%s/snotel_metadata.csv",path),
                col.names=TRUE,
                row.names=FALSE,
                quote=FALSE,
                sep=",")
  }
})
