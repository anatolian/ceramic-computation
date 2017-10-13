# Assistance functions for loading rim sections from .csv files into the database, including computing certain mathematical calculations on them.

# Chord length is length along the profile line, so between each pair of points we calculate a distance and add that up. 
ChordLength<-function(M, zero) { 
  # The M[-dim(M)[1]] simply removes the final row, and the M[1,] duplicates the first row, so that distances can be subtracted to the 
  # previous point: at the first point this returns zero, we end at the last point.
  onelessM<-rbind(M[1,],M[-(dim(M)[1]),])
  # Apply accross all row pairs a summation of the sqrt of the squared difference (Euclidean distance) between points,
  # this gives a simple array of distances from the start point along the line.
  temp <- cumsum(sqrt((M$X-onelessM$X)^2 +(M$Y-onelessM$Y)^2)) 
  # Shift so that zero is at the rim point, so that all sherds 'start' at the same place, ie the rim top.
  temp<-temp-temp[zero]
  temp<-cbind(M$pointid,temp)
  colnames(temp)<-c("pointid","chord")
  return (temp)
}

# The arctan trigonmetric function is used to determine the angle, in radians, based on x and y changes.
# atan2 uses signs of the variables to determine the quadrant, as opposed to plain atan.
ArctanAssist<-function(M) {
  res=atan2(M["deltay"],M["deltax"])
  if(res<0) {res=(2*pi)+res} # This makes the positive X axis of the circle 0 and 2pi, so all values are positive around the circle counterclockwise.
                             # This prevents a discontunity when crossing the rim point which would otherwise jump from pi to -pi.
  return(res)  
}

# Determine the angle of a tangent line from the next point to the current point.
Tangent<-function(chord,coordinates) {
  # Subtract each y and x from the next to the current point using arrays that don't contain the first and last elements.
  deltay<-coordinates$Y[-1]-coordinates$Y[-(dim(coordinates)[1])]
  deltax<-coordinates$X[-1]-coordinates$X[-(dim(coordinates)[1])]
  tanres<-apply(cbind(deltay,deltax),1,ArctanAssist)  # Run them through the arctan function to get the angles in radians.
  
  # The following section is for the boundary condition when crossing the positive x axis, ie when deltay is zero and deltax is positive.
  # This might happen if the sherd's exterior surface dips before rising again to the rim.
  # We are generally not expecting too many values in the 4th or bottom right quandrant of the circle, since rims don't usually dip that way, but it can happen.
  # If it dips below the positive x, you would have small radians all of the sudden jump up to radians just below 2pi, which would create an abnormality in the chart.
  # We want a smooth curve for the tangent, so we put the boundary (redline) at an arbitrary place within the 4th quadrant (between 1.5pi and 2pi, ie 4.71 to 6.28).
  # The ultimate goal is that you cross pi radians at the rim point (ie heading towards negative x along the x axis), and the remaining points flow gently in all other areas.
  
  redline<-5
  # if we begin with a downward slope, the following 'check and adjust' function won't start correctly, so 
  # we need to bump down the initial value into negative territory so that we can grow from there
  if (tanres[1]>redline)
  {
    tanres[1]=-((2*pi)-tanres[1]) 
  }
  for (i in 2:length(tanres))
  {
    if((tanres[i]-tanres[i-1])>redline) {  # A sudden jump from just above the positive x (previous point) to just below (current point) is like 2pi-0.
      tanres[i]=-((2*pi)-tanres[i])        # So adjust to a small negative tangent for this point.
    } else if ((tanres[i]-tanres[i-1])<(-redline)) {  # On the other hand a jump from just below the positive x (previous point) to just above (current point) is like 0-2pi.
      tanres[i]=(2*pi)+tanres[i]                      # So adjust to a value for this point that is a little above 2pi.
    }
  }
  
  # Tangents are indexed by chord position.  There are n-1 points since the final point is subtracted from the penultimate point.
  # The tangent is the angle at the current point towards the next point.
  chordtan<-cbind(chord[-dim(chord)[1],],tanres)
  colnames(chordtan)<-c("pointid","chord","theta")
  return(chordtan)
}

