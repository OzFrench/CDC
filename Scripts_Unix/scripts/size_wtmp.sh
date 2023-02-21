#!/usr/bin/ksh
#
# Script qui verifie la taille du fichier wtmp
# Si taille inferieure a 10 Mo, ok
# Sinon, on ne garde que les 100 dernieres lignes
#
# le 27 juin 2003

DATE=`date`
FWTMP=/usr/sbin/acct/fwtmp
WTMP_FILE=/var/adm/wtmp
OLD_WMTP=/tmp/wtmp.old
NEW_WTMP=/tmp/wtmp.new
LOG_FILE=/tmp/wtmp_update.log



#On verifie que le fichier de log existe
if [ -f ${LOG_FILE} ]
then
	echo "${DATE}">> ${LOG_FILE}
	echo "Le fichier de log ${LOG_FILE} existe">> ${LOG_FILE}
else
	touch ${LOG_FILE}
	echo "${DATE}">> ${LOG_FILE}
	echo "Creation du fichier de log ${LOG_FILE}">> ${LOG_FILE}
fi

touch ${OLD_WMTP}
touch ${NEW_WTMP}

#On recupere la taille du fichier wtmp
if [ $(ls -ali ${WTMP_FILE}|tr -s ' '|cut -f 7 -d ' ') -lt 10000000 ]
then
	
	echo "Taille du fichier ${WTMP_FILE}: $(ls -ali ${WTMP_FILE}|tr -s ' '|cut -f 7 -d ' ')">> ${LOG_FILE}
	echo "tout est ok">> ${LOG_FILE}
else
	echo "Taille du fichier ${WTMP_FILE}: $(ls -ali ${WTMP_FILE}|tr -s ' '|cut -f 7 -d ' ')">> ${LOG_FILE}
	echo "il faut reduire la taille du fichier">> ${LOG_FILE}
	${FWTMP} < ${WTMP_FILE} > ${OLD_WMTP}
	grep -v xvfb ${OLD_WMTP} > ${NEW_WTMP}
	${FWTMP} -ic < ${NEW_WTMP} > ${WTMP_FILE}
	echo "Nouvelle taile du fichier ${WTMP_FILE}: $(ls -ali ${WTMP_FILE}|tr -s ' '|cut -f 7 -d ' ')">> ${LOG_FILE}
fi

echo "----------FIN----------" >> ${LOG_FILE}
rm ${OLD_WMTP}
rm ${NEW_WTMP}
