# Experimental code to convert rgb values to Munsell values based on a selected part of the sherd in the image
# experiment with the munsell R library didn't produce great results, but values scraped from http://www.vcsconsulting.co.uk/VirtualAtlas.htm 
# and stored in the database worked out better
library(jpeg)
library(raster)
library(munsell)

source("../01_include/pg.R")
source("../01_include/subfolder.R")

#rgb2munsell <- read.table(paste(collectionsBasePath,"rgbmunsell.csv",sep=""), header=TRUE,sep=",")
#rgb2munsell2 <- read.table(paste(collectionsBasePath,"rgbmunsell2.csv",sep=""), header=TRUE,sep=",")
munsellRGBTable <- GetMunsellRGBTable()
extension<-"JPG"

#dev.off()
print(collectionsBasePath)
fileList <- list.files(path=collectionsImageBasePath, pattern=paste("*_1.",extension,sep=""))

for(file in fileList)
{
  figureid <- sub(paste("_1.",extension,sep=""),"",x=file)  # each image file named for the figureid from the original publication
  #if(substr(figureid,nchar(figureid),nchar(figureid)+1) != 1) {next}
  
  itemid <- GetItemIdFromFigureId(citation,figureid)
  print(itemid)
  if (is.null(itemid) || itemid == 5458 || itemid==5459) { next }
  currentImage<-readJPEG(paste(collectionsImageBasePath,file,sep=""))
  # set the plot size based on image size, then display the raster, correcting for left-right
  plot(c(0,dim(currentImage)[2]),c(0,dim(currentImage)[1]),asp=1)
  
  
  rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2],ytop=dim(currentImage)[1])
  
  point<-locator(n=2)
  rect(min(point$x),min(point$y),max(point$x),max(point$y))
  
  xleft<-round(min(point$x))
  xright<-round(max(point$x))
  ybottom<-round(dim(currentImage)[1]-max(point$y))
  ytop<-round(dim(currentImage)[1]-min(point$y))
  
  subsetPixels<-currentImage[ybottom:ytop,,][,xleft:xright,]
  red<-mean(subsetPixels[1,,][,1])
  green<-mean(subsetPixels[1,,][,2])
  blue<-mean(subsetPixels[1,,][,3])
  
  print(paste("average colors selected: ",red,green,blue,red*255,green*255,blue*255))
  munsell<-rgb2mnsl(red,green,blue)
  print(paste("munsell by function: ",munsell))
  
#  munsellDistance<-cbind(rgb2munsell,((red*255)-rgb2munsell["R"])^2+((green*255)-rgb2munsell["G"])^2+((blue*255)-rgb2munsell["B"])^2)
#  closeMunsell<-munsellDistance[order(munsellDistance[8]),][1:2,]
#  print(closeMunsell)

  munsellDistance<-cbind(munsellRGBTable,((red*255)-munsellRGBTable["red"])^2+((green*255)-munsellRGBTable["green"])^2+((blue*255)-munsellRGBTable["blue"])^2)
  closeMunsell<-munsellDistance[order(munsellDistance[8]),][1:2,]
  print(closeMunsell)
  hue<-closeMunsell[1,]["hue"]
  lightness_value<-closeMunsell[1,]["lightness_value"]
  chroma<-closeMunsell[1,]["chroma"]
  
  color<-rgb(red,green,blue)
  rect(dim(currentImage)[2]-600,dim(currentImage)[1]-400,dim(currentImage)[2],dim(currentImage)[1],col=color)
  
  InsertMunsellExteriorSurface(itemid,hue,lightness_value,chroma)
  
  out<-readline("hitenter")
  if (out=='s')
  { dbDisconnect(pgconnect)
    stop("done")}
}
dbDisconnect(pgconnect)