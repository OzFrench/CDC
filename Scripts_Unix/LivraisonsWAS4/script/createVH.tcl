#  --------------------------------------------------------------------
#  Le fichier createVH.tcl contient les procedures suivantes
#  createVH         : Creation d'un VirtualHost
#  --------------------------------------------------------------------


#
# Creation du VirtualHost
#
proc createVH {} {

	global VHattributelist vhName errorCode 
	set virtualhost /VirtualHost:$vhName/


	# Si le VirtualHost n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [VirtualHost show "/VirtualHost:$vhName/" -attribute none]}
    	if {$errorCode == 2} {
		VirtualHost create $virtualhost -attribute $VHattributelist
		if {$errorCode ==0} {
                        puts "\nCreation du VirtualHost  $vhName reussie\n"
                }
  	} else {
      		puts "\nLe VirtualHost $vhName existe deja. Veuillez changer le nom dans le fichier de variables.\n"
	}
}
