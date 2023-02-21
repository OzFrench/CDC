#  --------------------------------------------------------------------
#  Le fichier stopEA.tcl contient les procedures suivantes
#  stopEA           : Arret d'un EntrepriseApp
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#

#
# Arret de l'Entreprise Application
#

proc stopEA {} {

	global eaName errorCode fullEaName
	set fullEaName "/EnterpriseApp:$eaName/"
	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [EnterpriseApp show "$fullEaName" -attribute none]}
    	if {$errorCode != 2} {
		EnterpriseApp stop "$fullEaName"
		if {$errorCode ==0} {
                        puts "\nArret de l'EnterpriseApp $eaName reussie\n"
                }
  	} else {
      		puts "\nL'EnterpriseApp $eaName n'existe pas.\n"
		exit
	}
}
