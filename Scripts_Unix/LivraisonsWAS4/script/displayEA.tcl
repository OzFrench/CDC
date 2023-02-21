#  --------------------------------------------------------------------
#  Le fichier displayEAR.tcl contient les procedures suivantes
#  displayEA         : Affiche les proprietes d'un EntrepriseApp
#  --------------------------------------------------------------------


#
# Affichage des proprietes d'un EntrepriseApp
#
proc displayEA {} {

	global errorCode fullEaName eaName

	set fullEaName "/EnterpriseApp:$eaName/"
	set errorCode 0

        catch {set try [EnterpriseApp show "$fullEaName" -attribute none]}
        if {$errorCode == 2} {
        	puts "\nL'Entreprise Application $eaName n'existe pas.\n"
        } else {
		set attrs [EnterpriseApp show "$fullEaName" -all]
		puts "\n---  Proprietes de l'EnterpriseApp $eaName ---"
		foreach attr $attrs {
                puts "\n>> $attr"
                }
        }
}
