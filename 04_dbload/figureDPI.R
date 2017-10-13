# helper script to read the print resolution of an image file, using the Imagemagick command line tool
# imgPath <- readline("Folder for files? ")
imgPath <- "C:/inetpub/wwwroot/xx/"


fileList <- list.files(path=imgPath, pattern="*.tif")

for(file in fileList){
  figure <- paste(imgPath,file,sep="")
  command<- paste("identify -quiet -format '%x' \"",figure,"\"",sep="")
  
  r<-shell(command, intern=TRUE)
  dpi<-as.integer(strsplit(r,"'")[[1]][2])
  
  if (dpi!=300){
    print(command)
    print(dpi)
  }
}