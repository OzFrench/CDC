#  --------------------------------------------------------------------
#  Le fichier createClone.tcl contient les procedures suivantes
#  createClone         : Creation des Clones
#  --------------------------------------------------------------------


#
# Creation des Clones 
#

proc createClone {} {

	global sgName errorCode NumberOfClones clone fullSgName 

	set fullSgName "/ServerGroup:$sgName/"

	for {set i 1} {$i <= $NumberOfClones} {incr i} {
	   set fullNodeName "/Node:$clone(node$i)/"
	   set fullASname "/Node:$clone(node$i)/ApplicationServer:$clone(name$i)/"
    	   set errorCode 0

	   catch {set try [ApplicationServer show "$fullASname" -attribute none]}
    	   if {$errorCode == 2} {
		set errorCode 0
		puts "\nClone $clone(name$i) en cours de creation"
		ServerGroup clone $fullSgName -cloneAttrs $clone(CloneAttributelist$i) -node $fullNodeName
		ApplicationServer modify $fullASname -attribute $clone(CloneAttributelist$i)
		if {$errorCode ==0} {
			puts "\nCreation du clone $clone(name$i) reussie\n"
		} 
  	   } else {
      		puts "\nLe clone $clone(name$i) existe deja. Veuillez changer le nom dans le fichier de variables.\n"
	   }
	}
}
