# Comparison of Profiles

This folder contains scripts to use mathematical functions to quantitatively compare profile drawings.

The compareceramics.R script loops through the ceramic sections in the database and uses the three math models of the sections already computed and stored in the database.  It compares each individual sherd to every other individual sherd, and calculates a quantity that represents difference between the two samples.  In this way, one can start to track and organize sherds by closeness of shape.

The comparehelper.R script abstracts some of the calculations from the program control of the main script.

These scripts follow the mathematical models from two publications:

"Towards computerized typology and classification of ceramics," by Ayelet Gilboa, Avshalom Karasik, Ilan Sharon, and Uzy Smilansky
in the *Journal of Archaeological Science*, Volume 31 (2004), Pages 681–694

"Computerized morphological classification of ceramics," by Avshalom Karasik and Uzy Smilansky
in the *Journal of Archaeological Science*, Volume 38 (2011), Pages 2644-2657
