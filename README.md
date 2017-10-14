# Ceramic Computation
R scripts for digitizing, processing, analyzing, and comparing archaeological ceramic 2d profile drawings, photographs, and other data

## Overview
This code was written with the goal of being able to automate 2d shape analysis of archaeological ceramics, particularly profile drawings of rim sherds.  Much of the work and code was designed to help extract shape data from paper publications about archaeology.  These publications contain printed profile drawings that are scanned, cropped into individual image files, and then traced as points.  The next step is to load those points into a database for analysis and mathematical manipulation, as well as association with other structured descriptive data such as context information.  In this case, postgresql was used, however any rdbms would work.  Finally, a variety of mathematical manipulations are used to compare the shape-as-point representations of the pottery sherds.  Although this is the main workflow, some side workflows and utilities have also reached experimental development phase and are included in this code base.

These scripts were written by me, Peter Cobb.  They were written quickly, and although effort has been made to go back and document and clean the code a bit, these are still rapidly developed scripts.  There are limitations to their functionality and you may run into additional issues when attempting to run them.  Pull requests with improvements are welcome.

## Organization
The folders here are organized:
 * 01_include
   * Scripts that are used by all other folders and processes
 * 02_digitization
    * Tracing of the images is done in the open source ImageJ software, with some supporting scripts
 * 03_pointfilemanipulation
    * The ImageJ exports often need some tweaking for standardization
 * 04_dbload
    * Once the point files are ready, they can be loaded into the database
 * 05_comparison
    * The main goal is to compare 2d rim profile shapes
 * 06_otheranalysis
    * Additional experimental analysis
 * 10_other
    * Other utility scripts
 
Note that the folder structure assumes that the current working directory for R should be set to the root folder.
 
## File and Data structures
As we move through each step of the process in the scripts of the subfolders, the database structure and the file paths used by the scripts will be individually introduced.

At a high level, there are two ways data are organized, the publication or the collection.  A publication is a paper book containing the pottery drawings.  Each publication is uniquely identified by its basic citation, which is last name of first author and year.  An et al can be added for multiauthor, and a letter suffix can be added to the year if the author has multiple publications.  Much of the processing and scripts are aimed at these individual publications.  Collections, on the other hand, are groups of sherds not from a publication.  They are from collections in museums, archives, or at individual digs - that were 3d scanned and photographed.  Collections are organized by siteid, which is a unique numeric identifier for each archaeological site.  These two concepts, the publication and the collection, are used in the file structure on the harddrive that organizes the images files and connects them to the database.

Within the database, the main tables are items, sites, and ceramic_sections.

The items table is a list of all of the individual ceramic sherds, each uniquely identified by an itemid, this number is also used to name image files on the filesystem.  Each item, whether from publication or collection, is from a site, and has an associated siteid.

A subtable of the items table is the items_figures table.  Within this table, the identifier figureid is unique per citation (ie per publication), and just identifies the drawing or photograph in that publication.  An individual itemid can have multiple figureid's and be illustrated in multiple publications.

The sites table listed all of the sites, each identified by a unique siteid.  The latitude and longitude of the center of each site is also stored in this table for mapping.

The ceramic_sections table contains a row for each point along the ceramic section.  Since one item may have multiple section drawings, they each get a unique sectionid.  All of the points receive a pointid which is unique within the section.  The x_cm and y_cm stores the coordinates of each individual points, at 1:1 scale to the real sherd.  The top point of a rim sherd is set to a y value of 0, so most y values are negative.  The x value is set based on the radius of the vessel, if known.  If the radius is not known, the left-most point is set to 0 arbitrarily.  Note that all sections should be on the right side of the center line, with positive x values.  Note also that this system assumes rotational symmetry.
