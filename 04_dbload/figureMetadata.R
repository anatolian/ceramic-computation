# This prepares the drawing image files for web display by recording in the database the properties such as image dimensions
# depends on an install of the ImageMagick command line tools
source("../01_include/pg.R")

# we can load image files directly from a webserver and saves it locally
fetchImage <- function(url) {
 return( tryCatch( { download.file(url,"c:/temp/tmp.tif",quiet=TRUE,mode="wb") },
        error=function(cond) { return(FALSE) }, finally={ return(TRUE) } ) )
}

figTab<-GetItemFigures()
# this provides an example if you are storing your images on multiple webservers
bases<-cbind(GetProcedureProperty("ceramics_figure_http_base1"), GetProcedureProperty("ceramics_figure_http_base2"))

end<-dim(figTab)[1]
#end<-10
for (i in 1:end) {
  row<-figTab[i,]
  url<-URLencode(paste(bases[row['server'][1,]],row['citation'][1,],"/finds/",row['figureid'][1,],".tif",sep=""))
  print(url)
  if (fetchImage(url)) 
  {
    # read height of the image files
    r<-shell("identify -format '%h' c:/temp/tmp.tif", intern=TRUE)
    height<-as.integer(strsplit(r,"'")[[1]][2])  
    
    # if we were able to get height, also get width and print resolution
    if (!is.na(height)){
      r<-shell("identify -format '%w' c:/temp/tmp.tif", intern=TRUE)  
      width<-as.integer(strsplit(r,"'")[[1]][2])
      r<-shell("identify -format '%x' c:/temp/tmp.tif", intern=TRUE)
      dpi<-as.integer(strsplit(r,"'")[[1]][2])
    
      WriteFigureProperties(row['itemid'][1,],row['citation'][1,],row['figureid'][1,],height,width,dpi)
    }
    print(paste(height,width,dpi))
  }
}

dbDisconnect(pgconnect)