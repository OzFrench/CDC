#  --------------------------------------------------------------------
#  Le fichier displayDS.tcl contient les procedures suivantes
#  displayDS  : Affichage des proprietes du ou des Datasources
#  --------------------------------------------------------------------


#
# Affichage Proprietes des datasources 
#
proc displayDS {} {

	global errorCode dataSourceName jdbcDriverName

        set errorCode 0

	set fullDsName "/JDBCDriver:$jdbcDriverName/DataSource:$dataSourceName/"

	# Affichage du ou des datasources

	puts "\n--- Affichage des proprietes des Datasources  ---\n"
	
	for {set i 0} {$i < [llength $dataSourceName]} {incr i} {
	
	      catch {set try [DataSource show "/JDBCDriver:$jdbcDriverName/DataSource:[lindex $dataSourceName $i]/" -all]}
	
              if {$errorCode == 0} {
		
		 foreach attr $try {
                       puts "\n>> $attr"
                    }

              } else {
                puts "\nLe Datasource [lindex $dataSourceName $i] existe deja. Veuillez changer le nom dans le fichier de variables."
		puts "\n"
              }
	  puts "\n" 
	}
}
