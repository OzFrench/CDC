#  --------------------------------------------------------------------
#  Le fichier installEAR.tcl contient les procedures suivantes
#  installEAR         : Creation d'un EntrepriseApp
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
#
# Installation du EAR 
#

proc installEAR {} {

	global modvirthosts eaName errorCode fullEaName nodeName asName earName fullNodeName fullAsName clone NumberOfClones CloneInitial warName1 userid
	
	set fullEaName "/EnterpriseApp:$eaName/"
	set CloneInitial [exec hostname]
	set WasDir "product/was4/installedApps"
	#set EarDir [exec basename $earName]
	set EarDir ${eaName}.ear
	
	# Si Application server n'existe pas alors creation sinon message d'erreur
    	set errorCode 0
	puts "\nDebut de la procedure install"
	catch {set try [EnterpriseApp show "$fullEaName" -attribute none]}

    	if {$errorCode == 2} {
		set errorCode 0
		EnterpriseApp install $fullNodeName $earName -appname $eaName -defappserver $fullAsName -modvirtualhosts $modvirthosts
		if {$errorCode == 0} {
                        puts "\nInstallation de l'EnterpriseApp  $eaName reussie\n"
			
			#Copie des fichiers de l'EAR sur les autres noeuds
			for {set i 1} {$i <= $NumberOfClones} {incr i} {
				puts "\nLe clone $clone(name$i) se toruve sur le noeud $clone(node$i)"
				if {$clone(node$i) != $CloneInitial} {
					puts "\n$clone(node$i) --> Deploiement de l'EAR sur le noeud $clone(node$i)"
					exec rcp -rp /$CloneInitial/$WasDir/$EarDir fexploit@$clone(node$i):/$clone(node$i)/product/websphere/v4/installedApps
					#
					# Ajout Simon pour la copie du fichier initEnv.properties sur les autres clones
					#
					puts "\n$clone(node$i) --> Deploiement du fichier initEnv.properties sur le noeud $clone(node$i)"
					exec rcp -rp /fsdevelop2/dev/${eaName}/integration/was4/variables_appli/initEnv.properties fexploit@$clone(node$i):/$clone(node$i)/product/websphere/v4/installedApps/${EarDir}/${warName1}
					#
					# Ajout Simon pour suppression des fichiers temporaires sur le clone distant
					#
					puts "\n$clone(node$i) --> Suppression des fichiers temporaires jsp sur le clone $clone(node$i)"
					exec rsh $clone(node$i) -l fexploit /$clone(node$i)/product/websphere/v4/livraison/script/removeTmpDir.ksh $clone(name$i) ${eaName} ${warName1}
				} 
			}
                } else {
			puts "\nInstallation pas reussie, errorCode vaut $errorCode\n"
		} 
  	} else {
      		puts "\nL'EnterpriseApp $eaName existe deja. Veuillez reprendre la procedure de livraison.\n"
	        exit
	}
}
