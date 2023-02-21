#!/bin/ksh

#set -x

# Exemple de script de creation d'objet WAS 4.x

# Repertoire WAS4
REP_WAS="/fsdevelop2/product/was4"

# Repertoire des scripts de fonctions
#REP_SCRIPT="/fsdevelop2/product/was4/livraison/script"
REP_SCRIPT="/fsdevelop2/dev/was4test/integration"

# Repertoire du fichier de variables
FIC_VAR="variables_${1}.tcl"
#REP_VAR="/fsdevelop2/product/was4/livraison/script/${FIC_VAR}"
REP_VAR="/fsdevelop2/dev/was4test/integration/${FIC_VAR}"

# Liste de Commandes definies
listeCommandes="createClone createDS createJDBC createSG createVH displayClone displayDS displayEA displayJVM displaySG displayVH displayWC installEAR modifyClone modifyDS modifyJDBC modifySG modifyVH regenPlugin removeClone removeDS removeEA removeJDBC removeSG removeVH startClone startEA startSG stopClone stopEA stopSG"

echo "le fichier de vars est ${REP_VAR}\n"

# Procedure d'appel des commandes TCL-WSCP
manipObject () {
echo "On est dans la procedure qui charge ts les scripts TCL\n"
check_var

$REP_WAS/bin/wscp.sh \
-p $REP_WAS/properties/wscp_fsdevelop2.properties \
-f $REP_VAR \
$scriptTCL \
$liste

}


usage () {

   echo "\nUsage: wasObject.ksh <code appli> createAS      --> Creation d'un ApplicationServer"
   echo "                                  createVH      --> Creation d'un VirtualHost"
   echo "                                  createSG      --> Creation d'un ServerGroup"
   echo "                                  createClone   --> Creation d'un ou des clones"
   echo "                                  createJDBC    --> Creation et Installation d'un Driver JDBC"
   echo "                                  createDS      --> Creation d'un ou des Datasources"
   echo "                                  installEAR      --> Creation d'un ou des EnterpriseApplications"
   echo "\n                                  displayAS     --> Affiche certaines proprietes d'un ApplicationServer"
   echo "                                  displayVH     --> Affiche les proprietes d'un VirtualHost"
   echo "                                  displaySG     --> Affiche les proprietes d'un ServerGroup"
   echo "                                  displayClone  --> Affiche certaines proprietes d'un ou des clones"
   echo "                                  displayDS     --> Affiche les proprietes d'un ou des Datasources"
   echo "                                  displayEA     --> Affiche les proprietes d'une EnterpriseApp"
}

check_var () {
   
   if [ ! -f $REP_VAR ]
    then 
	echo "\nLe fichier de variables $FIC_VAR n'existe pas.\n"
	usage
	exit 69
   fi   
}


# Main

if [ $# -gt 1 ]
   then
	ret=$1
	for arg in $@
	do
	   if [ $arg != "$ret" ]
	      then 
		tmpliste="$tmpliste $arg"
	   fi
	done

	for arg in $tmpliste
	do
	   if [ ! "`echo $listeCommandes | grep -w $arg`" ]
		then
		   echo "\nLa commande $arg n'appartient pas a la liste de commandes definies.\n"
		   usage
		   exit 69
		else
		fichier="$REP_SCRIPT/$arg.tcl"
		scriptTCL="$scriptTCL -f $fichier"
		liste="$liste -c $arg"
	   fi
	done
   export scriptTCL
   export liste
   echo $scriptTCL
   echo $liste
   manipObject
else
  echo "\nNombre de parametres incorrect:"
  usage
fi
