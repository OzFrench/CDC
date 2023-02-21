#!/usr/bin/ksh
#
# Ce script va creer le repertoire temporaire pour l'application ag
# On verifie que le repertoire existe
# Si oui, on ne fait rien sinon on le cree avec les bons droits
#
APPLI=$1
WAS_HOME=/fsdevelop2/product/was4

case ${APPLI} in
ag)
        APPLI_DIR=ag.ear/agWeb.war
        ;;
cw)
        APPLI_DIR=cw.ear/cwWeb.war
        ;;
*)
        echo "probleme du parametre passee a la fonction, vous avez passe ${APPLI}...ERREUR"
        exit 5
        ;;
esac

if [ -d ${WAS_HOME}/installedApps/${APPLI_DIR}/WEB-INF/tmp ]
then
        echo " le repertoire tmp pour l'application ${APPLI} existe"

        if [ -w ${WAS_HOME}/installedApps/${APPLI_DIR}/WEB-INF/tmp ]
        then
                echo "le repertoire tmp pour l'application ${APPLI} a les droits d'ECRITURE, tout est OK"

        else
                echo "le repertoire tmp pour l'application ${APPLI} n'a pas les droits d'ECRITURE, nous allons les fixer"
                chmod 777 ${WAS_HOME}/installedApps/${APPLI_DIR}/WEB-INF/tmp

                if [ $? -eq 0 ]
                then
                        echo "les droits d'ecriture ont ete fixes"

                else
                        echo "les droits d'ecriture N'ONT PAS ETE FIXES, contactez l'administrateur"
                fi
        fi
else
        echo " le repertoire tmp pour l'application ${APPLI} N'EXISTE PAS, nous allons le creer et fixer les droits"
        mkdir ${WAS_HOME}/installedApps/${APPLI_DIR}/WEB-INF/tmp

        if [ $? -ne 0 ]
        then
                echo "le repertoire tmp pour l'application ${APPLI} N'A PAS PU ETRE CREER, contactez l'administrateur"

        else
                echo "le repertoire tmp pour l'application ${APPLI} a ete cree, nous allons fixer les droits"
                chmod 777 ${WAS_HOME}/installedApps/${APPLI_DIR}/WEB-INF/tmp

                if [ $? -eq 0 ]
                then
                        echo "les droits d'ecriture ont ete fixes"

                else
                        echo "les droits d'ecriture N'ONT PAS ETE FIXES, contactez l'administrateur"
                fi
        fi
fi
