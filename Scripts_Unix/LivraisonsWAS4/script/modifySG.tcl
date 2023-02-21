#  --------------------------------------------------------------------
#  Le fichier modifySG.tcl contient les procedures suivantes
#  modifySG         : Modification d'un ServerGroup
#  --------------------------------------------------------------------


#
# Modification de ServerGroup
#
proc modifySG {} {

	global SGattributelist sgName errorCode fullSgName 

	set fullSgName "/ServerGroup:$sgName/"
    	set errorCode 0

	catch {set try [ServerGroup show "$fullSgName" -attribute none] }

    	if {$errorCode != 2} {
		puts "\nServerGroup $sgName en cours d'arret"
		ServerGroup stop "$fullSgName"
		puts "\nServerGroup $sgName arrete"
		puts "\nServerGroup $sgName en cours de modification"
		set errorCode 0
		ServerGroup modify "$fullSgName" -attribute $SGattributelist
		if {$errorCode == 0} {
			puts "\nServerGroup $sgName modifie"
		} else {
			puts "\nProbleme lors de la modification du ServerGroup $sgName"
		}
		puts "\nServerGroup $sgName en cours de relance"
		ServerGroup start "$fullSgName"
		puts "\nServerGroup $sgName relance"
  	} else {
      		puts "\nLe ServerGroup $sgName n'existe pas. Veuillez changer le nom dans le fichier de variables.\n"
	}
}
