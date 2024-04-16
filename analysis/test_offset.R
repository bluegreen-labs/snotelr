# test dynamic offset for out of bounds sites
# high latitude or southern hemisphere (for out of network data)

library(snotelr)
library(ggplot2)
library(patchwork)

# high latitude example

# download data
df <- snotel_download(
  site_id = 679,
  internal = TRUE
)

# defaults
default <- snotel_phenology(df)

# late summer
late <- snotel_phenology(df, offset = 250)

# plot results
p1 <- ggplot(default) +
  geom_point(
    aes(
      year,
      first_snow_melt_doy
    )
  )

p2 <- ggplot(late) +
  geom_point(
    aes(
      year,
      first_snow_melt_doy
    )
  )

p1 / p2
