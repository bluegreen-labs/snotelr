#' Calculates snow phenology from the snow water equivalent data 
#' 
#' First snow melt, first continuous snow melt, first
#' snow accumulation and continous snow accumulation
#' are reported.
#' 
#' Be sure to execute this code on individual sites when loading
#' a combined tidy data frame containing data for multiple sites.
#'
#' @param df a snotel data file or data frame
#' @export
#' @examples
#'
#' \dontrun{
#' # download one of the longer time series
#' df <- snotel_download(site_id = 670, internal = TRUE)
#' 
#' # calculate the snow phenology
#' phenology <- snotel_phenology(df)
#' 
#' # show a couple of lines
#' head(phenology)
#' 
#'}

snotel_phenology <- function(df){

  # read data if existing snotel file
  if (!is.data.frame(df) | base::missing(df)) {
    stop("File is not a (SNOTEL) data frame, or missing!")
  }

  # check and convert to metric if necessary
  metric <- "temperature_min" %in% colnames(df)
  if ( !metric ) {
    stop("The content of the data frame might not be (metric) SNOTEL data...")
  }

  # check if there is SWE data, if not return NULL
  # nothing to be calculated and returned
  if ( all(is.na(df$snow_water_equivalent)) ) {
    warning("Insufficient data, no snow phenology metrics returned...")
    return(NULL)
  }

  # convert date format, add year
  df$date <- as.Date(df$date)

  # extract years for yearly stats
  year <- format(df$date,"%Y")

  # convert snow water equivalent values for
  # post processing
  df$snow_na <- df$snow_water_equivalent
  df$snow_na[df$snow_water_equivalent > 0] <- NA

  # function which calculates the first and last
  # day where snow cover is 0, as well as the
  # days defining the longest snow free period
  minmax <- function(x, ...){
    
    if (nrow(x) < 365){
      return(rep(NA,4))
    }
    
    if ( all(is.na(x$snow_na)) ) {
      return(rep(NA,4))
    }

    # calculate timing of snow melt and accumulation
    minmax_loc <- which(x$snow_water_equivalent == 0)
    na_loc <- as.numeric(stats::na.action(stats::na.contiguous(x$snow_na)))
    doy <- 1:365
    doy[na_loc] <- NA

    year <- as.numeric(format(x$date[min(minmax_loc)],"%Y"))
    
    # first occurence of 0 cover
    min_loc <- as.numeric(format(x$date[min(minmax_loc)],"%j"))
    
    # last occurence of 0 cover (start of new accumulation)
    max_loc <- as.numeric(format(x$date[max(minmax_loc)],"%j"))
    
    # first day of the longest continous snow free period
    min_na_loc <- as.numeric(format(x$date[min(doy, na.rm = TRUE)],"%j"))
    
    # last day of the longest continous snow free period
    max_na_loc <- as.numeric(format(x$date[max(doy, na.rm = TRUE)],"%j"))

    # highest value before snow melt in a given year, makes the assumption
    # that this occurs in the same year. Ideally needs to be processed
    # on a snow season basis not on a yearly basis
    max_swe <- max(x$snow_water_equivalent[1:min(minmax_loc)],na.rm=TRUE)
    max_swe_doy <- as.numeric(
      format(x$date[which(x$snow_water_equivalent == max_swe)[1]],"%j")
      )

    # return a data frame (easier on the formatting)
    return(data.frame(year,
                      min_loc,
                      max_loc,
                      min_na_loc,
                      max_na_loc,
                      max_swe,
                      max_swe_doy))
  }

  # calculate metrics by year and bind the rows of the list
  # with a do.call()
  output <- do.call("rbind",
                   by(df, INDICES = c(year),
                      FUN = minmax))

  # remove years with missing values
  output <- stats::na.omit(output)

  # if no rows left, return empty NA data string
  # else
  if ( dim(output)[1] == 0 ){
    warning("Insufficient data, no snow phenology metrics returned...")
    return(NULL)
  } else {
    # assign column names
    colnames(output) <- c("year",
                         "first_snow_melt",
                         "cont_snow_acc",
                         "last_snow_melt",
                         "first_snow_acc",
                         "max_swe",
                         "max_swe_doy"
                         )

    # return the matrix
    return(output)
  }
}
