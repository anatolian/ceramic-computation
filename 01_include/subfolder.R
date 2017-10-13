# here we point to the place where we are going to work on image files on the filesystem, depending on whether what you are working on is organized
# as a collection or as a publication
# a set of variables are setup here that can be used in other scripts

#processingType<-"collections"
processingType<-"publications"

# first we set the base path, to which everything else is relative
# mainPath <- readline("Folder for csv files? ")
basePath<- "C:/images/"
typeBasePath<- paste (basePath,"publications/",sep="")
if (processingType == "collections")
{
  typeBasePath <- paste (basePath,"collections/",sep="")
}

# these values would be changed per run of the script to indicate which citation or site we are working on
siteid<-1
citation <- "xxxx 19xx/"

subPath <- citation
if (processingType == "collections")
{
  subPath <- siteid
}

# photographs and drawings are stored in the finds subfolder, 3dscans processed with Pottery3D in the 3dscans folder, and 
# backups provides an output for scripts
imageSubPath<-"/finds/"
scanSubPath<-"/3dscans/"
backupSubPath<-"/backups/"

# these scripts were initially written only to process rim sherds, with a distinction between those drawings that indicated radius and those
# that did not
rimRadiusPointsSubpath <- "rim-points-radius/"
rimNoRadiusPointsSubpath <- "rim-points-noradius/"

imageBasePath <- paste(typeBasePath,subPath,imageSubPath,sep="")
backupBasePath <- paste(typeBasePath,subPath,backupSubPath,sep="")
scanBasePath <- paste(typeBasePath,subPath,scanSubPath,sep="")

rimRadiusPointsPath <- paste(imageBasePath,rimRadiusPointsSubpath,sep="")
rimNoRadiusPointsPath <- paste(imageBasePath,rimNoRadiusPointsSubpath,sep="")