# Curvature measures  the rate of change of the angles (tangents) between points.
# In order to smooth out common irregularities in the data, the angles are averaged over a specified range.
# In this way, when the angle goes up or down slightly, these values are zeroed out from each other.
Curvature<-function(tangent,averageRange) {
  if (averageRange>1)
  {
    chordCurve<-vector()
    newEnd<-length(tangent[,"theta"])-averageRange
    interval<-averageRange-1
    
    for (currentIndex in 1:newEnd)
    {
      # the next set is just one up from the current set
      nextIndex<-currentIndex+1

      # The averages of the next and prior sets
      nextMean<-mean(tangent[,"theta"][nextIndex:(nextIndex+interval)])
      priorMean<-mean(tangent[,"theta"][currentIndex:(currentIndex+interval)])
  
      # normalize by chord length to factor in the changes
      deltaChord<-tangent[,"chord"][(nextIndex+interval)]-tangent[,"chord"][nextIndex]
      # what is the change between the average curves?
      deltaCurve<-nextMean-priorMean

      # what is the curvature
      curve<-deltaCurve/deltaChord
      
      center<-round((averageRange/2)+0.5)
      curChord<-tangent[,"chord"][currentIndex+center]
      pointid<-tangent[,"pointid"][currentIndex+center]
    
      chordCurve<-rbind(chordCurve,c(pointid,curChord,curve))
    }
  }
  else
  {
    # subtract the next chord or tangent value from the current
    deltachord<-tangent[,"chord"][-1]-tangent[,"chord"][-length(tangent[,"chord"])]
    deltatheta<-tangent[,"theta"][-1]-tangent[,"theta"][-length(tangent[,"theta"])]
    
    # normalize by the distance so that a particular angle change will have a larger impact if it was over shorter distances
    curve<-deltatheta/deltachord
    
    #shift back the chord lengths because the tangents change at the forward point
    # we measured tangent from point 1 to point 2, then point 2 to point 3, so the first curvature change happens at point 2 along the chord
    chordCurve<-cbind(tangent[,"pointid"][-1],tangent[,"chord"][-1], curve)
  }
    
  colnames(chordCurve)<-c("pointid","chord","curve")
  return(chordCurve)
}

# all y values should be in negative centimeters below the rim, and the rim should be set to zero
# since the rim is at the top (generally speaking)
TranslateYToRim<-function(rawcoordinates,upsidedown) {
  M<-rawcoordinates
  
  miny <- min(M["Y"])
  
  if (upsidedown) {miny<-max(M["Y"])}
  M["Y"]<-apply(M["Y"],2,function(y) y=miny-y)
  return(M)
}

# take x at the rimpoint and multiple by 2, rounding to 2 decimal places
GetRimDiameter<-function(M) {
  xatminy <- max(M$X[which(M["Y"]==0)]) 
  return(round(xatminy*2,2))
}

# the top of the rim should be y=0, so among the possible multiple points with this characteristic, choose the furthest out
GetRimPointNumber<-function(M) {
  xatminy <- max(M$X[which(M["Y"]==0)]) 
  return(M$pointid[which(M$X==xatminy & M$Y==0)])
}

GetMaxBodyDiameter<-function(M) {
  maxx <- max(M["X"])
  return(round(maxx*2,2))
}

GetMaxPreservedHeight<-function(M) {
  lowy <- min(M["Y"])
  highy <- max(M["Y"])
  return(round(highy-lowy,2)) 
}

# during the read we can do things like determine the diameter and preserved height
GetRimProperties<-function(M,rimRadius) {
  df<-data.frame()
  df<-rbind(df,data.frame("Preserved Height",GetMaxPreservedHeight(M),stringsAsFactors=F))
  
  if (rimRadius)
  {
    df<-rbind(df,c("Body Diameter",GetMaxBodyDiameter(M)))
    df<-rbind(df,c(as.character("Rim Diameter"),GetRimDiameter(M)))
  }
  
  df<-rbind(df,c("Rim Point Id",GetRimPointNumber(M)))
  names(df)<-c("name","value")
  return(df)
}