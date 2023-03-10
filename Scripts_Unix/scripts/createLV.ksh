#!/usr/bin/ksh

##########################################
#                A.BOUR                  #
#               15/07/02                 #
#                 V3.1                   #
#   Script de cr?ation de raw device     #
##########################################

integer FREE=0
integer PP=0
integer SIZE=0
integer NBRPP=0
integer I=0
integer n=0
integer numraw=1
VOLGROUP=""
RAWNAME=""
CONFIRM="non"
CHANGE=""
VG=0

#############################
# Definitions des fonctions #
#############################

#Generation de la liste de volume groupe disponible et choix
#-----------------------------------------------------------

function genlist {
print "Sur quel Volume Group voulez vous cr?er le raw device?"
print " ---------------------------------------------------- "
for i in `lsvg | grep -v rootvg`
do
vg[$n]=$i
print "${vg[$n]}		-> $n"
n=n+1
done
n=n-1
print ""
read VG

while [[ $VG != [0-$n] ]]
 do
  print "Veuillez choisir le volume group sur lequel vous desirez cr?er le raw device!"
  read VG
 done

VOLGROUP=${vg[$VG]}

clear

}

#Recapitulatif des choix effectues
#---------------------------------

function recap {
while [[ $CONFIRM != "oui" && $CHANGE != "oui" ]]
 do
  CHANGE=""
  print "RECAPITULATIF :"
  print " -------------"
  print ""
  print "Volume Group --------> $VOLGROUP"
  print ""
  integer numraw=1
  print "Liste de(s) raw device(s) a creer :"
  print ""
   until (($numraw > $NBRRAW)) 
    do
     print "N?$numraw : ${RAWNAME[$numraw]} de ${SIZE[$numraw]} PP (${I[$numraw]} Mo)"
     numraw=$numraw+1
    done 
  print ""
  print "Confirmez vous ces donn?es? [oui/non]"
  print ""

  read CONFIRM

if [[ $CONFIRM = "vi" ]]
 then
  clear
  print ""
  print "Bon, arrete tes b?tises ou tu t'prepare des reveils penibles...!!!!"
  print ""
fi

if [[ $CONFIRM = "non" ]]
 then
  print ""
  print "Desirez-vous modifier un parametre? [oui/non]"
  print ""
  read CHANGE
fi

if [[ $CHANGE = "vi" ]]
 then
  clear
  print ""
  print "Bon, arrete tes conneries sinon c'est insomnies, migraines et nervousse braikdaune comme on dit de nos jours!!!"
  print ""
  CHANGE=""
fi

if [[ $CHANGE = "non" ]]
 then
  CHANGE=""
  exit
fi

done
}

######################
# Corps du programme #
######################

clear

genlist

FREE=`lsvg $VOLGROUP | grep FREE | awk '{print $6}'`
PP=`lsvg $VOLGROUP | grep SIZE | awk '{print $6}'`
((RESTE=FREE*PP))
((I=1024/PP))

print "Volume Group de creation	     = $VOLGROUP"
print "Espace Libre sur \"$VOLGROUP\"	= $FREE PP (soit $RESTE Mo avec 1 PP = $PP Mo)."
print ""
while [[ $NBRRAW != [0-99] ]]
 do
  print "Combiens de raw device voulez-vous creer?"
  print "(Tapez 0 pour sortir)"
  print ""
  read NBRRAW
 done

if [[ $NBRRAW = "0" ]]
 then
  print ""
  print "A bientot"
  print ""
  exit
fi

until (($numraw > $NBRRAW))
 do
  print ""
  printf "Nom du raw device N?$numraw : " 
  read RAWNAME
  RAWNAME[$numraw]=$RAWNAME
  printf "Taille (en PP) du raw device N?$numraw? (1Go = 1024Mo = $I PP) : "
  read SIZE
  SIZE[$numraw]=$SIZE
  ((I[$numraw]=PP*SIZE))
  numraw=$numraw+1
  print ""
 done

clear

recap

if [[ $CHANGE = "oui" ]]
 then
