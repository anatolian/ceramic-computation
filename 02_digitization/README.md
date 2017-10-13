# digitization files

The main digitization was done with the open source software ImageJ. Each individual image file containing a single pottery section drawing was opened in ImageJ and a series of steps were used to automatically trace the outline of the profile and save it to a .csv file as a series of x, y coordinate points.  The imagej subfolder here contains a macro for startup of the software that configures the software for use during this process.

A second process was also used to get to the 2d profile drawings.  A 3d scan of a sherd was loaded into the software called Pottery3d (p3d) and described in xx.  This semi-automated process creates a section drawing.  The drawing is then printed as an eps file from the software.  This is the only way we could discover to extract the actual points of the 2d profile drawing.

The script in epsOutlineTrace.R was written specifically to parse the exported eps from the p3d software.

The p3d software also exports a tiff file, and this is put into the correct file system folder structure using the copyDrawings.R script.