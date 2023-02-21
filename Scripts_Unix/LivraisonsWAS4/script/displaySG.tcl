#  --------------------------------------------------------------------
#  Le fichier displaySG.tcl contient les procedures suivantes
#  displaySG    : Affiche les proprietes d'un ServerGroup
#  --------------------------------------------------------------------

#
# Affichage des proprietes d'un ServerGroup
#
proc displaySG {} {

	global fullSgName sgName errorCode 

	set fullSgName "/ServerGroup:$sgName/"
	set errorCode 0

        catch {set try [ServerGroup show "$fullSgName" -attribute none]}

        if {$errorCode == 2} {
        	puts "\nLe ServerGroup $sgName n'existe pas.\n"
        } else {
		puts "\n--- Proprietes du ServerGroup $sgName ---"
		set attrs [ServerGroup show "$fullSgName" -attribute "Name FullName IfStarted EJBServerAttributes" ]
		foreach attr $attrs {
                puts "\n>> $attr"
                }
        }
}
