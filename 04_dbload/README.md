# Database Loading Files

The files in this folder take the .csv files that model the sections and were created in previous scripts and loads them into the database.  Specifically, the profile x,y points are loaded into the ceramics_sections table.

Most of the work of loading the files is done using the loadceramics.R and loadhelper.R scripts.

The figureDPI.R and figureMetadata.R scripts allow us to store additional information about the profile drawing files.  These scripts use the command line image processing software ImageMagick, open source software that can be downloaded from the internet.