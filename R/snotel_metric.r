#' Convert snotel data to metric from imperial units
#' 
#' Data is read from either a snotel data file (csv) or 
#' a snotel data frame already loaded into the R workspace.
#' 
#' By default the conversion is done upon download. This function
#' might serve some a purpose in processing of data grabbed straight
#' from the server rather than through the package.
#' 
#' This is an internal function only. Hence, no examples are given.
#' 
#' @param df snotel data frame
#' @keywords SNOTEL, conversion, metric
#' @export

snotel_metric <- function(df) {

  # check if it's a dataframe
  df_check <- is.data.frame(df)
  
  if (!df_check) {
      stop("Not a valid (SNOTEL) data frame...")
  }

  # check the file, if less than 7 columns
  # are present this is not a standard file,
  # stop processing
  if (ncol(df) != 7) {
    stop("not a standard snotel file")
  }
  
  # define new column names
  snotel_columns <- c(
    "date",
    "snow_water_equivalent",
    "precipitation_cummulative",
    "temperature_max",
    "temperature_min",
    "temperature_mean",
    "precipitation"
    )
  
  # if the columns match those in the current data frame
  # return it as is (previously processed)
  if(length(which(colnames(df) == snotel_columns)) == 7){
    message("File is already metric, returning original!")
    return(df)
  }
  
  # if the data are metric, just rename the columns
  # otherwise convert from imperial to metric units
  if ( length(grep("degC", colnames(df))) >= 1 ){
    
    # rename columns
    colnames(df) <- snotel_columns

  } else {
    
    # rename the columns
    colnames(df) <- snotel_columns

    # convert the imperial to metric units
    # precipitation (inches)
    df$precipitation_cummulative <- df$precipitation_cummulative * 25.4
    df$precipitation <- df$precipitation * 25.4

    # temperature (fahrenheit to celcius)
    df$temperature_max <- (df$temperature_max - 32) * 5/9
    df$temperature_min <- (df$temperature_min - 32) * 5/9
    df$temperature_mean <- (df$temperature_mean - 32) * 5/9
  }

  # if the data is not a data frame, write
  # to the same file else return df
  if (!df_check) {
    utils::write.table(
      df,
      filename,
      quote = FALSE,
      row.names = FALSE,
      col.names = TRUE,
      sep = ","
    )
  } else {
    return(df)
  }
}