while [[ $CHANGE = "oui" && $CONFIRM = "non" ]]
 do
  ((I=PP*SIZE))
  n=0
  clear
  print "Volume Group --------> $VOLGROUP"
  print ""
  integer numraw=1
  print "Liste de(s) raw device(s) a creer :"
  print ""
   until (($numraw > $NBRRAW))
    do
     print "N?$numraw : ${RAWNAME[$numraw]} de ${SIZE[$numraw]} PP (${I[$numraw]} Mo)"
     numraw=$numraw+1
    done
  print ""
  print "Quel parametre desirez-vous changer?"
  print "Volume Group 		->1"
  print "Modifier un raw device	->2"
  print "Tout est bon 		->3"
  print ""
  read PARAM

   while [[ $PARAM != [1-3] ]]
    do
     print "Veuillez choisir un parametre valide!"
     read PARAM
    done
   case $PARAM in
    1)
     print ""
     genlist
     ;;
    2)
     print ""
     print "Quel raw device voulez-vous modifier?"
     integer numraw=1
     print ""
      until (($numraw > $NBRRAW))
       do
        print "${RAWNAME[$numraw]} de ${SIZE[$numraw]} PP (${I[$numraw]} Mo)		-> $numraw"
        numraw=$numraw+1
       done
      print ""
     read numraw
     print "Anciennes donnees:"
     print ""
     print "${RAWNAME[$numraw]} de ${SIZE[$numraw]} (${I[$numraw]} Mo)"
     print ""
     print "Pour annuler la cr?ation d'un raw device, mettre la taille a 999!"
     printf "Nouveau nom (si ok tapez Entr?e) : " 
     read RAWNAME
     if [[ $RAWNAME = "" ]]
      then
       printf "Nouvelle Taille (1 PP = $PP Mo) : "
       read SIZE
       if (($SIZE == 0))
        then
         print "Veuillez entrer une valeur!" 
        elif (($SIZE == 999))
         then
          SIZE[$numraw]=0
          I[$numraw]=0
        else
         SIZE[$numraw]=$SIZE
         ((I=PP*SIZE))
         I[$numraw]=$I
       fi
      else
       RAWNAME[$numraw]=$RAWNAME
       printf "Nouvelle Taille (1 PP = $PP Mo) : "
       read SIZE
       if (($SIZE == 0))
        then
         echo ""
        elif (($SIZE == 999))
         then
          SIZE[$numraw]=0
          I[$numraw]=0
        else
         SIZE[$numraw]=$SIZE
         ((I=PP*SIZE))
         I[$numraw]=$I
       fi
      fi 
     print ""
     ;;
    3)
     CHANGE=non
     ;;
   esac
clear
done
fi

clear

if [[ $CONFIRM = "non" ]]
 then
  recap
fi

integer numraw=1

print "Machine ------> `hostname`" > crrawdev.tmp
print "" >> crrawdev.tmp
print "Liste des raw devices crees :" >> crrawdev.tmp
print "" >> crrawdev.tmp

until (($numraw > $NBRRAW))
 do
  if ((${SIZE[$numraw]} == 0))
   then
    print ""
    print "Cr?ation du raw device \"${RAWNAME[$numraw]}\" annul?e pour cause de taille nulle."
    numraw=$numraw+1
   else
    print "Cr?ation du raw device \"${RAWNAME[$numraw]}\" de ${SIZE[$numraw]} PP (${I[$numraw]} Mo) sur $VOLGROUP."
    mklv -y ${RAWNAME[$numraw]} -t raw $VOLGROUP ${SIZE[$numraw]} 2>/var/log/crrawdev.log
    print "${RAWNAME[$numraw]} de ${SIZE[$numraw]} PP (${I[$numraw]} Mo) sur $VOLGROUP." >> crrawdev.tmp
    numraw=$numraw+1
  fi
 done

print ""
print "Traitement termin?."
print ""

FREE=`lsvg $VOLGROUP | grep FREE | awk '{print $6}'`
PP=`lsvg $VOLGROUP | grep SIZE | awk '{print $6}'`
((RESTE=FREE*PP))

print "" >> crrawdev.tmp
print "Reste $FREE PP sur $VOLGROUP. (soit $RESTE Mo)" >> crrawdev.tmp

cat crrawdev.tmp | mail -s "Cr?ation d'un raw device sur `hostname`." root

rm crrawdev.tmp
