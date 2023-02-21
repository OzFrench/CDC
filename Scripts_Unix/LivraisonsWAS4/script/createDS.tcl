#  --------------------------------------------------------------------
#  Le fichier createDS.tcl contient les procedures suivantes
#  createDS  : Creation du ou des Dirver JDBC
#  --------------------------------------------------------------------


#
# Creation des datasources 
#
proc createDS {} {

	global errorCode DSattributelist dataSourceName jdbcDriverName

        set errorCode 0
	puts "\nValeur de jdbcDriverName $jdbcDriverName"
	set fullDsName "/JDBCDriver:$jdbcDriverName/DataSource:$dataSourceName/"

	# Creation du ou des datasources

	   for {set i 0} {$i < [llength $dataSourceName]} {incr i} {
	      set errorCode 0
	      puts "\nOn verifie que le Data source /JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i] n existe pas"	
	      catch {set try [DataSource show "/JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i]/" -attribute none]}
	
              if {$errorCode == 2} {
		set errorCode 0
		puts "\nDataSource [lindex $dataSourceName $i] en cours de creation"
	        DataSource create "/JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i]/"  -attribute [lindex $DSattributelist $i]

		 if {$errorCode ==0} {
                    puts "\nCreation du Datasource [lindex $dataSourceName $i] reussie\n"
		 } else {
		 	puts "\nProbleme lors de la creation du DataSource [lindex $dataSourceName $i]"
		 }
              } else {
                puts "\nLe Datasource [lindex $dataSourceName $i] existe deja. Veuillez changer le nom dans le fichier de variables."
		puts "\n"
              }
	}
}
