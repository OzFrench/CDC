#  --------------------------------------------------------------------
#  Le fichier modifyVH.tcl contient les procedures suivantes
#  modifyVH         : Creation d'un VirtualHost
#  --------------------------------------------------------------------


#
# Modification du VirtualHost
#
proc modifyVH {} {

	global VHattributelist vhName errorCode 
	set virtualhost /VirtualHost:$vhName/


	# Si le VirtualHost n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [VirtualHost show "/VirtualHost:$vhName/" -attribute none]}
    	if {$errorCode != 2} {
		set errorCode 0
		puts "\nVirtualHost $vhName en cours de modification"
		VirtualHost modify $virtualhost -attribute $VHattributelist
		if {$errorCode ==0} {
                        puts "\nModification du VirtualHost  $vhName reussie\n"
                } else {
			puts "\nProbleme lors de la modification du VirtualHost $vhName"
		}
  	} else {
      		puts "\nLe VirtualHost $vhName n'existe pas. Veuillez changer le nom dans le fichier de variables.\n"
	}
}
