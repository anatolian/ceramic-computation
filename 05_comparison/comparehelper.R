# A set of functions that are used by the main comparison script.  These are abstracted out in order to 
# separate calculations from program flow control.

# this function converts the database rows into an array of individual rims by grouping all the points in a single section
GetRimArray<-function(rims) {
  
  rimidlist<-unique(rims[c("itemid","sectionid")])
  
  rimarray<-array(list(),dim=c(1,2))
  
  for(i in 1:nrow(rimidlist)) {
    rimid<-rimidlist[i,]
    rim<-subset(rims,itemid==rimid[1,]$itemid & sectionid==rimid[1,]$sectionid)
    
    rimarray[[i,1]]<-rimid
    rimarray[[i,2]]<-rim
    
    rimarray<-rbind(rimarray,array(list(),dim=c(1,2)))
  }
  rimarray<-rimarray[-dim(rimarray)[1],]
}

plotRim<-function(rimArray){
  rim<-GetSpecificCeramicSection(rimArray[[1]]$itemid,rimArray[[1]]$sectionid)
  par(mar=c(5.1,6.1,4.1,2.1))
  plot(cbind(rim$x_cm,rim$y_cm),asp=1,pch=".",cex=3,main=rimArray[[1]]$itemid,xlab="distance from centerline",ylab="height below rim",cex.lab=2,cex.axis=1.5,cex.main=1.5)
}

# As we compare two sections, we only compare the length of the chords as much as they overlap.  Thus we need to bound by the shorter chord.
GetMaxCommonChord<-function(mainRimChord,comRimChord) {
  mainRimMaxX<-max(mainRimChord)
  comRimMaxX<-max(comRimChord)
  
  return(min(mainRimMaxX,comRimMaxX))
}

GetMinCommonChord<-function(mainRimChord,comRimChord) {
  mainRimMinX<-min(mainRimChord)
  comRimMinX<-min(comRimChord)
  
  return(max(mainRimMinX,comRimMinX))
}

# calculate the differences between the two sections using one specified mathematical representation
GetDifference<-function(mainRim,comRim,name) {
  xMax<-GetMaxCommonChord(mainRim[,1],comRim[,1])
  xMin<-GetMinCommonChord(mainRim[,1],comRim[,1])
  
  # here we remap the curves in such a way that they have points that directly match each other in distance along the chord, using spline
  # line up all of the points along the x access using a spline fit of 1000 points
  # note that it may be possible just to use a trapizoidal rule to calculate the area under the raw points,
  # with the catch being that you'd have to interpolate the endpoint on the curve that didn't have xMin and xMax
  mainSpline<-spline(cbind(mainRim[,1],mainRim[,2]),n=1000,xmin=xMin,xmax=xMax)
  comSpline<-spline(cbind(comRim[,1],comRim[,2]),n=1000,xmin=xMin,xmax=xMax)

  # calculate the square of the difference at each x point between the curves
  # since the distance between x points is constant (xmax-xmin)/1000, then we can cancel the deltachord
  curveSquareDifferences<-cbind(mainSpline$x,(mainSpline$y-comSpline$y)^2)
  differenceRMS<-round(sqrt(sum(curveSquareDifferences[,2])/1000),3)

  # the simple distance between each point on the curves, averaged
  curveDifferences<-cbind(mainSpline$x,abs(mainSpline$y-comSpline$y))
  differenceAverage<-round(sum(curveDifferences[,2])/1000,3)


  #matplot(mainSpline$x, cbind(mainSpline$y,comSpline$y,curveDifferences[,2], curveSquareDifferences[,2]),pch=".",asp=1,cex=3,xlab="chord",ylab="y")
  #matplot(mainSpline$x, cbind(mainSpline$y,comSpline$y,curveDifferences[,2]),pch=".",asp=1,cex=3,xlab="chord",ylab="y",cex.lab=2,cex.axis=1.5,main=name,cex.main=2)
  #points(mainRim[,1],mainRim[,2],cex=0.8)
  #points(comRim[,1],comRim[,2],cex=0.8,col="red")


  res<-cbind(differenceAverage,differenceRMS)
  colnames(res)<-cbind(paste(name,"DifferenceAverage",sep=""),paste(name,"DifferenceRMS",sep=""))
 # print(res)
  
  return(res)
}

