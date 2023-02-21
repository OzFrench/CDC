#!/usr/bin/ksh

##########################################
#                A.BOUR                  #
#               08/04/02                 #
#                 V1.2                   #
# Verification de la presence de fichier #
#          CORE sur un serveur           #
##########################################

APPLI=neant
NAPPLI=0
REP=neant
CORESPAPPLIS=neant
SCRREP=/usr/local/adm/scripts

find / -name core -print > core_result
k=`wc -l core_result | awk '{print $1}'`
SERVEUR=`hostname`

if ((k!=0))
  then
    print "Attention, presence de fichiers core sur le serveur $SERVEUR :" > result
    print "" >> result
    for i in `cat core_result`
      do
        print "$i" > core_tmp
	j=`ls -l $i | awk '{print $7}'`
	m=`ls -l $i | awk '{print $6}'`
	m=`grep -w $m $SCRREP/mois.txt | awk '{print $2}'`
	h=`ls -l $i | awk '{print $8}'`
        APPLI=`cat core_tmp | awk -F/ '{print $4}'`
        integer r=`cat core_tmp | wc -c`-5
        REP=`cut -c -$r core_tmp`
        SIZE=`ls -l $i | awk '{print $5}'`
        print "Repertoire : $REP" >> result
	print "Date du fichier Core : $j $m a $h" >> result
        print "Taille du fichier Core : $SIZE octets" >> result
        NAPPLI=`cat core_tmp | awk -F/ '{print $4}' | wc -c`
          if ((NAPPLI==3))
            then
              CORESPAPPLIS=`grep -w $APPLI $SCRREP/applist.txt | awk '{print $2}'`
              print "Application : $CORESPAPPLIS" >> result
              print "Code Appli  : $APPLI" >> result
            else
              CORESPAPPLIS=$APPLI
              print "Application : $CORESPAPPLIS" >> result
          fi
        print "" >> result
      done
  cat result | mail -s "Presence de fichiers core sur $SERVEUR" root
rm core_tmp
rm result
fi
rm core_result
