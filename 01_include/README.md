# Includes

 * .config 
  * file stores your postgresql database accounts and passwords, so it will be customized per project
 * subfolder.R
  * A way to abstract the set of files you are working on during any particular run of the scripts
 * pg.R
  * Holds all of the functions that interact with the database in postgresql
 * db.plain
  * Contains the basic sql for the table structures referenced by pg.R.  Here we have the items and sites table, along with all the related tables.  References contains the citations to publications.