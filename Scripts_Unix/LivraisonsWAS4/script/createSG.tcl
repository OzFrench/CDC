#  --------------------------------------------------------------------
#  Le fichier createSG.tcl contient les procedures suivantes
#  createSG         : Creation d'un ServerGroup
#  --------------------------------------------------------------------


#
# Creation de ServerGroup
#
proc createSG {} {

	global SGattributelist sgName errorCode fullSgName 

	set fullSgName "/ServerGroup:$sgName/"
    	set errorCode 0

	catch {set try [ServerGroup show "$fullSgName" -attribute none]}

    	if {$errorCode == 2} {
		set errorCode 0
		puts "\nServerGroup $sgName en cours de creation"
		ServerGroup create "$fullSgName" 
		ServerGroup modify "$fullSgName" -attribute $SGattributelist
		if {$errorCode ==0} {
			puts "Creation du ServerGroup reussie"
		}
  	} else {
      		puts "\nLe ServerGroup $sgName existe deja. Veuillez changer le nom dans le fichier de variables.\n"
	}
}
