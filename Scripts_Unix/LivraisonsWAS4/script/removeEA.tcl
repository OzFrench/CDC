#  --------------------------------------------------------------------
#  Le fichier removeEA.tcl contient les procedures suivantes
#  removeEA          : Demarrage d'un EntrepriseApp
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
#
# Demarrage de l'Entreprise Application
#

proc removeEA {} {

	global eaName errorCode fullEaName NumberOfClones clone CloneInitial userid warName1
	set fullEaName "/EnterpriseApp:$eaName/"
	set CloneInitial [exec hostname]
	set EarDir ${eaName}.ear

	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	catch {set try [EnterpriseApp show "$fullEaName" -attribute none]}
    	if {$errorCode != 2} {
		set errorCode 0
		puts "\nApplication d'entreprise $eaName en cours d'arret"
		EnterpriseApp stop "$fullEaName"
		puts "\nApplication d'entreprise $eaName arrete"
		puts "\nApplication d'entreprise $eaName en cours de suppression"
		set erroCode 0
		EnterpriseApp remove "$fullEaName"
		if {$errorCode == 0} {
			puts "\nSuppression de l' Application d'entreprise $eaName reussie"
			
			#Suppression des fichiers de l'EAR sur les autres noeuds
                        for {set i 1} {$i <= $NumberOfClones} {incr i} {
                                puts "\nLe clone $clone(name$i) se trouve sur le noeud $clone(node$i)"
                                if {$clone(node$i) != $CloneInitial} {
                                        puts "\n$clone(node$i) --> Suppression de l'EAR sur le noeud $clone(node$i)"
                                        #exec rcp -rp /$CloneInitial/$WasDir/$EarDir fexploit@$clone(node$i):/$clone(node$i)/product/websphere/v4/installedApps
					exec rsh $clone(node$i) -l fexploit rm -rf /$clone(node$i)/product/websphere/v4/installedApps/$EarDir
					puts "\n$clone(node$i) --> Suppression des fichiers temporaires jsp sur le noeud $clone(node$i), valeur de userid: $userid"
					puts "$clone(node$i) --> Vidage du repertoire /$clone(node$i)/product/websphere/v4/temp/$clone(node$i)/$clone(name$i)/$eaName/$warName1/jsp/*"
					exec rsh $clone(node$i) rm -rf /$clone(node$i)/product/websphere/v4/temp/$clone(node$i)/$clone(name$i)/$eaName/$warName1/jsp/*
				}
			}

		} else {
			puts "\nProbleme lors de la suppression de l'Application d'entreprise $eaName"
		}
  	 } else {
      	      puts "\nL'EnterpriseApp $eaName n'existe pas.\n"
         }
}
