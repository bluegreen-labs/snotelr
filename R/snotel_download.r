#' Dowloads snotel data based upon a subset of the
#' sno-tel info as provided by snotel_info()
#'
#' @param site_id subset of the sites listed by snotel_info()
#' @param network network list to query (default = sntl, for SNOTEL)
#' @param path where to save downloaded files (default = tempdir())
#' @param internal return data to workspace, \code{TRUE} or \code{FALSE}
#' (default = \code{FALSE})
#' @export
#' @examples
#'
#' \dontrun{
#' # download data for SNOTEL site 429 and 1287, returning data to 
#' # the R workspace
#' df <- snotel_download(site_id = c(429,1287), internal = TRUE)
#' 
#' # list a few first rows
#' head(df)
#'}

snotel_download <- function(
  site_id,
  network = "sntl",
  path = tempdir(),
  internal = FALSE
  ){
  
  # trap empty site parameter, if all, downloadd all data
  # if string of IDs subset the dataset.
  if (base::missing(site_id)){
    stop("no site specified")
  }
  
  # download meta-data
  meta_data <- snotelr::snotel_info(
    network = tolower(network)
  )
  meta_data <- meta_data[which(meta_data$site_id %in% site_id),]
  
  # check if the provided site index is valid
  if (nrow(meta_data) == 0){
    stop("no site found with the requested ID")
  }    
  
  # for more than one site create a common output file
  if (length(site_id) > 1){
    filename <- "snotel_data.csv"
  }else{
    # filename
    filename <- sprintf("%s_%s.csv",
                        "snotel",
                        meta_data$site_id)
  }
  
  # loop over selection, and download the data
  snotel_data <- do.call("rbind",
    lapply(seq_len(nrow(meta_data)), function(i){
    
      # some feedback on the download progress
      message(sprintf("Downloading site: %s, with id: %s\n",
                    meta_data$site_name[i],
                    meta_data$site_id[i]))
  
      # download url (metric by default!)
      base_url <- paste0(
        "https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport,metric/daily/",
        meta_data$site_id[i], ":",
        meta_data$state[i], ":",
        meta_data$network[i],
        "%7Cid=%22%22%7Cname/POR_BEGIN,POR_END/WTEQ::value,SNWD::value,PREC::value,TMAX::value,TMIN::value,TAVG::value,PRCP::value"
        )
      
      # try to download the data
      error <- httr::GET(url = base_url,
                         httr::write_disk(path = file.path(tempdir(),
                                                           "snotel_tmp.csv"), 
                         overwrite = TRUE))
      
      # catch error and remove resulting zero byte files
      if (httr::http_error(error)) {
          warning(sprintf("Downloading site %s failed, removed empty file.",
                          meta_data$site_id[i]))
      }
      
      # read in the snotel data
      df <- utils::read.table(file.path(tempdir(),"snotel_tmp.csv"),
                             header = TRUE,
                             sep = ",",
                             stringsAsFactors = FALSE)
      
      # subsitute column names
      df <- snotelr::snotel_metric(df)
      
      # combine with the corresponding meta-data
      # (remove warning on non matching size)
      return(suppressWarnings(data.frame(meta_data[i,],df)))
  }))
  
  # cleanup temporary file (if it exists)
  if(file.exists(file.path(tempdir(),"snotel_tmp.csv"))){
    file.remove(file.path(tempdir(), "snotel_tmp.csv"))
  }
  
  # return value internally, or write to file
  if (internal){
    return(snotel_data)
  } else {
   # overwrite the original with the metric version if desired
   # merging in the meta-data
   utils::write.table(snotel_data, file.path(path, filename),
               quote = FALSE,
               col.names = TRUE,
               row.names = FALSE,
               sep = ",")
  }
}
