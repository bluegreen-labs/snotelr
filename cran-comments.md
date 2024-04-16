Dear CRAN team,

This is an update of the {snotel} package (version 1.3). This package calculates and visualize 'SNOTEL' snow data and seasonality.

The update includes a correction to the snow seasonality algorithm. This fix surfaces the offset parameter in the snow_phenology() function, which allows for high latitude and souther hemisphere (out of network) sites to correctly estimate snow phenology.

Kind regards,
Koen Hufkens

--- 

I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## Test environments, local, github actions

- local 22.04 install on R 4.3.3
- github actions (devel / release + macos / windows)
- codecove.io code coverage at ~90%

## local / github actions R CMD check results

0 errors | 0 warnings | 0 notes