#' Grabs the sno-tel site listing for further processing
#'
#' @param url: Location of the FLUXNET2015 site table
#' (hopefully will not change to often, default is ok for now)
#' @param path: location of the phantomjs binary (system specific)
#' @keywords sno-tel, USDA, sites, locations, web scraping
#' @export
#' @examples
#'
#' # with defaults, outputting a data frame
#' # df = snotel.info()
#'
#' # [requires the rvest package for post-processing]
#' # http://phantomjs.org/download.html
#  # selection string

snotel.info = function(url="http://wcc.sc.egov.usda.gov/nwcc/yearcount?network=sntl&counttype=listwithdiscontinued&state=",path = NULL){

  # grab the location of the package, assuming it is installed
  # in the user space (not globally)
  # phantomjs_path = sprintf("%s/phantomjs/",path.package("fluxdatastatr"))

  # grab the OS info
  OS = Sys.info()[1]

  # base url
  base_url="http://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/1:AK:SNTL%7Cid=%22%22%7Cname/POR_BEGIN,POR_END/WTEQ::value,PREC::value,TMAX::value,TMIN::value,TAVG::value,PRCP::value"

  # assume phantomjs in the current working directory
  phantomjs_path = "/data/Dropbox/Research_Projects/working/evergreen_phenology/code/phantomjs/"

  # subroutines for triming leading spaces
  # and converting factors to numeric
  trim.leading = function (x)  sub("^\\s+", "", x)
  as.numeric.factor = function(x) {as.numeric(levels(x))[x]}

  # write out a script phantomjs can process
  # change timeout if the page bounces, seems empty !!!
  writeLines(sprintf("var page = require('webpage').create();
                     page.open('%s', function (status) {
                     if (status !== 'success') {
                     console.log('Unable to load the address!');
                     phantom.exit();
                     } else {
                     window.setTimeout(function () {
                     console.log(page.content);
                     phantom.exit();
                     }, 3000); // Change timeout to render the page
                     }
                     });", url), con="scrape.js")

  # run different versions of phantomjs depending on the OS
  if (OS == "Linux"){
    # process the script with phantomjs / scrapes zooniverse page
    system(sprintf("%s./phantomjs_linux scrape.js > scrape.html",phantomjs_path),wait=TRUE)
  } else if (OS == "Windows") {
    # process the script with phantomjs / scrapes zooniverse page
    shell(sprintf("%sphantomjs.exe scrape.js > scrape.html",phantomjs_path))
  }else{
    # process the script with phantomjs / scrapes zooniverse page
    system(sprintf("%s./phantomjs_osx scrape.js > scrape.html",phantomjs_path),wait=TRUE)
  }

  # load html data
  main = xml2::read_html("scrape.html")

  # set html element selector for the table
  sel_data = 'h5~ table+ table'

  # process the html file and extract stats
  data = rvest::html_nodes(main,sel_data) %>% rvest::html_table()
  df = data.frame(data)

  # extract site id from site name
  df$site_id = as.numeric(gsub("[\\(\\)]", "", regmatches(df$site_name, regexpr("\\(.*?\\)", df$site_name))))

  # reformat the sitename (drop the site ID)
  df$site_name = tolower(lapply(strsplit(df$site_name,"\\("),"[[",1))

  # clean up date format
  df$start = as.Date(paste(df$start,"1"),"%Y-%B %d")
  df$end = as.Date(paste(df$enddate,"1"),"%Y-%B %d")

  # drop old enddate column for consistency
  df = df[,-grep("enddate",colnames(df))]

  # rename columns
  colnames(df)[which(colnames(df) == 'ntwk')] = 'network'
  colnames(df)[which(colnames(df) == 'huc')] = 'description'

  # drop some columns
  df = df[-which(colnames(df) == 'ts' | colnames(df) == 'wyear')]
  df = df[,c(1,2,3,9,4,11,5,6,7,8,10)]

  # convert elevation to m asl
  df$elev = round(df$elev * 0.3048)

  # convert the end date
  df$end[df$end == "2100-01-01"] = Sys.Date()

  # remove temporary html file and javascript
  file.remove("scrape.html")
  file.remove("scrape.js")

  if (is.null(path)){
    # return data frame
    return(df)
  }else{
    # write to file
    utils::write.table(df,
                sprintf("%s/snotel_metadata.csv",path),
                col.names=TRUE,
                row.names=FALSE,
                quote=FALSE,
                sep=",")
  }
}
