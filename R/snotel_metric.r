#' Convert snotel data to metric from imperial units, data is read
#' from either a snotel data file (csv) or a snotel data frame already
#' loaded into the R workspace.
#' 
#' Note, if providing a path to a snotel file the original data will
#' be overwritten by their metric equivalent with standardized column
#' names. It is advisable to do this to create a uniform dataset.
#'
#' @param df snotel data frame or file
#' @keywords SNOTEL, USDA, sites, locations, web scraping, conversion
#' @export
#' @examples
#'
#' # would download all available snotel data
#' # df = snotel_metric(df = "snotel_1277.csv")

snotel_metric = function(df) {

  # check if it's a filename or data frame
  df_check = is.data.frame(df)

  if (!df_check) {
    if (file.exists(df)) {

      # assign filename
      filename = df

      # read data file
      header = try(readLines(df, n = 58), silent = TRUE)
      df = utils::read.table(df, header = TRUE, sep = ",")
    } else{
      stop("file does not exist, check path")
    }
  }

  # check the file
  if ( ncol(df) != 7) {
    stop("not a standard snotel file")
  } else {
    
    # if the data are metric, just rename the columns
    # otherwise convert from imperial to metric units
    if ( length(grep("degC", colnames(df))) >= 1 ){
      colnames(df) = c("date",
                       "snow_water_equivalent",
                       "precipitation_cummulative",
                       "temperature_max",
                       "temperature_min",
                       "temperature_mean",
                       "precipitation")

    } else {
      colnames(df) = c("date",
                       "snow_water_equivalent",
                       "precipitation_cummulative",
                       "temperature_max",
                       "temperature_min",
                       "temperature_mean",
                       "precipitation")

      # convert the imperial to metric units
      # precipitation (inches)
      df$precipitation_cummulative = df$precipitation_cummulative * 25.4
      df$precipitation = df$precipitation * 25.4

      # temperature (fahrenheit)
      df$temperature_max = (df$temperature_max - 32) * 5/9
      df$temperature_min = (df$temperature_min - 32) * 5/9
      df$temperature_mean = (df$temperature_mean - 32) * 5/9
    }

    # if the data is not a data frame, write
    # to the same file else return df
    if (!df_check) {
      
      # writing the final data frame to file,
      # retaining the original header
      utils::write.table(
        header,
        filename,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE,
        sep = ""
      )
      utils::write.table(
        df,
        filename,
        quote = FALSE,
        row.names = FALSE,
        col.names = TRUE,
        sep = ",",
        append = TRUE
      )
    } else {
      return(df)
    }
  }
}
