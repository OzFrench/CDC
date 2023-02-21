#  --------------------------------------------------------------------
#  Le fichier displayClone.tcl contient les procedures suivantes
#  displayClone    : Affiche les proprietes des Clones
#  --------------------------------------------------------------------


#
# Affichage des proprietes des Clones
#
proc displayClone {} {

	global fullSgName sgName errorCode  

	set fullSgName "/ServerGroup:$sgName/"
	set errorCode 0
   

        catch {set try [ServerGroup show "$fullSgName" -attribute none]}

        if {$errorCode == 2} {
        	puts "\nLe ServerGroup $sgName n'existe pas.\n"
        } else {

   	     set clones [ServerGroup listClones "$fullSgName"]
	     set longueur [string length $clones]

             if {[string length $clones] == 0} {
	        puts "\nIl n'y a aucun Clone associe au ServerGroup $sgName.\n"
	        } else {
 	            puts "\n\n Affichage des certaines proprietes de Clones\n"
	            foreach clone $clones {
		       set attrs [ApplicationServer show "$clone"  -attribute "Name CurrentState DesiredState WorkingDirectory Stdout Stderr JVMConfig"]
		    foreach attr $attrs {
                       puts "\n>> $attr"
                       }
		       puts "\n"
	            }
	      }
        }
}
