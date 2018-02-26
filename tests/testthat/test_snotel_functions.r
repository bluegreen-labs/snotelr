# snotelr unit tests

# ancillary functions
test_that("check snotel routines",{
  
  # list sites
  info = try(snotel_info())
  
  # download data
  df = try(download_snotel(site = 1161,
                       path = tempdir()))
  
  # download fail
  df_fail = try(download_snotel(site = 10000,
                           path = tempdir()))
  
  # convert to metric
  metric = try(snotel_metric(paste0(tempdir(),
                                    "/snotel_1161.csv")))
  
  # conversion fail
  metric_fail = try(snotel_metric(paste0(tempdir(),
                                    "/snotel_1160.csv")))
  
  # estimate snotel phenology
  stats = try(snotel_phenology(paste0(tempdir(),
                                  "/snotel_1161.csv")))
  
  # estimate snotel phenology
  stats_fail = try(snotel_phenology(paste0(tempdir(),
                                  "/snotel_1160.csv")))
  
  # see if any of the runs failed
  check = !inherits(info,"try-error") &
  !inherits(metric,"try-error") &
  inherits(metric_fail,"try-error") &
  !inherits(stats,"try-error") &
  inherits(stats_fail,"try-error") &
  !inherits(df,"try-error") &
  inherits(df_fail,"try-error")
  
  # check if no error occured
  expect_true(check)
})
