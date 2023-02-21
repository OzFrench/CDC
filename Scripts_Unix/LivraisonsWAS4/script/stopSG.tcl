#  --------------------------------------------------------------------
#  Le fichier stopSG.tcl contient les procedures suivantes
#  stopSG          : Arret d'un ServerGroup
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
#
# Arret de l'Application Server
#

proc stopSG {} {

	global fullSgName sgName errorCode
	set fullSgName "/ServerGroup:$sgName/"
	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [ServerGroup show "$fullSgName" -attribute none]}
    	if {$errorCode != 2} {
		ServerGroup stop "$fullSgName"
		if {$errorCode ==0} {
                        puts "\nArret du Server Group $sgName reussie\n"
                }
  	} else {
      		puts "\nLe Server Group $sgName n'existe pas."
	}
}
