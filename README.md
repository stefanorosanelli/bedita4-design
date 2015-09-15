# BEdita 4 design

## Database structure

Goals in new BE4 design:

  * performance optimizations
  * better names for tables, fields
  * simpler/clearer structure


###Conventions:
 * table and field names all undescored lowercase
 * don't name index, unique, primary fileds unless they consist of more then one field 


###Principles:
 * use VARCHAR only if field limits are known, otherwise use TINYTEXT, TEXT, MEDIUMTEXT, LONGTEXT
 * use MEDIUMTEXT for JSON fields, from MySQL 5.7.8 native JSON data type
 * for indexed fields don't use *TEXT type, but VARCHAR - maximum size still 255
 
 
###Optimizations
 * reduce number of tables and joins
 * remove unused fields/tables
 * optimize fieds types and dim without losing redability 
 