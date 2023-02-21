#  --------------------------------------------------------------------
#  Le fichier regenPluginWas4.tcl contient les procedures suivantes
#  regenPlugin     : Regeneration de la configution du Plugin Was4
#  --------------------------------------------------------------------

#
# Affiche un message d'erreur
#
proc printError {message} {
  puts "\n>> $message"
}

#
# Regeneration du Plugin
#

proc regenPlugin {} {

	global errorCode clone NumberOfClones

	for {set i 1} {$i <= $NumberOfClones} {incr i} {
           	set fullNodeName "/Node:$clone(node$i)/"
           	set errorCode 0
        	catch {set try [Node show "$fullNodeName" -attribute none]}
        	if {$errorCode != 2} {
			set errorCode 0
			puts "\nPlugin sur le noeud $clone(node$i) en cours de regeneration"
			Node regenPluginCfg "$fullNodeName" 
			if {$errorCode == 0} {
		   		puts "\nLe plugin sur le noeud $clone(node$i) a ete regenere"
			} else {
				puts "\nProbleme lors de regeneration du plugin sur le noeud $clone(node$i)"
			}
		} else {
      			puts "Le noeud $clone(node$i) n'existe pas."
		}
	}
}
