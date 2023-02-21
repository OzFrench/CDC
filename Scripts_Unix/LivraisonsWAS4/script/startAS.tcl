#  --------------------------------------------------------------------
#  Le fichier startAS.tcl contient les procedures suivantes
#  startAS          : Demarrage d'un ApplicationServer
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
#
# Demarrage de l'Application Server
#

proc startAS {} {

	global fullAsName errorCode
	set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"
	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [ApplicationServer show "$fullAsName" -attribute none]}
    	if {$errorCode != 2} {
		ApplicationServer start "$fullAsName"
		if {$errorCode ==0} {
                        puts "\nDemarrage de l'ApplicationServer $asName reussie\n"
                }
  	} else {
      		puts "\nL'ApplicationServer $asName n'existe pas."
	}
}
