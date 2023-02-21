#!/bin/sh
WAS_HOME="/fsdevelop2/product/was4"
SCRIPT_DIR="${WAS_HOME}/livraison/script"

if [ $# -lt 3 ]
then
	echo "Parametres insuffisant"
	echo "GenererVariables.ksh <CODE APPLI> <FICHIER INI APPLI> <FICHIER INI CLONE>...\n"
	exit 2
fi

CODE_APPLI=$1
FIC_APPLI=$2
VAR_DIR="/fsdevelop2/dev/${CODE_APPLI}/variables_appli"

if [ ! -f $FIC_APPLI ]
then
	echo "le fichier INI de l'application $FIC_APPLI n'existe pas\n"
	exit 3
fi

LISTE_CLONE=""
shift 2
for i in $*
do
	if [ ! -f $i ]
	then
        	echo "le fichier INI pour le clone $i n'existe pas\n"
        	exit 4
	fi
	LISTE_CLONE="$LISTE_CLONE --clone $i"
done

if [ ! -f ${SCRIPT_DIR}/transf.pl ]
then
	echo "Le script PERL de transformation de fichier ini n'existe pas"
	exit 5
fi

${SCRIPT_DIR}/transf.pl --dest ${VAR_DIR}/variables_${CODE_APPLI}.tcl --ini ${FIC_APPLI} --generic ${SCRIPT_DIR}/was.tcl --genericlone ${SCRIPT_DIR}/clones.tcl ${LISTE_CLONE}

echo "Le fichier de variables a ete genere"
echo "Celui se trouve sous ${VAR_DIR}, fichier variables_${CODE_APPLI}.tcl"
