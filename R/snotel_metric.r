#' Convert snotel data to metric from imperial units
#' 
#' Data is read from either a snotel data frame and returned  as such.
#' 
#' By default the conversion is done upon download. This function
#' might serve some a purpose in processing of data grabbed straight
#' from the server rather than through the package.
#' 
#' This is an internal function only. Hence, no examples are given.
#' 
#' @param df snotel data frame
#' @return a data frame with imperial values converted to metric ones
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
  if (ncol(df) != 8) {
    stop("not a standard snotel file")
  }
  
  # define new column names
  snotel_columns <- c(
    "date",
    "snow_water_equivalent",
    "snow_depth",
    "precipitation_cumulative",
    "temperature_max",
    "temperature_min",
    "temperature_mean",
    "precipitation"
    )
  
  # if the columns match those in the current data frame
  # return it as is (previously processed)
  if(length(which(colnames(df) == snotel_columns)) == 8){
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
    df$precipitation_cumulative <- df$precipitation_cumulative * 25.4
    df$precipitation <- df$precipitation * 25.4

    # temperature (fahrenheit to celcius)
    df$temperature_max <- (df$temperature_max - 32) * 5/9
    df$temperature_min <- (df$temperature_min - 32) * 5/9
    df$temperature_mean <- (df$temperature_mean - 32) * 5/9
  }

  # return data frame
  return(df)
}
