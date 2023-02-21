#############################################
#
# Script qui vide le fichier /var/adm/wtmp
# des entrees 'xvfb' lorsque celui-ci atteint 
# une taills superieure a 5 Mo
#
# Le 15 spt 2003
#
#############################################

WTMP=/var/adm/wtmp
TMP1=/tmp/toto.txt
TMP2=/tmp/toto2.txt

WTMPSIZE=$(ls -l  $WTMP|tr -s ' '|cut -f 5 -d ' ')

if [ $? -ne 0 ]
then
	echo "Probleme lors de la recuperation de la taille du fichier $WTMP"
	exit 5
fi

if [ $WTMPSIZE -gt 5000000 ]
then
	echo "Taille du fichier $WTMP superieure a 5 Mo, on nettoie"
	fwtmp < $WTMP > $TMP1

	if [ $? -ne 0 ]
	then
		echo "Probleme lors de la lecture du fichier $WTMP. STOP!!!!" 
		exit 5
	fi

	grep -v xvfb $TMP1 > $TMP2

	if [ $? -ne 0 ]
	then
		echo "Probleme lors du filtrage du fichier TMP $TMP1" 
		exit5
	fi

	fwtmp -ic < $TMP2 > $WTMP

	if [ $? -ne 0 ]
        then
		echo "Probleme de remplacement du fichier $WTMP a parir du fichier $TMP2" 
		exit 5
	fi
else
	echo "Taille du fichier $WTMP inferieure a 5 Mo, tout est OK" 
fi