# Here we build the database-ready results table of all the differences of the mathematical comparisons
# for each type of comparison, the above difference function is called once and the result is added as the next column
GetAllDifference<-function(mainRim,comRim,mainRimHasRadius,comRimHasRadius) {
  res<-cbind(itemid1=mainRim[[1]]$itemid,sectionid1=mainRim[[1]]$sectionid,itemid2=comRim[[1]]$itemid,sectionid2=comRim[[1]]$sectionid)

  # if one of the rims to be compared lacks a radius, we will artifically increase the value ofr the radius measurement by 2 times, since
  # we can't be sure how close these are.  At the same time, we will normalize the radius measurements for direct comparison
  noRadiusMultiplier <- 1
  if (mainRimHasRadius && !comRimHasRadius) {
    mainRimRadius <- mainRim[[2]]$radius_cm[which (mainRim[[2]]$chord_length == 0)]
    comRim[[2]]$radius_cm<-comRim[[2]]$radius_cm + mainRimRadius
    noRadiusMultiplier <- 2
  } else if (comRimHasRadius && !mainRimHasRadius) {
    comRimRadius <- comRim[[2]]$radius_cm[which (comRim[[2]]$chord_length == 0)]
    mainRim[[2]]$radius_cm<-mainRim[[2]]$radius_cm + comRimRadius
    noRadiusMultiplier <- 2
  } else if (!comRimHasRadius && !mainRimHasRadius)
  {
    noRadiusMultiplier <- 2
  }
  
  # run each difference in turn to store in the next column
  res<-cbind(res,noRadiusMultiplier*GetDifference(cbind(mainRim[[2]]$chord_length,mainRim[[2]]$radius_cm),cbind(comRim[[2]]$chord_length,comRim[[2]]$radius_cm),"radius"))
  #readline("radius")
  res<-cbind(res,GetDifference(cbind(mainRim[[2]]$chord_length,mainRim[[2]]$tangent_rad),cbind(comRim[[2]]$chord_length,comRim[[2]]$tangent_rad),"tangent"))
  #readline("tangent")
  res<-cbind(res,GetDifference(cbind(mainRim[[2]]$chord_length,mainRim[[2]]$curvature),cbind(comRim[[2]]$chord_length,comRim[[2]]$curvature),"curvature"))
  #readline("curve")
  return(res)
}

# normalization stores the area under each curve both as average and as root mean square
# this can help average out the sizes of the sections across the entire dataset
GetNormalizationFactors<-function(mainRim,mainRimHasRadius) {
  chord_length<-max(mainRim[[2]]$chord_length)-min(mainRim[[2]]$chord_length)

  # use the trapizoidal area to calculate the integral - ie area under each curve
  #  1. figure out the distance between each point on the x access (the chord length):
  deltaChord<-mainRim[[2]]$chord_length[-1] - mainRim[[2]]$chord_length[-length(mainRim[[2]]$chord_length)]
  
  #  2. average each pair of y values to get the average height in the middle of each delta chord
  #     results are changed to positive absolute values, which should only matter for the curvature
  averageRadiusValues<-abs((mainRim[[2]]$radius_cm[-1] + mainRim[[2]]$radius_cm[-length(mainRim[[2]]$radius_cm)])/2)
  averageTangentValues<-abs((mainRim[[2]]$tangent_rad[-1] + mainRim[[2]]$tangent_rad[-length(mainRim[[2]]$tangent_rad)])/2)
  averageCurvatureValues<-abs((mainRim[[2]]$curvature[-1] + mainRim[[2]]$curvature[-length(mainRim[[2]]$curvature)])/2)
  
  #  3. figure out the plain average of each y value using the area (integral) calculation - this takes into account variety
  #     in delta chord lengths
  radiusAverage<-round(sum(averageRadiusValues*deltaChord)/chord_length,3)
  tangentAverage<-round(sum(averageTangentValues*deltaChord)/chord_length,3)
  curvatureAverage<-round(sum(averageCurvatureValues*deltaChord)/chord_length,3)
  
  #  4. get the root mean square value for each y value
  radiusRMS<-round(sqrt(sum(averageRadiusValues^2*deltaChord)/chord_length),3)
  tangentRMS<-round(sqrt(sum(averageTangentValues^2*deltaChord)/chord_length),3)
  curvatureRMS<-round(sqrt(sum(averageCurvatureValues^2*deltaChord)/chord_length),3)
  
  if (!mainRimHasRadius)
  {
    radiusAverage <- NA
    radiusRMS <- NA
  }
  normalizationFactors<-cbind(itemid=mainRim[[1]]$itemid,sectionid=mainRim[[1]]$sectionid,radiusAverage,radiusRMS,tangentAverage,tangentRMS,curvatureAverage,curvatureRMS)

  #print(normalizationFactors)
  return(normalizationFactors)
}

PlotSection<-function(rim,sections) {
  print(rim[[1]]['itemid'])
  section <- subset(sections, itemid==as.integer(rim[[1]]['itemid']) & sectionid==as.integer(rim[[1]]['sectionid']))
  plot(section$x_cm,section$y_cm, pch=".",cex=3,asp=1,main=section[1,]['itemid'])
}