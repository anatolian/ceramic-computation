# sometimes the ImageJ process accidentally orders the points from interior to exterior, so this script corrects for that
source("../01_include/subfolder.R")

mainPath<-rimRadiusPointsPath

print(mainPath)

# see notes in diameterShift.R for further notes on these flags
foundStart<-FALSE
startAt<-"xx_dwg"
stepLoop<-F
oneLoop<-F

newDir<-""

fileList <- list.files(path=mainPath, pattern="*.csv")

for(file in fileList){
  
  figureid <- sub(".csv","",x=file)
  csvFile<-paste(mainPath,file,sep="")
  if (startAt==figureid) {foundStart=TRUE}
  
  if (file.exists(csvFile) && foundStart)
  {    
    rawcoordinates <- read.table(csvFile, header=TRUE,sep=",")
    # this command reverses the order of the points
    reverseframe<-rawcoordinates[rev(rownames(rawcoordinates)),]
    
    newpath<-paste(mainPath,newDir,file,sep="")
    write.table(reverseframe,file=newpath,row.names=F,sep=",")
  
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