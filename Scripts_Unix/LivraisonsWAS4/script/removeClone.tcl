#  --------------------------------------------------------------------
#  Le fichier removeClone.tcl contient les procedures suivantes
#  removeClone         : Suppression des Clones
#  --------------------------------------------------------------------


#
# Modification des Clones 
#
proc removeClone {} {

	global sgName errorCode NumberOfClones clone fullClName

	for {set i 1} {$i <= $NumberOfClones} {incr i} {
	   set fullClName "/Node:$clone(node$i)/ApplicationServer:$clone(name$i)/"
	   puts "\nNous allons supprimer $fullClName"
    	   set errorCode 0

	   catch {set try [ApplicationServer show "$fullClName" -attribute none]}
    	   if {$errorCode != 2} {
		puts "\nClone $clone(name$i) en cours d'arret"
		#ApplicationServer stop "$fullClName"
		puts "\nClone $clone(name$i) arrete"
		puts "\nClone $clone(name$i) en cours de suppression"
		set errorCode 0
		ApplicationServer remove "$fullClName" 
		if {$errorCode == 0} {
			puts "\nSuppression du clone $clone(name$i) reussie"
		} else {
			puts "\nProbleme lors de la suppression du clone $clone(name$i)"
		}
  	   } else {
      		puts "\nLe clone $clone(name$i) n'existe pas. Veuillez changer le nom dans le fichier de variables.\n"
	   }
	}
}
