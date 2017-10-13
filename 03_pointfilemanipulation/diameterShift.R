# shifts the x values so that the leftmost point gets an x value of 0, and everything else lines up with that.
# The purpose is to work with rim drawings without a radius
source("../01_include/subfolder.R")

fullPath<- rimRadiusPointsPath
#fullPath<- rimNoRadiusPointsPath

#loop through the image files until first one found
foundStart<-F
startAt<-"xx_dwg"
stepLoop<-F  # step loop slows down the processing so that the next target sherd can be indicated after each loop
oneLoop<-T  # run just once on the startAt image

newDir<-""

fileList <- list.files(path=fullPath, pattern="*.csv")

for(file in fileList){
  
  figureid <- sub(".csv","",x=file)
  csvFile<-paste(fullPath,file,sep="")
  if (startAt==figureid) {foundStart=TRUE}
  
  if (file.exists(csvFile) && foundStart)
  {    
    print(file)
    rawcoordinates <- read.table(csvFile, header=TRUE,sep=",")

    #miny<-min(rawcoordinates["Y"])
    minx<-min(rawcoordinates["X"])  # determine the smallest x value
    #xatminy <- max(rawcoordinates$X[which(rawcoordinates["Y"]==miny)])
    shift<-  -minx # shift everything else by the smallest x value negatively
    
    # store the values again
    rawcoordinates["X"]<-shift+rawcoordinates["X"]
    
    # resave the file
    newpath<-paste(fullPath,newDir,file,sep="")
    write.table(rawcoordinates,file=newpath,row.names=F,sep=",")
  
    if (oneLoop)
    {
      stop("done")
    }
    
    
    if (stepLoop) {
      foundStart <- FALSE
      startAt <- readline("next start? ")
      if (startAt=="")
      {
        stop("done")
      }
    }
  }
  

}