# The purpose of this workflow is to visually check the accuracy of the traces of raster images of sherd profiles
# that were digitized using the ImageJ process.  Each tif image file from the target folder is loaded into
# this script together with its cooresponding csv file of xy coordinates.  The user clicks a start point on the image (top of rim, center of vessel)
# and the dots are drawn at proper scale over the image.  The first dot is marked with a blue cross and the fifth dot 
# is green so the direction of the dots is clear.  Move to the next image by clicking anywhere below 0 on the y axis.
library(tiff)

source("../01_include/subfolder.R")

mainPath<-imageBasePath
print(mainPath)

# These folders show where the point csv files were saved.  Some rims do not have known radii, they need to be kept separate.
#rimRadiusPointsSubpath <- "rim-points-radius"
#rimNoRadiusPointsSubpath <- "rim-points-noradius"
pointsType<-""  # a plot label to identify which folder the points were found in
titleSize<-1

# to equate pixels in the raster to dots in the point set, need to convert dpi to cm (taking account for print scale)
imageScale<-29.5  # 29.5 is 300 dpi and 1/4 scale images

# just loops until it finds the specified first image
foundStart<-F
startAt<-"xx_dwg"
  
stepLoop<-F        # to target specific images, request next image name at each step
flipHorizontal<-F  # the profile should be on the right, so may need to flip images from publications that don't default that way

# work through all of the image files in the collection or publication, starting with the startAt image
fileList <- list.files(path=mainPath, pattern="*.tif")

for(file in fileList){
  
  figureid <- sub(".tif","",x=file)  # each image file named for the figureid from the original publication
  csvFile<-paste(mainPath,rimRadiusPointsSubpath,"/",figureid,".csv",sep="")
  writeClipboard(figureid, format = 1) # this helps if we need to run another script on that particular file
  
  # default to checking for rim points with a radius specified, move next to no radius, finally to no points
  if (file.exists(csvFile))
  {
    pointsType<-""
    titleSize<-1
  } else {
    csvFile<-paste(mainPath,rimNoRadiusPointsSubpath,"/",figureid,".csv",sep="")
    titleSize<-4
    if (file.exists(csvFile))
    {
      pointsType<-"NO-Rad"
    } else {
      csvFile <- ""
      pointsType<-"No Points"
    }
  }
  
  if (startAt==figureid) {foundStart=TRUE}

  if (file.exists(csvFile) && foundStart) # if there is a point file, load everything for display
  {
    currentImage<-readTIFF(paste(mainPath,file,sep=""))
    
    rawcoordinates <- read.table(csvFile, header=TRUE,sep=",")
    print(nrow(rawcoordinates))
    titleColor<-"black"
    # if there are too many points, indicate this, the user can subset the points
    if (nrow(rawcoordinates)>200)
    {
      titleColor<-"red"
    }
    # digitzed sherds have the y-axis at their center line, but extend beyond the top of the sherd, shift the y so that the top of the sherd is x-axis 
    translated<-cbind(rawcoordinates[,1],rawcoordinates[,2]-min(rawcoordinates[,2]))
    #translated<-cbind(rawcoordinates[,1]-rawcoordinates[1,]$X,rawcoordinates[,2]-rawcoordinates[1,]$Y)  # this was to set the click point as origin
    
    # set the plot size based on image size, then display the raster, correcting for left-right
    plot(c(0,dim(currentImage)[2]/imageScale),c(0,dim(currentImage)[1]/imageScale),asp=1,main=paste(figureid,pointsType),cex.main=titleSize,col.main=titleColor)
    # now load the actual tiff file and map it to scale in the plot window
    if (flipHorizontal)
    {
      rasterImage(currentImage,xleft=dim(currentImage)[2]/imageScale,ybottom=0,xright=0,ytop=dim(currentImage)[1]/imageScale)
    } else {
      rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2]/imageScale,ytop=dim(currentImage)[1]/imageScale)
    }
    
    # origin will be the mouse click point, should be center of the vessel at the top of the rim, which helps verify radius
    # clicking below the x-axis, ie y<0 moves to next image
    testy<-1  # the y value from origin
    while (testy>0) {    
      origin<-point<-locator(n=1)
      
      # redraw the image in order to erase the points
      if (flipHorizontal)
      {
        rasterImage(currentImage,xleft=dim(currentImage)[2]/imageScale,ybottom=0,xright=0,ytop=dim(currentImage)[1]/imageScale)
      } else {
        rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2]/imageScale,ytop=dim(currentImage)[1]/imageScale)
      }
      # print the points over the image, the first and 5th point get different symbology to clarify which direction the points are going
      points(x=translated[,1]+origin$x,y=origin$y-translated[,2],pch=".",cex=3,col="red")
      points(x=translated[,1][1]+origin$x,y=origin$y-translated[,2][1],pch="+",col="blue")
      points(x=translated[,1][5]+origin$x,y=origin$y-translated[,2][5],pch=".",cex=3,col="green")
      points(x=translated[,1][nrow(translated)]+origin$x,y=origin$y-translated[,2][nrow(translated)],pch="o",cex=0.75,col="yellow")
      
      # a few shortcuts for processing points were built into the process, and duplicate functionality from external scripts.  
      # These are all activited based on where you click
      testy<-origin$y
      # a shortcut for reducing the number of points
      if (origin$x<0 && testy>dim(currentImage)[1]/imageScale)
      {
        byValue<-2
        subs<-readline(paste("Are you sure you want to subset by ",byValue,"? ",sep=""))
        if (subs=="y")
        {
          ind <- seq(1, nrow(rawcoordinates), by=byValue)
          rawcoordinates<-rawcoordinates[ind,]
          write.table(rawcoordinates,file=csvFile,row.names=F,sep=",")
          translated<-cbind(rawcoordinates[,1],rawcoordinates[,2]-min(rawcoordinates[,2]))
        }  # clicking too high will stop the program
      } else if (testy>dim(currentImage)[1]/imageScale) {
          stop("out") # clicking far to the left will do a reverse of the points
      } else if (origin$x<0) {
        print("rev")
        rawcoordinates<-rawcoordinates[rev(rownames(rawcoordinates)),]
        write.table(rawcoordinates,file=csvFile,row.names=F,sep=",")
        translated<-cbind(rawcoordinates[,1],rawcoordinates[,2]-min(rawcoordinates[,2]))
      }
    }
    
    # if in a step loop, ask the user for next image number
    if (stepLoop) {
      foundStart <- FALSE
      startAt <- readline("next start? ")
    }
  } 
  else if (!file.exists(csvFile) && foundStart)  # if a point file hasn't yet been created, display the image file only
  {
    currentImage<-readTIFF(paste(mainPath,file,sep=""))
    
    plot(c(0,dim(currentImage)[2]/imageScale),c(0,dim(currentImage)[1]/imageScale),asp=1,main=paste(figureid,pointsType),cex.main=titleSize)
    rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2]/imageScale,ytop=dim(currentImage)[1]/imageScale)
    
    testy<-1
    while (testy>0) {    
      origin<-point<-locator(n=1)
      
      testy<-origin$y
      if (testy>dim(currentImage)[1]/imageScale)
      {
        stop("out")
      }
    }
  }
}
