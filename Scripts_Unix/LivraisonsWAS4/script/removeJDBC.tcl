#  --------------------------------------------------------------------
#  Le fichier createJDBC.tcl contient les procedures suivantes
#  createJDBC  : Creation du ou des Dirver JDBC
#  --------------------------------------------------------------------


#
# Suppression des Driver JDBC
#
proc removeJDBC {} {

	global errorCode nodeInstalled jdbcDriverName jdbcZipfileLocation DriverAttributelist

        set errorCode 0
	set fullDriverName "/JDBCDriver:$jdbcDriverName/"

	# Suppression du JDBC Driver sur le domaine WAS

	   catch {set try [JDBCDriver show "$fullDriverName" -attribute none]}
    	   if {$errorCode != 2} {
	     set errorCOde 0
	     puts "\nJDBC $jdbcDriverName en cours de suppression"		
	     JDBCDriver remove "$fullDriverName"
		if {$errorCode == 0} {
                    puts "\nSuppression du JDBCDriver $jdbcDriverName reussie\n"
                } else {
		    puts "\nProbleme lors de la suppression du JDBCDrive $jdbcDriverName"
		}
           } else {
                puts "\nLe JDBCDriver $jdbcDriverName n'existe pas. Veuillez changer le nom dans le fichier de variables."
	   }
}
