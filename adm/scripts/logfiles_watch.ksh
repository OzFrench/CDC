#!/usr/bin/ksh

##########################################
#                A.BOUR                  #
#               22/05/02                 #
#                 V1.0                   #
#  Limitation de la taille des fichiers  #
#         de logs d'un serveur           #
##########################################

ADMDIR=/usr/local/adm/scripts
P=neant
NP=neant

# Ici on peut parametrer le nombre de lignes a garder
integer SIZE=100


integer NBRL=0
integer E=0

# Main

DATE=`date +"%d%B%Y"`

for P in `/usr/bin/cat $ADMDIR/logfiles.txt | /usr/bin/grep -v "^#"| grep -v no | /bin/cut -d":" -f 1`
 do
  NBRL=`/usr/bin/cat $P | /usr/bin/wc -l`
    if ((NBRL>$SIZE))
      then
        NP=$P.tmp
        cp $P $NP
        >$P
        OLDLOG=$P.$DATE
        E=$NBRL-$SIZE
        head -$E $NP > $OLDLOG 
	/usr/bin/gzip -f $OLDLOG
        tail -$SIZE $NP > $P
        rm $NP
    fi
 done
