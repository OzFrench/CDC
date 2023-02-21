#  --------------------------------------------------------------------
#  Le fichier regenPlugin.tcl contient les procedures suivantes
#  regenPlugin         : Regeneration du Plugin en Was 3.5.x
#  --------------------------------------------------------------------

#
# Affection du parametre argv
#
set servername "$argv"

#
# Affiche un message d'erreur
#
proc printMessage {message} {
  puts "\n>> $message"
}

#
#  Determination du nom d'objet du ServletEngine
#
proc getServletEngine {server} {

  set seList [ServletEngine list]
  set se ""
  foreach object $seList {
    if {[string first $server $object] != -1} {
      set se $object
      break
    }
  }
  return $se
}


#
# Regeneration du Plugin en mode ligne de commandes
#

proc regenPlugin {} {

	global errorCode servername
	set seName ""
	set seName [getServletEngine $servername]
    	set errorCode 0


	catch {set try [ServletEngine show $seName -attribute none]}
    	if {$errorCode != 10} {
		ServletEngine regen $seName
		printMessage "Le plugin a ete regenere"
  	} else {
      		printMessage "Le ServletEngine $servername n'existe pas"
	}
}

