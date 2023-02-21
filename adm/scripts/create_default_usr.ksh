#!/usr/bin/ksh

##################################################
#                     A.BOUR                     #
#                    11/06/03                    #
#                      V1.0                      #
# Creation des logins du personnel de la cellule #
#             dev/rec/prex/prod citi.            #
##################################################

LOGIN=0
GROUP=0
HOME=0
UTILISATEUR=0
PASSWD=0
SERVER=0
OS=0

######################################################
# Determination du systeme d'exploitation du serveur #
######################################################

SERVER=$1
OS=`rsh $SERVER uname`

################################################################################################
# Copie des fichiers servant a metre en place le mot de passe par defaut de chaque utilisateur #
################################################################################################

rsh $SERVER mkdir /usr/local /usr/local/adm /usr/local/adm/utils /usr/local/adm/utils/$OS 2>/dev/null
rcp /usr/local/adm/utils/* $SERVER:/usr/local/adm/utils/$OS 2>/dev/null

rsh $SERVER chmod 500 /usr/local/adm/utils/$OS/*

if [[ $OS = "AIX" || $OS = "SunOS" ]]
 then
  print "Les logins vont etre cree sur une machine $OS."
 else
  print "Il y a un probleme avec la machine a laquelle vous voulez acceder"
fi

echo "Les utilisateurs suivant ont ete cree sur $SERVER ($OS):" > root.txt

####################################################################
# Pour les serveur SUN, copie de sauvegarde du fichier /etc/shadow #
####################################################################

if [[ $OS = "SunOS" ]]
 then
  rsh $SERVER cp /etc/shadow /etc/shadow.ori
fi
 
################################
# Debut du programme principal #
################################

for i in `cat default_users.txt`
 do
  UTILISATEUR=`echo $i | awk -F. '{print $1" "$2}'`
  echo >> root.txt
  echo $UTILISATEUR >> root.txt
  LOGIN=`echo $i | awk -F. '{print "f"$2}' | sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/ | cut -c 1,2,3,4,5,6,7,8`
  GROUP=fexploit
  PASSWD=$LOGIN
  HOME=/home/$LOGIN
  a=`echo $i | awk -F. '{print $1}'| cut -c 1 | sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/`
  b=`echo $i | awk -F. '{print $2}'| sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/`
  MAIL=`print "$a$b"`

##############################
# Creation du group fexploit #
##############################

  rsh $SERVER grep fexploit /etc/group > tmp
  T=`wc -l tmp | awk '{print $1}'`
  if [[ $T = 0 ]]
   then
    if [[ $OS = "AIX" ]]
     then
      rsh $SERVER mkgroup -'A' users='root' fexploit
    elif [[ $OS = "SunOS" ]]
     then
      rsh $SERVER groupadd -g 101 fexploit
    fi
  fi
  rm tmp

###########################################################################################
# Constitution du fichier constituant le mail de notification envoye a chaque utilisateur #
###########################################################################################

echo "Votre login a ete cree sur $SERVER. Vos parametres sont les suivants :" > user.txt
echo >> user.txt
echo "utilisateur = $UTILISATEUR" >> user.txt
echo "login = $LOGIN" >> user.txt
echo "passwd par defaut = $LOGIN" >> user.txt
echo "serveur = $SERVER" >> user.txt
echo "groupe = $GROUP" >> user.txt
echo "home = $HOME" >> user.txt
echo "os = $OS" >> user.txt
echo >> user.txt

###########################################################################
# Creation des utilisateurs et mise en place des mots de passe par defaut #
###########################################################################

rsh $SERVER grep -w $LOGIN /etc/passwd | grep -v $LOGIN"A" > tmp
T=`wc -l tmp | awk '{print $1}'`
if [[ $T = 0 ]]
 then
  if [[ $OS = "AIX" ]]
   then
    rsh $SERVER mkuser pgrp=\'$GROUP\' home=\'$HOME\' shell=\'/bin/ksh\' gecos=\'$UTILISATEUR\' $LOGIN
    rsh $SERVER /usr/local/adm/utils/$OS/setpwd -u $LOGIN -p $LOGIN
  elif [[ $OS = "SunOS" ]]
   then
    rsh $SERVER  useradd -m -d $HOME -s /usr/bin/ksh -c \"$UTILISATEUR\" -g $GROUP $LOGIN
    CRYPTPASS=`rsh $SERVER /usr/local/adm/utils/$OS/gencryptpass $LOGIN`
    echo $CRYPTPASS
    L=`rsh $SERVER wc -l /etc/shadow | awk '{print $1}'`
    rsh $SERVER sed $L"s:*LK*:$CRYPTPASS:" /etc/shadow > ./tempshadow
    sed $L"s/*:/:/" ./tempshadow > ./shadow.tmp
    rcp shadow.tmp $SERVER:/etc
    rsh $SERVER mv /etc/shadow.tmp /etc/shadow
    echo "*** PENSEZ A CHANGER VOTRE MOT DE PASSE PAR DEFAUT ***" >> user.txt
  fi
  cat user.txt | mail -s "Creation de votre login sur $SERVER." $MAIL@exchange.cmi.net
 else
  echo >> root.txt
  echo "*** Le login de $UTILISATEUR existe deja sur ce serveur. ***" >> root.txt
 fi
done

##############################
# Fin du programme principal #
##############################

cat root.txt | mail -s "Creation des utilisateurs par defaut sur $SERVER." root
rm -f root.txt user.txt
