# sometimes the ImageJ process creates too dense a set of points, this removes every so many points in order to thin out the dataset
source("01_include/subfolder.R")

fullPath<-rimNoRadiusPointsPath

# we will create a backup file just in case
fullPointsBackupPath<-paste(backupBasePath,"finds/points-full/",sep="")

if (!dir.exists(fullPointsBackupPath))
  {dir.create(fullPointsBackupPath,recursive = T)}

# see other scripts for information on these flags
foundStart<-FALSE
startAt<-"xx_dwg"
stepLoop<-T
oneLoop<-T
every<-2  # the interval of points to remove
avoid<-F # do we remove every interval point, or do we invert the selection and remove everything else

fileList <- list.files(path=fullPath, pattern="*.csv")

for(file in fileList){
  
  figureid <- sub(".csv","",x=file)
  csvFile<-paste(fullPath,file,sep="")
  if (startAt==figureid) {foundStart=TRUE}
  
  if (file.exists(csvFile) && foundStart)
  {
    # make a backup copy
    if (!(res<-file.copy(csvFile,paste(fullPointsBackupPath,file,sep=""),overwrite=T))) {stop("filesaving problem")}
    print(res)
    
    rawcoordinates <- read.table(csvFile, header=TRUE,sep=",")
    # this selects the points at every interval
    ind <- seq(1, nrow(rawcoordinates), by=every)
    if (avoid) { ind<- -ind} # do the inverse selection if avoid is set
    
    write.table(rawcoordinates[ind,],file=csvFile,row.names=F,sep=",")
  
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