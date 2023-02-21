#  --------------------------------------------------------------------
#  Le fichier startEA.tcl contient les procedures suivantes
#  startEA          : Demarrage d'un EntrepriseApp
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
set fullEaName "/EnterpriseApp:$eaName/"

#
# Demarrage de l'Entreprise Application
#

proc startEA {} {

	global eaName errorCode fullEaName 

	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [EnterpriseApp show "$fullEaName" -attribute none]}
    	if {$errorCode != 2} {
		EnterpriseApp start "$fullEaName"
		if {$errorCode ==0} {
                        puts "\nDemarrage de l'EnterpriseApp $eaName reussie\n"
                }
  	} else {
      		puts "\nL'EnterpriseApp $eaName n'existe pas."
	}
}
