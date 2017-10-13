library(tiff)
# simple script to do basic y-normalization on the points from the csv files and load them into the database

source("../01_include/pg.R")
source("loadhelper.R")
source("../01_include/subfolder.R")

# are we loading the .csv files from drawings with radii or not?
rimRadius<-F

csvPath<-rimRadiusPointsPath
if (!rimRadius)
{
  csvPath<-rimNoRadiusPointsPath
}
imagePath<-imageBasePath
fileSuffix<-""
if (processingType=="collections")
{
  fileSuffix<-"_1"
}
print(csvPath)

# for re-running the script, we can start at any figure
foundStart <- F
beginReadAt <- "xx_dwg"
upsidedown<-F
# for the curvature calculation, we want to determine how many points are taken into consideration, how wide the leveling of the function will be
doCount<-5

# read all of the csv files
fileList <- list.files(path=csvPath, pattern="*.csv")
# setup a display in the plot window
layout (matrix(c(1,3,2,4,2,5,2,6,2,7),5,2,byrow=T),widths=c(1,3.5))

for(file in fileList)
{
  figureid <- sub(paste(fileSuffix,".csv",sep=""),"",x=file)
  print(figureid)
  if (figureid==beginReadAt) {foundStart=T}
  if (!foundStart) {next}
  
  # this allows us to possibily do other processing on the object
  writeClipboard(charToRaw(paste0(figureid, ' ')), format = 1)
  # since we start from publications, need to work back from printed figure number to the database unique id
  itemid <- GetItemIdFromFigureId(citation,figureid)
  print(itemid)
  
  currentImage<-readTIFF(paste(imagePath,figureid,fileSuffix,".tif",sep=""))
  plot(c(0,dim(currentImage)[2]/imageScale),c(0,dim(currentImage)[1]/imageScale),asp=1,ylab="",xlab="",yaxt="n",xaxt="n")
  rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2]/imageScale,ytop=dim(currentImage)[1]/imageScale)
  
  # renew the data for the ceramic each time
  ClearCeramicData(itemid)
  
  rawcoordinates <- read.table(paste(csvPath,file,sep=""), header=TRUE,sep=",")
  rawcoordinates<-cbind(as.numeric(rownames(rawcoordinates)),rawcoordinates)
  colnames(rawcoordinates)<-c("pointid","X","Y")
  
  # the original traces have Y values from an arbitrary top of the image above the rim, we want to shift them down to the rim
  finalcoordinates <- TranslateYToRim(rawcoordinates,upsidedown)
  # plot to verify the ceramic
  par(mar=c(5.1,6.2,4.1,2.1))
  plot(x=finalcoordinates$X,y=finalcoordinates$Y,asp=1,pch=".",cex=5,ylab="height below rim",xlab="distance from centerline",cex.lab=2,cex.axis=1.5)
  points(x=finalcoordinates$X[1],y=finalcoordinates$Y[1],pch="+",cex=2,col="blue")
  points(x=finalcoordinates$X[5],y=finalcoordinates$Y[5],pch=".",cex=10,col="green")

  type<-"rim with radius"
  if (!rimRadius)
    { type<-"rim without radius" }
  # write the coordinates to the db for future use
  WriteFinalCoordinates(itemid,finalcoordinates,type)
 # readline("c")
  
  # rim properties are such things as the preserved height, the diameter, and the top point along the rim
  properties<-GetRimProperties(finalcoordinates,rimRadius)
  WriteProperties(itemid,properties)
  print(properties)
  rimpoint<-as.numeric(properties$value[properties$name=="Rim Point Id"])
  points(x=finalcoordinates$X[rimpoint],y=finalcoordinates$Y[rimpoint],pch=".",cex=10,col="red")
  
  # determine the length between points and add them up to get the length of all points from the rim point
  # this data will be used in later calculations as the x-axis for measurements
  chordx<-ChordLength(finalcoordinates, rimpoint)
  radiusgraph<-cbind(chordx,finalcoordinates["X"]) 
  
  if (!rimRadius)
  { 
    radiusgraph<-cbind(chordx,finalcoordinates["X"]-finalcoordinates$X[rimpoint])
  }
  
  # radius graph just shows the distance from the center Y axis at each point according to its distance along the chord
  plot(x=radiusgraph$chord,y=radiusgraph$X,pch=".",cex=5,ylab="y",xlab="chord",cex.lab=2,cex.axis=1.5)
  #readline("e")
  
  
  # find the tangent, or angle, from each next point to the current point
  tangent<-Tangent(chordx,finalcoordinates)
  plot(x=tangent[,"chord"],y=tangent[,"theta"],pch=".",cex=8,col="red",ylab="y",xlab="chord",cex.lab=2,cex.axis=1.5)
  lines(x=tangent[,"chord"],y=tangent[,"theta"])
  #readline("t")
 
  # curavture is change in tangent
  curvature<-Curvature(tangent,1)
  plot(x=curvature[,"chord"],y=curvature[,"curve"],pch=".",cex=8,col="red",ylab="y",xlab="chord",cex.lab=2,cex.axis=1.5)
  lines(x=curvature[,"chord"],y=curvature[,"curve"])
  if (doCount == 3 || doCount == 5) 
    { curvature<-Curvature(tangent,3) }
  plot(x=curvature[,"chord"],y=curvature[,"curve"],pch=".",cex=8,col="red",ylab="y",xlab="chord",cex.lab=2,cex.axis=1.5)
  lines(x=curvature[,"chord"],y=curvature[,"curve"])
  if (doCount == 5)
   { curvature<-Curvature(tangent,5) }
  plot(x=curvature[,"chord"],y=curvature[,"curve"],pch=".",cex=8,col="red",ylab="y",xlab="chord",cex.lab=2,cex.axis=1.5)
  lines(x=curvature[,"chord"],y=curvature[,"curve"])
  
  #once all the calculations are complete, save everything to the database
  WriteMath(itemid,radiusgraph,tangent,curvature)
 
  out<-readline("hitenter")
  if (out=='s')
  { dbDisconnect(pgconnect)
    stop("done")}
}

dbDisconnect(pgconnect)
