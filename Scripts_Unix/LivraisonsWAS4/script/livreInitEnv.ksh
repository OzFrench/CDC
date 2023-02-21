#!/usr/bin/ksh
#
# Script qui va copier initEnv.properties livre par les etudes dans le repertoire de l'application
#

NODE=fsdevelop2
CODE_APPLI=$1;
WAS_HOME=/fsdevelop2/product/was4
APPLI_HOME=/fsdevelop2/dev/${CODE_APPLI}/integration/was4
VAR_DIR=${APPLI_HOME}/variables_appli
FIC_VAR=${VAR_DIR}/${CODE_APPLI}_dev.ini
typeset -u APPLI_MAJ=$1
CLONE=Clone${APPLI_MAJ}


EA_NAME="$(grep 'eaName' ${FIC_VAR}|sed 's/\"//g'|awk '{print $NF}')"
EAR_DIR="$(echo $EA_NAME|sed 's/$/\.ear/')"
WAR_DIR="$(grep 'warName' ${FIC_VAR}|sed 's/\"//g'|awk '{print $NF}')"
echo "Repertoire de l'application $CODE_APPLI : ${WAS_HOME}/installedApps/$EAR_DIR"
echo "Repertoire de toute la partie Web : $WAR_DIR"

#
# On verifie que le repertoire de l'appli existe
# Si oui, alors on verifie que le fichier initEnv.properties nous a bien ete livre par les etudes dans le repertoire variables_appli
# Si oui, alors on copie le fichier dan sle repertoire de l'appli, on change les droits et le proprietaire
# A la moindre erreur, on affiche un message d'erreur et on quitte le programme
#

if [ ! -d ${WAS_HOME}/installedApps/${EAR_DIR}/${WAR_DIR} ]
then
	echo "Le repertoire ${WAS_HOME}/installedApps/${EAR_DIR}/${WAR_DIR} n'existe pas"
	exit 5 
fi

if [ ! -f ${VAR_DIR}/initEnv.properties ]
then
	echo "Le fichier initEnv.properties sous $VAR_DIR n'existe pas"
	exit 5
fi
cp -f ${VAR_DIR}/initEnv.properties ${WAS_HOME}/installedApps/${EAR_DIR}/${WAR_DIR}
chmod 644 ${WAS_HOME}/installedApps/${EAR_DIR}/${WAR_DIR}/initEnv.properties
chown root:staff ${WAS_HOME}/installedApps/${EAR_DIR}/${WAR_DIR}/initEnv.properties

#
# Dans un souci de bonne mise a jour, on vide le repertoire temporaire utilise par l'appli pour compiler les jsp
# On verifie que le repertoire temporaire existe
# Si ok alors on efface tout ce qu'il contient sinon on retourne un petit msg d'erreur
#

if [ ! -d ${WAS_HOME}/temp/${NODE}/${CLONE}/${CODE_APPLI}/*.war/jsp ]
then
	echo "le répertoire temporaire pour les jsp ${WAS_HOME}/temp/${NODE}/${CLONE}/${CODE_APPLI}/*.war/jsp n'existe pas"
	exit 5
fi

echo "on supprime tous les fichiers se trouvant sous ${WAS_HOME}/temp/${NODE}/${CLONE}/${CODE_APPLI}/*.war/jsp"
rm -rf ${WAS_HOME}/temp/${NODE}/${CLONE}/${CODE_APPLI}/*.war/jsp/*
