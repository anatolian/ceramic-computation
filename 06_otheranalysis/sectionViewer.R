#produces a simple list of the ceramic sections stored in the database

source("01_include/pg.R")

ceramicSectionList <- GetCeramicSectionList()
ceramicSections <- GetCeramicSection()

apply(ceramicSectionList, 1, function(row) {
  section <- subset(ceramicSections, itemid==row['itemid'] & sectionid==row['sectionid'])
  plot(section$x_cm,section$y_cm, pch=".",cex=3,asp=1,main=section[1,]['itemid'])
  readline("continue? ")
  
  
} )

dbDisconnect(pgconnect)