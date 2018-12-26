tags$html(
  tags$head(
    tags$title('About page')
  ),
  tags$body(
    tags$h2('Snow Telemetry (SNOTEL) Network'),
    tags$p('The SNOTEL network is composed of over 800 automated data 
           collection sites located in remote, high-elevation mountain 
           watersheds in the western U.S. They are used to monitor snowpack,
           precipitation, temperature, and other climatic conditions.
           The data collected at SNOTEL sites are transmitted to a central
           database, called the Water and Climate Information System, where
           they are used for water supply forecasting, maps, and reports.'),
    tags$p('SNOTEL sites are designed to operate unattended and without 
           maintenance for a year or more. A typical SNOTEL remote site 
           consists of measuring devices and sensors, an equipment shelter for
           the radio telemetry equipment, and an antenna that also supports the
           solar panels used to keep batteries charged.'),
    tags$p('A standard sensor configuration includes a snow pillow, a storage 
           precipitation gage, and a temperature sensor. The snow pillow
           measures how much water is in the snowpack by weighing the 
           snow with a pressure transducer. Devices in the shelter convert 
           the weight of the snow into the snow water equivalent -- that is,
           the actual amount of water in a given volume of snow.'),
    tags$p('SNOTEL stations also collect data on snow depth, 
           all-season precipitation accumulation, and air temperature 
           with daily maximums, minimums, and averages. Many enhanced SNOTEL
           sites are equipped to take soil moisture and soil temperature
           measurements at various depths, as well as solar radiation, 
           wind speed, and relative humidity. The configuration at each site
           is tailored to the physical conditions, the climate, and the 
           specific requirements of the data users. The data collected at
           SNOTEL sites are generally reported multiple times per day,
           with some sensors reporting hourly.'),
    tags$img(src='http://www.wcc.nrcs.usda.gov/images/snotel_callouts.jpg'),
    tags$h2('Acknowledgements'),
    tags$p('Please acknowledge downloaded data through
           the R snotelr package properly, citing all relevant literature.')
  )
)

