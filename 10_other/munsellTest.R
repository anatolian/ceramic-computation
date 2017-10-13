# A simple script to view colors
source("../01_include/pg.R")

hue_shades<-GetMunsellByHue("N")

plot(x=0,xlim=c(0,100),ylim=c(100,0))
#plot(xright=100,xleft=0,ytop=0,ybottom=100)

for (i in 1:dim(hue_shades)[1])
{
  row<-hue_shades[i,]
  v<-row["lightness_value"]*10
  c<-row["chroma"]*10
  print(v)
  print(row)
  
  red<-row["red"]/255
  green<-row["green"]/255
  blue<-row["blue"]/255
  
  if (is.na(red)) {next}
  
  rect(c-10,v-10,c,v,col=rgb(red,green,blue))
  
}

dbDisconnect(pgconnect)
