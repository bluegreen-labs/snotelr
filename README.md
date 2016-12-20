# snotelr

SnotelR is a R toolbox to facilitate easy SNOTEL data exploration and downloads through a convenient R [shiny](http://shiny.rstudio.com/) based GUI. In addition it provides a routine to extract basic snow phenology metrics.

## Installation

You can quick install the package by installing the following dependencies

```R
install.packages("devtools")
```

and downloading the package from the github repository

```R
require(devtools)
install_github("khufkens/snotelr")
```

## Use

Most people will prefer the GUI to explore data on the fly. To envoke the GUI use the following command:

```R
library(snotelr)
snotel.explorer()
```

This will start a shiny application with an R backend in your default browser.

```R
snotel.info(path = ".") # returns the site info as snotel_metadata.txt in the current working directory
data = ameriflux.info(path = NULL) # export to data frame
```

To query data use for example site is 924 (further info can be found in the meta-data file).

```R
download.snotel(924)
```

# Notes
Use the proper acknowledgements when using the downloaded data.

# Acknowledgements

This project was in part supported by the National Science Foundation’s Macro-system Biology Program (award EF-1065029).
