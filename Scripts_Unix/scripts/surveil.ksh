#!/usr/bin/ksh

##########################################
#                A.BOUR                  #
#               10/04/02                 #
#                 V2.0                   #
#    Surveillance du paging space d'un   #
#      serveur ainsi que des applis      #
#            de ce dernier.              #
##########################################

ADM=/usr/local/adm/scripts

integer PS=0
integer SW=0
integer j=0

PROCESS=$ADM/processus.txt
SWAP=$ADM/swap.tmp
PROC=$ADM/proc.tmp

###################################
###### Execution du programe ######
###################################

touch $PROC
touch $SWAP
for i in `cat $PROCESS`
do
  j=`ps -ef | grep $i | grep -v grep | wc -l`
  if ((j==0))
  then
   print "Le processus $i ne tourne pas." >> proc.tmp
  fi
done

print "`lsps -s | awk '{print $2}' | sed /Pag/d | awk -F% '{print $1}'`" > swap.tmp

##########################################
######## Definition des fonctions ########
##########################################

#-------------------------------------------
### Fonction d'envoi de mail automatique ### 
#-------------------------------------------

function envoi
{
 PS=`wc -l $PROC | awk '{print $1}'`
  if ((PS!=0))
   then
    cat $PROC | mail -s "Attention, il manques des processus sur `hostname`." root
  fi
 SW=`cat $SWAP`
  if ((SW>=50))
   then
    mail -s "Attention, le paging space sur `hostname` est trop eleve: $SW%" root
  fi
 rm $PROC
 rm $SWAP
}

#-------------------------------------
### Fonction d'affichage a l'ecran ###
#-------------------------------------

function screen
{
 print ""
 PS=`wc -l $PROC | awk '{print $1}'`
  if ((PS!=0))
   then
    print "`cat $PROC`\n"
   else
    print "Tous les processus tournent.\n"
  fi 
 SW=`cat $SWAP`
  if ((SW>=50))
   then
    print "Attention, $SW% du paging space de `hostname` est utilise."
   else
    print "Le paging space de `hostname` est utilise a $SW%.\n"
  fi
 rm $PROC
 rm $SWAP
}

#####################################################
###### Prise en compte des options d'execution ######
#####################################################

s=1
integer OPT=${1}

if ((OPT==1))
 then
  screen
 else
  envoi
fi
