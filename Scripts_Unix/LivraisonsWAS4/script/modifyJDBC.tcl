#  --------------------------------------------------------------------
#  Le fichier createJDBC.tcl contient les procedures suivantes
#  createJDBC  : Creation du ou des Dirver JDBC
#  --------------------------------------------------------------------


#
# Creation des Driver JDBC
#
proc modifyJDBC {} {

	global errorCode nodeInstalled jdbcDriverName jdbcZipfileLocation DriverAttributelist

        set errorCode 0
	set fullDriverName "/JDBCDriver:$jdbcDriverName/"

	# Creation du JDBC Driver sur le domaine WAS

	   catch {set try [JDBCDriver show "$fullDriverName" -attribute none]}
    	   if {$errorCode == 0} {
	     	set errorCode 0
	     	puts "\nJDBC $jdbcDriverName en cours de modification"
	     	JDBCDriver remove "$fullDriverName"
	     	JDBCDriver create "$fullDriverName"  -attribute $DriverAttributelist
		if {$errorCode == 0} {
			puts "\nModification de JDBC $jdbcDriverName reussie"
                } else {
			puts "\nProbleme lors de la creation du JDBCDriver $fullDriverName"
		}
           } else {
                puts "\nLe JDBCDriver $jdbcDriverName existe deja. Veuillez changer le nom dans le fichier de variables."
           }

	# Installation du ou des Driver sur les noeuds WAS predefinis
	set errorCode 0
	catch {set try [JDBCDriver show "$fullDriverName" -attribute none]}

        if {$errorCode == 0} {

	      for {set i 0} {$i < [llength $nodeInstalled]} {incr i} {
		catch {JDBCDriver install "$fullDriverName"  -node "/Node:[lindex $nodeInstalled $i]/" -jarFile "[lindex $jdbcZipfileLocation $i]"}
		 if {$errorCode ==0} {
			puts "\nInstallation du JDBCDriver $jdbcDriverName sur [lindex $nodeInstalled $i] reussie\n"
		 } else {
		       puts "\nUne erreur s'est produite lors de l'installation sur le noeud [lindex $nodeInstalled $i].\n"
		 }
	      }
	}
}
