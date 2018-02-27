# snotelr unit tests

test_that("check snotel info routines",{
  
  # list sites
  info = try(snotel_info())
  
  # list sites, write to file
  info_file = try(snotel_info(path = tempdir()))
  
  print(!inherits(info,"try-error"))
  print(!inherits(info_file,"try-error"))
  
  # see if any of the runs failed
  check = !inherits(info,"try-error") &
          !inherits(info_file,"try-error")
          
  # check if no error occured
  expect_true(check)
})


test_that("check snotel download routines",{
  
  # download data
  df = try(download_snotel(site = 1161,
                           path = tempdir()))
  
  print(list.files(tempdir()))
  
  # download data
  df_home = try(download_snotel(site = 1161,
                                path = "~"))
  
  # download fail
  df_fail = try(download_snotel(site = 10000,
                                path = tempdir()))
  
  print(!inherits(df,"try-error"))
  print(!inherits(df_home,"try-error"))
  print(inherits(df_fail,"try-error"))
  
  # see if any of the runs failed
  check = !inherits(df,"try-error") &
          !inherits(df_home,"try-error") &
          inherits(df_fail,"try-error")
  
  # check if no error occured
  expect_true(check)
})


test_that("check metric conversion routines",{
  
  # download data
  df = try(download_snotel(site = 1161,
                           path = tempdir()))
  # convert to metric
  metric = try(snotel_metric(paste0(tempdir(),
                                    "/snotel_1161.csv")))
  
  # convert to metric completed
  metric_complete = try(snotel_metric(paste0(tempdir(),
                                             "/snotel_1161.csv")))
  
  # conversion fail
  metric_fail = try(snotel_metric(paste0(tempdir(),
                                         "/snotel_1160.csv")))
  
  print(!inherits(metric,"try-error"))
  print(!inherits(metric_complete,"try-error"))
  print(inherits(metric_fail,"try-error"))
  
  # see if any of the runs failed
  check = !inherits(metric,"try-error") &
          !inherits(metric_complete,"try-error") &
          inherits(metric_fail,"try-error")
    
  # check if no error occured
  expect_true(check)
})

test_that("check stats routines",{
  
  # download data
  df = try(download_snotel(site = 1161,
                           path = tempdir()))
  
  # estimate snotel phenology
  stats = try(snotel_phenology(paste0(tempdir(),
                                      "/snotel_1161.csv")))
  
  # estimate snotel phenology
  stats_fail = try(snotel_phenology(paste0(tempdir(),
                                           "/snotel_1160.csv")))
  
  print(!inherits(stats,"try-error"))
  print(!inherits(stats_fail,"try-error"))
  
  # see if any of the runs failed
  check = !inherits(stats,"try-error") &
          inherits(stats_fail,"try-error")
  
  # check if no error occured
  expect_true(check)
})

