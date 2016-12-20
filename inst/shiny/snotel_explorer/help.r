tags$html(
  tags$head(
    tags$title('About page')
  ),
  tags$body(
    tags$h2('The snotelr package'),
    tags$p('The snotelr package provides functions to easily query and visualize SNOTEL data. Additional tools will be developed over time to increase the package functionality.'),
    tags$p('I appreciate any help in the development of the package, especially development on Windows machines is difficult due to limit access to such hardware.'),
    tags$h3('FAQ / remarks'),
    tags$ul(
      tags$li('The sites can be geographically constrained by clicking top left / bottom right on the map'),
      tags$li('The map might load slowly as it pulls in metadata from the SNOTEL server\'s javascript based site table. Subsequent loads will be faster as the data is cached for a given R session.'),
      tags$li('Use the download.snotel() function to download data.'),
      tags$li('The snow phenology plot type displays start and end of the snow season as well as maximum snow depth (in snow water equivalent).'),
      tags$li('For continued development consider buying me coffee by tipping my tip jar on my',tags$a(href="http://www.khufkens.com/downloads/", "software page",target="_blank"),'.'),
      tags$li('... or cite / acknowledging the package.')
    )
  )
)
