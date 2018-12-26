# snotelr unit tests

# info
test_that("check snotel info routines",{
  expect_output(str(snotel_info()), "11 variables")
})
  
test_that("check snotel info routines - write to disk",{
  expect_silent(snotel_info(path = tempdir()))
})

# downloads
test_that("check download 1 site",{
  expect_message(snotel_download(site_id = 429))
})

test_that("check download 2 sites",{
  expect_message(snotel_download(site_id = c(429,670)))
})

test_that("check download internal",{
  expect_output(str(snotel_download(site_id = 429,
                                    internal = TRUE)))
})

test_that("check download invalid site",{
  expect_error(snotel_download(site_id = 99999999))
})

test_that("check download no site",{
  expect_error(snotel_download())
})

# metric conversion
test_that("metric conversion - not a proper size data frame",{
  df <- snotel_download(site_id = 670, internal = TRUE)
  expect_error(snotel_metric(df))
})

test_that("metric conversion - alread converted",{
  df <- snotel_download(site_id = 429, internal = TRUE)
  df <- df[,12:18]
  expect_message(snotel_metric(df))
})

test_that("metric conversion - not a data frame",{
  df <- rep(NA, 10)
  expect_error(snotel_metric(df))
})

test_that("metric conversion - not a data frame",{
  df <- read.table("https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/947:AK:SNTL|id=%22%22|name/POR_BEGIN,POR_END/WTEQ::value,PREC::value,TMAX::value,TMIN::value,TAVG::value,PRCP::value",
                 header = TRUE, sep = ",")
  expect_output(str(snotel_metric(df)))
})

# phenology
test_that("check phenology routines",{
  df <- snotel_download(site_id = 670, internal = TRUE)
  expect_output(str(snotel_phenology(df)))
})

test_that("check phenology routines - swe empty",{
  df <- snotel_download(site_id = 670, internal = TRUE)
  df$snow_water_equivalent <- NA
  expect_output(str(snotel_phenology(df)))
})

test_that("check phenology routines - swe 0",{
  df <- snotel_download(site_id = 670, internal = TRUE)
  df$snow_water_equivalent <- 10
  expect_output(str(snotel_phenology(df)))
})

test_that("check phenology routines - not metric",{
  df <- snotel_download(site_id = 670, internal = TRUE)
  colnames(df) <- seq_len(ncol(df))
  expect_error(snotel_phenology(df))
})

test_that("check phenology routines - missing file",{
  expect_error(str(snotel_phenology()))
})

test_that("check phenology routines - no data returned",{
  df <- snotel_download(site_id = 429, internal = TRUE)
  expect_warning(snotel_phenology(df))
})

test_that("check phenology routines - not a data frame",{
  df <- rep(NA, 10)
  expect_error(snotel_phenology(df))
})

