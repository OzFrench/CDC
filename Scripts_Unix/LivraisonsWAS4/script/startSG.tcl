#  --------------------------------------------------------------------
#  Le fichier startSG.tcl contient les procedures suivantes
#  startSG          : Demarrage d'un ServerGroup
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
#
# Demarrage de l'Application Server
#

proc startSG {} {

	global fullSgName sgName errorCode
	set fullSgName "/ServerGroup:$sgName/"
	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [ServerGroup show "$fullSgName" -attribute none]}
    	if {$errorCode != 2} {
		ServerGroup start "$fullSgName"
		if {$errorCode ==0} {
                        puts "\nDemarrage du Server Group $sgName reussie\n"
                }
  	} else {
      		puts "\nLe Server Group $sgName n'existe pas."
	}
}
