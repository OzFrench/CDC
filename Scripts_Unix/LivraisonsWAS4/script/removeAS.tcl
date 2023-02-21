#  --------------------------------------------------------------------
#  Le fichier removeAS.tcl contient les procedures suivantes
#  removeAS          : Suppression d'un Application Server
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"

#
# Suppression de l'Application Server
#

proc removeAS {} {

	global asName errorCode fullAsName 

	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [ApplicationServer show "$fullAsName" -attribute none]}
    	if {$errorCode != 2} {
		set errorCode 0
		ApplicationServer remove "$fullAsName"
		if {$errorCode != 0} {
			puts "\nUne erreur s'est produite, verifiez que l'Application Server a ete arretee avant de le supprimer.\n"
		} else {
		      puts "\nSuppression de l'Application Server  $asName reussie\n"
		  }
  	 } else {
      	      puts "\nL'Application Server $asName n'existe pas.\n"
          }
}
