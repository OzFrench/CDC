#  --------------------------------------------------------------------
#  Le fichier displayVH.tcl contient les procedures suivantes
#  displayVH        : Affiche les proprietes d'un VirtualHost 
#  --------------------------------------------------------------------



#
# Affichage des proprietes d'un Virtual Host
#
proc displayVH {} {

	global virtualhost vhName errorCode 
	set virtualhost /VirtualHost:$vhName/
	set errorCode 0
	
        catch {set try [VirtualHost show "/VirtualHost:$vhName/" -attribute none]}
        if {$errorCode == 2} {
        	puts "\nLe VirtualHost $vhName n'existe pas.\n"
        } else {
		puts "\n--- Proprietes du VirtualHost $vhName ---"
		set attrs [VirtualHost show $virtualhost -attribute "Name FullName AliasList"]
		foreach attr $attrs {
                puts "\n>> $attr"
                }
        }
}

