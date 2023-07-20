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
#' @param threshold threshold for mapping continuous snow cover
#' @importFrom stats na.action na.contiguous
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

snotel_phenology <- function(
    df,
    threshold = 0
    ){

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

  df <- df |>
    dplyr::mutate(
      date = as.Date(date)
    )
  
  min_year <- min(df$date, na.rm = TRUE)
  max_year <- max(df$date, na.rm = TRUE)
  
  full_range <- 
    data.frame(
      date = 
        seq.Date(
          as.Date(sprintf("%s-01-01", min_year)),
          as.Date(sprintf("%s-01-01", max_year)),
          by = "day"
        )
    )
  
  # pad and offset
  df <- dplyr::left_join(df, full_range) |>
    dplyr::mutate(
      date_offset = date - 180
    )
  
  # offset year for grouping
  year <- as.numeric(format(df$date_offset, "%Y"))
  
  # convert snow water equivalent values for
  # post processing
  df$snow_na <- df$snow_water_equivalent
  df$snow_na[df$snow_water_equivalent <= threshold] <- NA

  # function which calculates the first and last
  # day where snow cover is 0, as well as the
  # days defining the longest snow free period
  minmax <- function(x, ...){
    
    if (nrow(x) < 365){
      return(rep(NA, 12))
    }
    
    if ( all(is.na(x$snow_na)) ) {
      return(rep(NA, 12))
    }

    # calculate timing of snow melt and accumulation
    minmax_loc <- which(x$snow_water_equivalent > 0)
    na_loc <- which(!c(1:length(x$snow_na) %in%
                      na.action(na.contiguous(x$snow_na))))
    
    # grab winter year
    year <- format(max(x$date),"%Y")
    year_start <- as.Date(sprintf("%s-01-01", year), "%Y-%m-%d")
    
    # first occurrence of >0 cover
    first_snow_acc <- x$date[min(minmax_loc, na.rm = TRUE)]
    first_snow_acc_doy <- as.numeric(
      difftime(
        first_snow_acc,
        year_start,
        units = "days")
    )
    
    # last occurrence of >0 cover (start of new accumulation)
    last_snow_melt <- x$date[max(minmax_loc, na.rm = TRUE)]
    last_snow_melt_doy <- as.numeric(
      difftime(
        last_snow_melt,
        year_start,
        units = "days"
      )
    )
    
    # first day of the longest continuous snow free period
    cont_snow_acc <- x$date[dplyr::first(na_loc)] 
    cont_snow_acc_doy <-as.numeric(
        difftime(
          cont_snow_acc,
          year_start,
          units = "days"
        )
      )
      
    
    # last day of the longest continuous snow free period
    first_snow_melt <-  x$date[dplyr::last(na_loc)]
    first_snow_melt_doy <- as.numeric(
        difftime(first_snow_melt, year_start,
          units = "days"
        )
      )
      

    # highest value before snow melt in a given year, makes the assumption
    # that this occurs in the same year. Ideally needs to be processed
    # on a snow season basis not on a yearly basis
    max_swe <- max(x$snow_water_equivalent[na_loc], na.rm=TRUE)
    max_swe_date <- x$date[which(x$snow_water_equivalent == max_swe)[1]]
    max_swe_doy <- as.numeric(
        difftime(
          max_swe_date,
          year_start,
          units = "days"
        )
      )
      
    df <- data.frame(
      year,
      first_snow_acc,
      first_snow_acc_doy,
      cont_snow_acc,
      cont_snow_acc_doy,
      first_snow_melt,
      first_snow_melt_doy,
      last_snow_melt,
      last_snow_melt_doy,
      max_swe,
      max_swe_date,
      max_swe_doy
    )
    
    # return a data frame (easier on the formatting)
    return(df)
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
    # return the matrix
    return(output)
  }
}