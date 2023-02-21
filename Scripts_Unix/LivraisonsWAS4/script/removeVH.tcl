#  --------------------------------------------------------------------
#  Le fichier removeVH.tcl contient les procedures suivantes
#  removeVH         : Suppression d'un VirtualHost
#  --------------------------------------------------------------------


#
# Suppression du VirtualHost
#

proc removeVH {} {

	global vhName errorCode 
	set fullVhName /VirtualHost:$vhName/


	# Si le VirtualHost n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [VirtualHost show "$fullVhName" -attribute none]}
    	if {$errorCode != 2} {
		set errorCode 0
		VirtualHost remove $fullVhName 
		if {$errorCode != 0} {
                        puts "\nProbleme lors de la suppression du VirtualHost"
                } else {
			puts "\nSuppression du virtualhoste $vhName reussie"
		}
  	} else {
      		puts "\nLe VirtualHost $vhName n'existe pas. Veuillez changer le nom dans le fichier de variables.\n"
	}
}
