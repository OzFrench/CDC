#  --------------------------------------------------------------------
#  Le fichier modifyDS.tcl contient les procedures suivantes
#  modifyDS  : Modification du ou des Dirver JDBC
#  --------------------------------------------------------------------


#
# Creation des datasources 
#
proc modifyDS {} {

	global errorCode DSattributelist dataSourceName jdbcDriverName

        set errorCode 0

	set fullDsName "/JDBCDriver:$jdbcDriverName/DataSource:$dataSourceName/"

	# Creation du ou des datasources

	   for {set i 0} {$i < [llength $dataSourceName]} {incr i} {
	
	      catch {set try [DataSource show "/JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i]/" -attribute none]}
	
              if {$errorCode != 2} {
		 set errorCode 0
		 puts "\nDatasource [lindex $dataSourceName $i] en cours de modification"
	         DataSource modify "/JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i]/"  -attribute [lindex $DSattributelist $i]

		 if {$errorCode ==0} {
                    puts "\nModification du Datasource [lindex $dataSourceName $i] reussie\n"
		 } else {
		    puts "\nProbleme lors de la modification du DataSource [lindex $dataSourceName $i]"
		 }
              } else {
                puts "\nLe Datasource [lindex $dataSourceName $i] n\'existe pas. Veuillez changer le nom dans le fichier de variables."
		puts "\n"
              }
       	   }
}
