#!/bin/ksh


# Exemple de script de livraison WAS4 sans transfert du EAR et du contenu statique (HTMl, images etc)

# Repertoire WAS4
REP_WAS="/fsdevelop2/product/was4"
# Repertoire des scripts de fonctions
REP_SCRIPT="/fsdevelop2/product/was4/livraison/script"
# Repertoire du fichier de variables
FIC_VAR="variables_${1}.tcl"
REP_VAR="/fsdevelop2/dev/${1}/variables_appli/${FIC_VAR}"


livreInitiale () {

check_var

$REP_WAS/bin/wscp.sh \
-p $REP_WAS/properties/wscp_fsdevelop2.properties \
-f $REP_VAR \
-f $REP_SCRIPT/createVH.tcl \
-f $REP_SCRIPT/createJDBC.tcl \
-f $REP_SCRIPT/createDS.tcl \
-f $REP_SCRIPT/createSG.tcl \
-f $REP_SCRIPT/createClone.tcl \
-f $REP_SCRIPT/installEAR.tcl \
-f $REP_SCRIPT/regenPlugin.tcl \
-f $REP_SCRIPT/startEA.tcl \
-f $REP_SCRIPT/startSG.tcl \
-c createVH -c createJDBC -c createDS -c createSG -c createClone -c installEAR -c regenPlugin -c startEA -c startSG
}

monteeVersion () {

check_var

$REP_WAS/bin/wscp.sh \
-p $REP_WAS/properties/wscp_fsdevelop2.properties \
-f $REP_VAR \
-f $REP_SCRIPT/installEAR.tcl \
-f $REP_SCRIPT/regenPlugin.tcl \
-f $REP_SCRIPT/removeEA.tcl \
-f $REP_SCRIPT/startEA.tcl \
-f $REP_SCRIPT/stopEA.tcl \
-f $REP_SCRIPT/displayEA.tcl \
-f $REP_SCRIPT/stopSG.tcl \
-f $REP_SCRIPT/startSG.tcl \
-c stopEA -c removeEA -c installEAR -c startEA -c regenPlugin 
}


usage () {

   echo "\nUsage: livraison.ksh <code appli> Initialisation  --> Livraison Initiale d'une Application WAS4"
   echo "       livraison.ksh <code appli> Upgrade  --> Montee de version d'une Application WAS4\n"
}

check_var () {
   
   if [ ! -f $REP_VAR ]
    then 
	echo "\nLe fichier de variables $FIC_VAR n'existe pas.\n"
	exit 69
   fi   
}


# Main

if [ $# = 2 ]
   then
      case $2 in
          Initialisation)
              livreInitiale
          ;;
          Upgrade)
              monteeVersion
          ;;
          *)
           usage
          ;;
      esac
   else
      echo "\nNombre de parametres incorrect:"
      usage
fi
