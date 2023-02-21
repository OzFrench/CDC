#  --------------------------------------------------------------------
#  Le fichier modifyClone.tcl contient les procedures suivantes
#  modifyClone         : Modification des Clones
#  --------------------------------------------------------------------


#
# Modification des Clones 
#
proc stopClone {} {

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
  	   } else {
      		puts "\nLe clone $clone(name$i) n'existe pas. Veuillez changer le nom dans le fichier de variables.\n"
	   }
	}
}
