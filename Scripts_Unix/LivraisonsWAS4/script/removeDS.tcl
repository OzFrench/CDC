#  --------------------------------------------------------------------
#  Le fichier removeDS.tcl contient les procedures suivantes
#  removeDS  : Suppression du ou des Dirver JDBC
#  --------------------------------------------------------------------


#
# Creation des datasources 
#
proc removeDS {} {

	global errorCode DSattributelist dataSourceName jdbcDriverName

        set errorCode 0

	set fullDsName "/JDBCDriver:$jdbcDriverName/DataSource:$dataSourceName/"

	# Creation du ou des datasources

	   for {set i 0} {$i < [llength $dataSourceName]} {incr i} {
	
	      catch {set try [DataSource show "/JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i]/" -attribute none]}
	
              if {$errorCode != 2} {
		 set errorCode 0
		 puts "\nDatasource [lindex $dataSourceName $i] en cours de suppression"
	         DataSource remove "/JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i]/"

		 if {$errorCode ==0} {
                    puts "\nSuppression du Datasource [lindex $dataSourceName $i] reussie\n"
		 } else {
		    puts "\nProbleme lors de la suppression du DataSource [lindex $dataSourceName $i]"
		 }
              } else {
                puts "\nLe Datasource [lindex $dataSourceName $i] n\'existe pas. Veuillez changer le nom dans le fichier de variables."
              }
       	   }
}
