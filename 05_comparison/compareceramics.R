# This script loops through a subset of the ceramic sections in the database and compares each section to every other section
source("../01_include/pg.R")
source("comparehelper.R")

# We can constrain the itemids that are processed, this allows partial processing of the dataset
startAtOrAbove<-1
endBelow<-xx # stop processing when the itemid passes this number
endAbove<-xx # stop processing when the itemid is less than this number
  
# There are various datasets made available in the database that we can process
#rimArray<-GetRimArray(GetCeramicSectionRimMath())
rimArray<-GetRimArray(GetCeramicSectionRimMathWithoutDisabled(startAtOrAbove))
#rimArray<-GetRimArray(GetCeramicSectionRimRadiusMath())
#rimArray<-GetRimArray(GetCeramicSectionRimMathInProcess())
#ceramicSections <- GetCeramicSection()

# it is useful to watch the process of comparison, we can even slow it down to see individual comparisons
layout (matrix(c(1,3,1,3,1,4,2,4,2,5,2,5),6,2,byrow=T),widths=c(1,3))
endtime<-proc.time()["elapsed"]
# cycle through each rim, and compare with all remaining rims in set 
while (dim(rimArray)[1] > 2) {

  mainRim<-rimArray[1,]
  mainRimHasRadius = FALSE
  if (GetCeramicSectionRimType(mainRim[[1]]$itemid)=="rim with radius")
  {
    mainRimHasRadius = TRUE
  }
#  print (mainRimHasRadius)
  print (mainRim[[1]]$itemid)
  if (mainRim[[1]]$itemid >= endBelow) { stop("end")}
  if (mainRim[[1]]$itemid < endAbove) { stop("end")}
  
  # we clear all data, then use normalization to try to more directly compare all sherds
  ClearCeramicCompareData(mainRim[[1]]$itemid,mainRim[[1]]$sectionid)
  normalizationFactors<-GetNormalizationFactors(mainRim,mainRimHasRadius)
  WriteNormalization(normalizationFactors)
  
  # loop through the other sherds in the database
  rimArray<-rimArray[-1,]
  for(i in 1:nrow(rimArray)) {
    comRim<-rimArray[i,]  # the comparison rim
    #plotRim(mainRim)
    #readline("mainrim")
    
    #plotRim(comRim)
    
    #PlotSection(mainRim,ceramicSections)
    #readline("plot")
    #PlotSection(comRim,ceramicSections)
    #readline("plot")
    
    comRimHasRadius = FALSE
    if (GetCeramicSectionRimType(comRim[[1]]$itemid)=="rim with radius")
    {
      comRimHasRadius = TRUE
    }
#    print (comRimHasRadius)
    
    # here is the function to calculate all the differences
    allDifference<-GetAllDifference(mainRim,comRim,mainRimHasRadius,comRimHasRadius)
    #print(allDifference)
    WriteCompare(allDifference)
    
  }
  starttime<-endtime # keep track of the time it is taking
  endtime<-proc.time()["elapsed"]
  print(endtime-starttime)
  #out<-readline("comrim")
  #if (out=="s") {stop("done")}
}


stop("out")

# Given the way the loop above runs, we need to compare the final two sherds separately
ClearCeramicCompareData(rimArray[1,][[1]]$itemid,rimArray[1,][[1]]$sectionid)
ClearCeramicCompareData(rimArray[2,][[1]]$itemid,rimArray[2,][[1]]$sectionid)

plotRim(rimArray[1,])
#readline("mainrim")

plotRim(rimArray[2,])
#readline("comrim")

mainRimHasRadius = FALSE
if (GetCeramicSectionRimType(rimArray[1,][[1]]$itemid)=="rim with radius")
{
  mainRimHasRadius = TRUE
}
#print (mainRimHasRadius)

normalizationFactors<-GetNormalizationFactors(rimArray[1,],mainRimHasRadius)
WriteNormalization(normalizationFactors)

comRimHasRadius = FALSE
if (GetCeramicSectionRimType(rimArray[2,][[1]]$itemid)=="rim with radius")
{
  comRimHasRadius = TRUE
}
#print (comRimHasRadius)
normalizationFactors<-GetNormalizationFactors(rimArray[2,],comRimHasRadius)
WriteNormalization(normalizationFactors)

allDifference<-GetAllDifference(rimArray[1,],rimArray[2,],mainRimHasRadius,comRimHasRadius)
print(allDifference)
WriteCompare(allDifference)
readline("last") 

dbDisconnect(pgconnect)
