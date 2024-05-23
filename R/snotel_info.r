#' Downloads a SNOTEL site listing for further processing
#'
#' @param network network list to query (default = sntl, for SNOTEL)
#' @param path path where to save the snotel information (site list)
#' 
#' @importFrom memoise memoise
#' @importFrom rvest read_html
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

snotel_info <- memoise::memoise(
  function(
    network = "sntl",
    path
    ){
  
  # set base url
  url <- "https://wcc.sc.egov.usda.gov/nwcc/yearcount?"
    
  # construct the query to be served to the server
  query <- list("network" = tolower(network),
                "counttype" = "listwithdiscontinued")
    
  # query the data table
  df <- httr::GET(
    url = url,
    query = query) |>
    rvest::read_html() |>
    rvest::html_nodes('table') |>
    rvest::html_table() |>
    data.frame()
  
  # extract site id from site name
  df$site_id <- as.numeric(
    gsub("[\\(\\)]",
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
