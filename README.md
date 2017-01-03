# snotelr

SnotelR is a R toolbox to facilitate easy SNOTEL data exploration and downloads through a convenient R [shiny](http://shiny.rstudio.com/) based GUI. In addition it provides a routine to extract basic snow phenology metrics.

## Installation

You can quick install the package by installing the following dependencies

```R
install.packages("devtools")
```

and downloading the package from the github repository

```R
library(devtools)
install_github("khufkens/snotelr")
```

## Use

Most people will prefer the GUI to explore data on the fly. To envoke the GUI use the following command:

```R
library(snotelr)
snotel.explorer()
```

This will start a shiny application with an R backend in your default browser. The first window will display all site locations, and allows for subsetting of the data based upon state or a bounding box. The bounding box can be selected by clicking top-left and bottom-right.

![](https://farm1.staticflickr.com/325/31266804673_131c3e8898_b_d.jpg)

The *plot data* tab allows for interactive viewing of the soil water equivalent (SWE) data together with a covariate (temperature, precipitation). The SWE time series will also mark snow phenology statistics, mainly the day of:

- first snow melt
- a continuous snow free season (last snow melt)
- first snow accumulation (first snow deposited)
- continuous snow accumulation (permanent snow cover)
- maximum SWE (and it's amount)

![](https://farm1.staticflickr.com/429/31959389961_90723239f3_b_d.jpg)

For in depth analysis the above statistics can be retrieved using the **snow.phenology()** function

```R
# with df a SNOTEL file or data frame in your R workspace
snow.phenology(df)
```

To access the full list of SNOTEL sites and associated meta-data use the **snotel.info()** function.

```R
# returns the site info as snotel_metadata.txt in the current working directory
snotel.info(path = ".") 

# export to data frame
data = snotel.info(path = NULL) 
```

To query data for e.g. site 924 as shown in the image above use:

```R
download.snotel(site = 924)
```

# Notes
Use the proper acknowledgements when using the downloaded data.

# Acknowledgements

This project was in part supported by the National Science Foundation’s Macro-system Biology Program (award EF-1065029).
