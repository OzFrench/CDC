#  --------------------------------------------------------------------
#  Le fichier displayWebContainer.tcl contient les procedures suivantes
#  displayWC    : Affiche les proprietes du WebContainer d'un ApplicationServer
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
proc displayWC {} {

	global sgName fullSgName errorCode
	set fullSgName "/ServerGroup:$sgName/"
	set errorCode 0
        catch {set try [ServerGroup show "$fullSgName" -attribute none]}
  
        if {$errorCode == 2} {
        	puts "\nLe ServerGroup $sgName n'existe pas.\n"
        } else {
		set attrs [ServerGroup show "$fullSgName" -attribute "Name EJBServerAttributes"]
		puts "\n--- proprietes du WebContainer du ServerGroup $sgName ---"
        	foreach attr $attrs {
                	puts "\n>> $attr"
                }
	}
}
