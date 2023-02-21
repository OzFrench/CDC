#  --------------------------------------------------------------------
#  Le fichier displayAS.tcl contient les procedures suivantes
#  displayAS    : Affiche les proprietes d'un ApplicationServer
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
global nodeName asName 
set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"
#
# Affichage des proprietes d'un ApplicationServer
#
proc displayAS {} {

	global asName fullAsName errorCode
	set errorCode 0
        catch {set try [ApplicationServer show "$fullAsName" -attribute none]}
  
        if {$errorCode == 2} {
        	puts "\nL'ApplicationServer $asName n'existe pas.\n"
        } else {
		puts "\n--- Certaines proprietes de l'ApplicationServer $asName ---"
		set attrs [ApplicationServer show "$fullAsName" -attribute "Name CurrentState DesiredState WorkingDirectory Stdout Stderr JVMConfig ModuleVisibility"]
		foreach attr $attrs {
                puts "\n>> $attr"
                }
        }
}

