#' Dowloads sno-tel data based upon a subset of the
#' sno-tel info as provided by snotel_info()
#'
#' @param site_id subset of the sites listed by snotel_info()
#' @param path where to save downloaded files
#' @keywords SNOTEL, USDA, sites, locations, web scraping
#' @export
#' @examples
#'
#' # would download all available snotel data
#' # df = snotel_download(site = snotel_info())

download_snotel = function(site_id = NULL,
                           path = "."){

  # download meta-data
  meta_data = snotel_info(path = path)

  # trap empty site parameter, if all, downloadd all data
  # if string of IDs subset the dataset.
  if (is.null(site)){
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
  lapply(1:nrow(meta_data),function(i){

    # some feedback
    cat(sprintf("Downloading site: %s, with id: %s\n",
                meta_data$site_name[i],
                meta_data$site_id[i]))

    # download url
    base_url = paste0("https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport,metric/daily/",
                     meta_data$site_id[i], ":",
                     meta_data$state[i], ":",
                     meta_data$network[i],
                     "%7Cid=%22%22%7Cname/POR_BEGIN,POR_END/WTEQ::value,PREC::value,TMAX::value,TMIN::value,TAVG::value,PRCP::value")

    # filename
    filename = sprintf("%s/%s_%s.csv",
                       path,
                       "snotel",
                       meta_data$site_id[i])

    # download the data
    error = try(curl::curl_download(url = base_url,
                                    destfile = filename))

    # catch error and remove resulting zero byte files
    if (inherits(error,"try-error")) {
      file.remove(filename)
      cat(sprintf("Downloading site %s failed, removed empty file.",meta_data$site_id[i]))
    }
  })
}
