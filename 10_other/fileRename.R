# A simple script to do renaming tasks on the image files
source("../01_include/subfolder.R")

extension<-".csv"
#mainPath<- collectionsImageBasePath
mainPath<- collectionsRimRadiusPointsPath

fileList <- list.files(path=mainPath, pattern=paste("*",extension,sep=""))
for(file in fileList)
{
  figureid <- sub(extension,"",x=file)
  oldName<-paste(mainPath,file,sep="")
  print(oldName)
  newName<-paste(mainPath,figureid,"_1",extension,sep="")
  print(newName)
  file.rename(oldName,newName)
}