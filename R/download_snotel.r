#' Dowloads sno-tel data based upon a subset of the
#' sno-tel info as provided by snotel_info()
#'
#' @param site_id subset of the sites listed by snotel_info()
#' @param path where to save downloaded files
#' @param silent suppress verbose output on downloads (default = FALSE)
#' @keywords SNOTEL, USDA, sites, locations, web scraping
#' @export
#' @examples
#'
#' # would download all available snotel data
#' # df = snotel_download(site = snotel_info())

download_snotel = function(site_id = NULL,
                           path = ".",
                           silent = FALSE){

  # download meta-data
  meta_data = snotel_info()

  # trap empty site parameter, if all, downloadd all data
  # if string of IDs subset the dataset.
  if (is.null(site_id)){
    stop("no site specified")
  } else {
    # for some reason using != here doesn't work for strings?
    if (any(site_id == "all" | site_id == "ALL")){
      meta_data = meta_data
    } else {
      meta_data = meta_data[which(meta_data$site_id %in% site_id),]
    }
  }
  
  # loop over selection, and download the data
  snotel_data = lapply(1:nrow(meta_data), function(i){
    
    # some feedback on the download progress
    if (!silent){
      cat(sprintf("Downloading site: %s, with id: %s\n",
                  meta_data$site_name[i],
                  meta_data$site_id[i]))
    }
    
    # download url
    base_url = paste0("https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport,metric/daily/",
                     meta_data$site_id[i], ":",
                     meta_data$state[i], ":",
                     meta_data$network[i],
                     "%7Cid=%22%22%7Cname/POR_BEGIN,POR_END/WTEQ::value,PREC::value,TMAX::value,TMIN::value,TAVG::value,PRCP::value")
    
    # filename
    filename = sprintf("%s/%s_%s.csv",
                       tempdir(),
                       "snotel",
                       meta_data$site_id[i])

    # download the data
    error = try(curl::curl_download(url = base_url,
                                    destfile = filename),
                silent = TRUE)

    # catch error and remove resulting zero byte files
    if (inherits(error,"try-error")) {
      file.remove(filename)
      if(!silent){
        warning(sprintf("Downloading site %s failed, removed empty file.",
                        meta_data$site_id[i]))
      }
      return(NULL)
    }
    
    # how to export the data, if no export
    # path is provided return as a nested list
    # if a path is provided copy the data from
    # the temporary directory to the destination path
    if (is.null(path)){
      
      # read in the snotel data
      df = utils::read.table(filename,
                             header = TRUE,
                             sep = ",",
                             stringsAsFactors = FALSE)
      # convert to metric
      df = snotel_metric(df)
      
      # combine with the corresponding meta-data
      # (remove warning on non matching size)
      df = suppressWarnings(data.frame(meta_data[i,],df))
      
      # return the value
      return(df)
    } else {
      file.copy(filename, path)
    }
  })
  
  # return the nested list of data
  return(snotel_data)
}
