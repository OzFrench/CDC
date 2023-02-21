#  --------------------------------------------------------------------
#  Le fichier removeSG.tcl contient les procedures suivantes
#  removeSG         : remove d'un ServerGroup
#  --------------------------------------------------------------------


#
# Modification de ServerGroup
#
proc removeSG {} {

	global sgName errorCode fullSgName  

	set fullSgName "/ServerGroup:$sgName/"
    	set errorCode 0

	catch {set try [ServerGroup show "$fullSgName" -attribute none] }

    	if {$errorCode != 2} {
		set errorCode 0
		puts "\nServerGroup $sgName en cours d'arret"
		ServerGroup stop "$fullSgName"
		puts "\nServerGroup $sgName arrete"
		puts "\nServerGroup $sgName en cours de suppression"
		set errorCode 0
		ServerGroup remove "$fullSgName" 
		if {$errorCode == 0} {
			puts "\nSuppression du ServerGroup $sgName reussie"
		} else {
			puts "\nProbleme lors de la suppression du ServerGroup $sgName"
		}
  	} else {
      		puts "\nLe ServerGroup $sgName n'existe pas. Veuillez changer le nom dans le fichier de variables.\n"
	}
}
