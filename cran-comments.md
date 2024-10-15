Dear CRAN team,

This is an update of the {snotelr} package (version 1.5.2). This package calculates and visualizes 'SNOTEL' snow data and seasonality. 

This update implements a consistency conversion of snow depth values when reporting in the raw files is metric. The values are reported as cm, while my conversion from (inches where reported in inches) goes to mm. This corrects this issue so sites can be mixed, regardless of the units used for reporting. I've also exposed the option to export the raw data, using a `metric` parameter. The default is TRUE, but this has been helpful in debugging and might serve some.

No further changes were made to the package so the update does not affect previous code coverage and testing metrics (which remained the same).

Kind regards,
Koen Hufkens

--- 

I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## Test environments, local, github actions

- local 22.04 install on R 4.4.1
- github actions (devel / release + macos / windows)
- codecove.io code coverage at ~90%

## local / github actions R CMD check results

0 errors | 0 warnings | 0 notes