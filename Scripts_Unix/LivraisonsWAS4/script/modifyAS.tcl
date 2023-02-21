#  --------------------------------------------------------------------
#  Le fichier modifyAS.tcl contient les procedures suivantes
#  modifyAS         : Creation d'un ApplicationServer
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
global nodeName asName 
set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"
#
# Creation de l'ApplicationServer
#

proc modifyAS {} {

	global ASattributelist asName errorCode fullAsName 

    	set errorCode 0
	catch {set try [ApplicationServer show "$fullAsName" -attribute none]}
    	if {$errorCode == 0} {
		ApplicationServer stop "$fullAsName"
		ApplicationServer modify "$fullAsName" -attribute $ASattributelist
		if {$errorCode ==0} {
                        ApplicationServer start "$fullAsName"
			puts "\nModification de l'ApplicationServer $asName reussie\n"
                } else {
			puts "\nProbleme lors de la modification de l'ApplicationServer $asName"
		}
		 
  	} else {
      		puts "\nL'ApplicationServer $asName n'existe pas.\n"
	}
}
