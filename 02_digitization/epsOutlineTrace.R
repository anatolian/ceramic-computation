# This is a special script that takes the eps export from p3d and extracts the x, y coordinates for the profile drawing
library("jpeg")
library("grImport")
source("01_include/subfolder.R")

# loop through the 3d scans folder, the eps is always put in the same place in the folder hiearchy by p3d
dirList <- list.dirs(path=scanBasePath, full.names=FALSE, recursive=FALSE)
outlineSubFile<- "/3ds/p3d/outline.eps"
# a file prefix is used to indentify images from a collection
filePrefix<-""
foundStart<-F

# create an output location for the file we will create
if (!dir.exists(rimRadiusPointsPath))
  {dir.create(rimRadiusPointsPath)}

# loop through each item in the collection subfolder
for(dir in sort(as.numeric(dirList)))
{
  #print(dir)
  #if (dir==24){next()}  If you want to skip a particular item
  
  # this is the eps file of the object that we are currently working on
  targetOutline <- paste(scanBasePath,dir,outlineSubFile,sep="")
  print(targetOutline)
  
  # if the outline does not exist, show the image so we can figure out what went wrong
  if (!file.exists(targetOutline)) {
    
    currentImage<-readJPEG(paste(imageBasePath,filePrefix,dir,"_1.JPG",sep=""))
    plot(c(0,dim(currentImage)[2]),c(0,dim(currentImage)[1]),asp=1)
    rasterImage(currentImage,xleft=0,ybottom=0,xright=dim(currentImage)[2],ytop=dim(currentImage)[1])
    
    print("NO OUTLINE")
    out<-readline("Nooutline")
    next
  }
  # clear the plotting area
  plot(1,1)
  
  #convert the EPS to a temporary xml
  PostScriptTrace(targetOutline,"c:/temp/out.xml",charpath=FALSE)
  
  #read the temporary xml
  petal<-readPicture("c:/temp/out.xml")
  
  
  # set scale
  # find any two x or y grid lines, and then using their cm values, find
  # the conversion factor for all x and y values
  # don't forget to reverse y's for the other import process, you could even shift 
  # to zero for the top point now
  # also the x value needs to find zero, which is just using the conversion factor
  # and adjusting for the actual x written on the chart
  # x line labels seem to follow their above marked dotted lines, get actual x from the line
  
  outlinePath<-1
  textfindcount<-0
  #find the dots of the outline, ie where the rgb is blue #0000FF
  for (i in 1:length(petal@paths)) 
  { 
    #print(i)
    if(!is.null(petal@paths[i]$path))
    { 
      if (petal@paths[i]$path@rgb == "#0000FF")
      {
        outlinePath<-i
        break
      }
     # print(petal@paths[i]$path@rgb)
    } 
    else if (!is.null(petal@paths[i]$text))
    {
      if (textfindcount==0)
      {
        firsttext_realx<-as.integer(petal@paths[i]$text@string)
        firsttext_localx<-petal@paths[i-1]$path@x[1]
        textfindcount<-1
      } else if (textfindcount==1)
      {
        secondtext_realx<-as.integer(petal@paths[i]$text@string)
        secondtext_localx<-petal@paths[i-1]$path@x[1]
        textfindcount<-2
      }
  
    }
  }
  print(paste(firsttext_realx,firsttext_localx, secondtext_realx,secondtext_localx))
  deltareal<- secondtext_realx-firsttext_realx
  deltalocal<- secondtext_localx-firsttext_localx
  
  localscale<-10*deltalocal/deltareal
  print(localscale)
  
  grid.picture(petal)
  #out<-readline("hi")
  
  #from that outline, you get the actual x and y coordinates
  #petal@paths[69]$path@x
  #petal@paths[69]$path@y
  xminlocal<-petal@summary@xscale["xmin"]
  
  xmin<- ((xminlocal-firsttext_localx)/localscale)+firsttext_realx/10
  xmax<- ((petal@summary@xscale["xmax"]-firsttext_localx)/localscale)+firsttext_realx/10
  
  ymaxlocal<- petal@summary@yscale["ymax"]
  ymin<- (ymaxlocal-petal@summary@yscale["ymin"])/localscale
  ymax<- 0
  dev.new()
  print(paste(xmin,ymin,xmax,ymax))
  print(outlinePath)
  plot(x=xmin,xlim=c(xmin,xmax),ylim=c(ymin,ymax),asp=1)
  #outline<-104
  xpoints<-((petal@paths[outlinePath]$path@x-firsttext_localx)/localscale)+firsttext_realx/10
  ypoints<- (ymaxlocal-petal@paths[outlinePath]$path@y)/localscale
  points(x=xpoints ,y= ypoints,pch=".")
  
  # copy the csv to the destination
  newpath<-paste(rimRadiusPointsPath,filePrefix,dir,"_dwg.csv",sep="")
  write.table(cbind(xpoints,ypoints),file=newpath,col.names=c("X","Y"), row.names=F,sep=",")
  
  out<- readline("hi")
  if (out=="s")
  {stop("here")}
}
