#  --------------------------------------------------------------------
#  Le fichier modifyClone.tcl contient les procedures suivantes
#  modifyClone         : Modification des Clones
#  --------------------------------------------------------------------


#
# Modification des Clones 
#
proc modifyClone {} {

	global sgName errorCode NumberOfClones clone fullSgName fullClName

	set fullSgName "/ServerGroup:$sgName/"

	for {set i 1} {$i <= $NumberOfClones} {incr i} {
	   set fullNodeName "/Node:$clone(node$i)/"
	   set fullClName "/Node:$clone(node$i)/ApplicationServer:$clone(name$i)/"
    	   set errorCode 0

	   catch {set try [ApplicationServer show "$fullClName" -attribute none]}
    	   if {$errorCode != 2} {
		puts "\nClone $clone(name$i) en cours d'arret"
		ApplicationServer stop "$fullClName"
		puts "\nClone $clone(name$i) arrete"
		puts "\nClone $clone(name$i) en cours de modification"
		set errorCode 0
		ApplicationServer modify "$fullClName" -attribute $clone(CloneAttributelist$i) 
		if {$errorCode == 0} {
			set errorCode 0
			puts "\nModification du clone $clone(name$i) reussie"
		} else {
			puts "\nProbleme lors de la modification du clone $clone(name$i)"
		}
	   puts "\nClone $clone(name$i) en cours de relance"
	   set errorCode 0
	   ApplicationServer start "$fullClName"
	   if {$errorCode == 0} {
	   	puts "\nClone $clone(name$i) relance"
	   } else {
		puts "\nProble de relance du clone $clone(name$i)"
	   }
  	   } else {
      		puts "\nLe clone $clone(name$i) n'existe pas. Veuillez changer le nom dans le fichier de variables.\n"
	   }
	}
}
