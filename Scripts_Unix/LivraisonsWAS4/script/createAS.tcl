#  --------------------------------------------------------------------
#  Le fichier createAS.tcl contient les procedures suivantes
#  createAS         : Creation d'un ApplicationServer
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
global nodeName asName 
set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"
#
# Creation de l'ApplicationServer
#

proc createAS {} {

	global ASattributelist asName errorCode fullAsName 

	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [ApplicationServer show "$fullAsName" -attribute none]}
    	if {$errorCode == 2} {
		puts "\nApplicationServer $asName en cours de creation"
		ApplicationServer create "$fullAsName" -attribute $ASattributelist
		if {$errorCode ==0} {
                        puts "\nCreation de l'ApplicationServer $asName reussie\n"
                }
  	} else {
      		puts "\nL'ApplicationServer $asName existe deja. Veuillez changer le nom dans le fichier de variables.\n"
	}
}
