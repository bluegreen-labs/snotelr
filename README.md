# snotelr <a href='https://bluegreen-labs.github.io/snotelr/'><img src='https://raw.githubusercontent.com/bluegreen-labs/snotelr/master/docs/apple-touch-icon-152x152.png' align="right" height="139" /></a>

[![R-CMD-check](https://github.com/bluegreen-labs/snotelr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bluegreen-labs/snotelr/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/bluegreen-labs/snotelr/branch/master/graph/badge.svg)](https://codecov.io/gh/bluegreen-labs/snotelr)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/snotelr)](https://cran.r-project.org/package=snotelr)
[![](https://cranlogs.r-pkg.org/badges/grand-total/snotelr)](https://cran.r-project.org/package=snotelr)

Snotelr is a R toolbox to facilitate easy SNOTEL data exploration and downloads through a convenient R [shiny](http://shiny.rstudio.com/) based GUI. In addition it provides a routine to extract basic snow phenology metrics.

## Installation

### stable release

To install the current stable release use a CRAN repository:

```r
install.packages("snotelr")
library("snotelr")
```

The use of the GUI requires the installation of additional packages, which are side loaded.

```r
install.packages(c("DT","shinydashboard", "plotly", "leaflet"))
```

### development release

To install the development releases of the package run the following
commands:

```r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("bluegreen-labs/snotelr")
library("snotelr")
```

Vignettes are not rendered by default, if you want to include additional
documentation please use:

```r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("bluegreen-labs/snotelr", build_vignettes = TRUE)
library("snotelr")
```

## Use

Most people will prefer the GUI to explore data on the fly. To envoke the GUI use the following command:

```r
library(snotelr)
snotel_explorer()
```

This will start a shiny application with an R backend in your default browser. The first window will display all site locations, and allows for subsetting of the data based upon state or a bounding box. The bounding box can be selected by clicking top-left and bottom-right.

![](https://github.com/bluegreen-labs/snotelr/raw/master/docs/map.png)

The *plot data* tab allows for interactive viewing of the soil water equivalent (SWE) data together with a covariate (temperature, precipitation). The SWE time series will also mark snow phenology statistics, mainly the day of:

- first snow melt
- a continuous snow free season (last snow melt)
- first snow accumulation (first snow deposited)
- continuous snow accumulation (permanent snow cover)
- maximum SWE (and its amount)

![](https://github.com/bluegreen-labs/snotelr/raw/master/docs/time_series.png)

To access the full list of SNOTEL sites and associated meta-data use the **snotel_info()** function.

```r
# returns the site info as snotel_metadata.txt in the current working directory
snotel_info(path = ".") 

# export to data frame
meta-data <- snotel_info(path = NULL) 

# show some lines of the data frame
head(meta-data)
```

To query data for e.g. site 924 as shown in the image above use:

```r
snotel_download(site_id = 924)
```

For in depth analysis the statistics in the GUI can be retrieved using the **snotel_phenology()** function

```r
# with df a SNOTEL file or data frame in your R workspace
snotel_phenology(df)
```

# Notes
Use the proper acknowledgements when using the downloaded data.

# Acknowledgements

This project was in part supported by the National Science Foundation’s Macro-system Biology Program (award EF-1065029) and the Marie Skłodowska-Curie Action (H2020 grant 797668). Logo design elements are taken from the FontAwesome library according to [these terms](https://fontawesome.com/license), where the globe element was inverted and intersected.

