#  --------------------------------------------------------------------
#  Le fichier displayAS.tcl contient les procedures suivantes
#  displayAS    : Affiche les proprietes d'un ApplicationServer
#  --------------------------------------------------------------------

#
# Affectation des Variables Globales
#
#
# Affichage des proprietes d'un ApplicationServer
#
proc display JVM{} {

	global asName fullAsName errorCode nodeName
	set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"
	set errorCode 0
        catch {set try [ApplicationServer show "$fullAsName" -attribute none]}
  
        if {$errorCode == 2} {
        	puts "\nL'ApplicationServer $asName n'existe pas.\n"
        } else {
                set errorCode 0
		catch {set try [PmiService listMembers "$fullAsName" ]}
		if {$errorCode == 24} {
			puts"\nLe serveur d'application $asName n'est pas lance, veuillez le demarrer"
		} else {
			PmiService enableData "$fullAsName" -dd jvmRuntimeModule
			Pmi get "$fullAsName" -dd jvmRuntimeModule
		}
	}
}

