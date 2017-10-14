# Point File Manipulation

Once we have gathered a csv file from either the ImageJ tracing process or the p3d eps export process, we next need to check the data, and perhaps make some minor tweaks to the data.

The checkOutline.R script loads both the csv file as points and the original image file of the profile section drawing, enabling direct comparison of the two.  The user clicks on the center of the vessel at the rim level, and the points should perfectly outline the profile drawing.  Three additional scripts enable quick cleanup of these csv point files.

The checkOutlinesFromDB.R script functions similar to the previous script, but gets the list of files to check from the database.

The following scripts can be used alone, but also have been added into the checkOutline script for quicker use.

reversePoints.R - The order of the points is important, it should always be from bottom outside surface to bottom inside surface.  Sometimes ImageJ exports in the other direction, so this script can fix that.

diameterShift.R - For drawings where the radius was unknown, we want to shift the points so the leftmost point is at 0 for X.  There may also be other reasons for shifting the points along the x-axis.

subsetPoints.R - The calculations work out best when each section is represented by a similar amount of points.  If ImageJ creates too many points, we can simply remove points at some standard interval.
