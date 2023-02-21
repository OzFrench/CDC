#  --------------------------------------------------------------------
#  Le fichier displayAttribute.tcl contient les procedures suivantes
#  displayAS    : Affiche les proprietes d'un objet WAS donne
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
global nodeName asName 
set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"

#
# Affichage des proprietes d'un ApplicationServer
#
proc displayOB {object} {

	global asName fullAsName errorCode
	set errorCode 0
        catch {set try [$object showall "$fullAsName" -attribute none]}
  
        if {$errorCode == 2} {
        } else {
		puts "\n--- Certaines proprietes de l'ApplicationServer $asName ---"
		set attrs [$object show "$fullAsName" -all]
		foreach attr $attrs {
		     puts "\n  $attr"
		 
                }
        }
}

