# this script functions similar to checkOutlines.R, but gets the list of images to check from the database.
# this script has not been fully updated recently, and really should be combined with the previous script
library(tiff)
source("../01_include/pg.R")

#dbGetQuery(pgconnect,"SET client_encoding = 'windows-1252'")
basePath<-"C:/inetpub/wwwroot/"

items<-GetItemsInProcess()
Encoding(items$site_name)<-"UTF-8"
Encoding(items$citation)<-"UTF-8"


pointsSubpath <- "rim-points-radius/"
imageScale<-29.5
foundStart<-FALSE

startAt<-"xx"
stepLoop<-F
checkImages<-F
#flipHorizontal<-T

#fileList <- list.files(path=mainPath, pattern="*.tif")

for(i in 1:nrow(items)){
  item<-items[i,]
  figureid <- item["figureid"]
  mainPath<-paste(basePath,item$citation,"/finds/",sep="")
  csvFile<-paste(mainPath,pointsSubpath,figureid,".csv",sep="")
  file<-paste(figureid,".tif",sep="")

  print(csvFile)
  print(file)
  if (startAt==figureid) {foundStart=TRUE}
  
  if (file.exists(csvFile) && foundStart)
  {
    currentImage<-readTIFF(paste(mainPath,file,sep=""))
    
    rawcoordinates <- read.table(csvFile, header=TRUE,sep=",")
    #translated<-cbind(rawcoordinates[,1]-rawcoordinates[1,]$X,rawcoordinates[,2]-rawcoordinates[1,]$Y)
    translated<-cbind(rawcoordinates[,1],rawcoordinates[,2]-min(rawcoordinates[,2]))
    xatminy <- round(max(translated[,1][which(translated[,2]==0)])*2,2)
    print(xatminy)
    
    plot(c(0,dim(currentImage)[2]/imageScale),c(0,dim(currentImage)[1]/imageScale),asp=1,main=paste(figureid,"-",xatminy))
    if (item$citation=="Bayne 2000")
    {
      rasterImage(currentImage,xleft=dim(currentImage)[2]/imageScale,ybottom=0,xright=0,ytop=dim(currentImage)[1]/imageScale)
    } else {
      rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2]/imageScale,ytop=dim(currentImage)[1]/imageScale)
    }
    
    testy<-1
    while (testy>0) {    
      origin<-point<-locator(n=1)
      
      plot(c(0,dim(currentImage)[2]/imageScale),c(0,dim(currentImage)[1]/imageScale),asp=1,main=paste(figureid,"-",xatminy))
      
      if (item$citation=="xx") # if a citation needs to reverse the image
      {
        rasterImage(currentImage,xleft=dim(currentImage)[2]/imageScale,ybottom=0,xright=0,ytop=dim(currentImage)[1]/imageScale)
      } else {
        rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2]/imageScale,ytop=dim(currentImage)[1]/imageScale)
      }
      #print (origin)
      #print(translated[,1]+origin$x)
      points(x=translated[,1]+origin$x,y=origin$y-translated[,2],pch=".",cex=3,col="red")
      points(x=translated[,1][1]+origin$x,y=origin$y-translated[,2][1],pch="+",col="blue")
      points(x=translated[,1][5]+origin$x,y=origin$y-translated[,2][5],pch=".",cex=3,col="green")
      
      testy<-origin$y
    }
    
    if (stepLoop) {
      foundStart <- FALSE
      startAt <- readline("next start? ")
    }
  } 
  else if (!file.exists(csvFile) && foundStart)
  {
    print("NoCSV")
    currentImage<-readTIFF(paste(mainPath,file,sep=""))
    
    plot(c(0,dim(currentImage)[2]/imageScale),c(0,dim(currentImage)[1]/imageScale),asp=1,main=figureid)
    rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2]/imageScale,ytop=dim(currentImage)[1]/imageScale)
    
    testy<-1
    while (testy>0) {    
      origin<-point<-locator(n=1)
      
      testy<-origin$y
    }
  }
  
  
}
