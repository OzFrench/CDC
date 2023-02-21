#!/usr/bin/ksh

# Script permettant de recuperer la liste des utilisateurs et des groupes
# Date: 28/02/2002
# Procedure : 
#	- lancer le script liste_user.sh
#	- transferer par ftp le script sur un poste NT
#	- lancer Excel et ouvrir le fichier liste_user_fsdevelop2.txt
# 	- choisir delimite
#	- puis autre ; (point virgule)
#	- sauvegarder le fichier sous Excel au format xls
# 	- copier le fichier liste_user_fsdevelop2.xls sur G:\Parc

ADM=/usr/local/adm

echo "LISTE UTILISATEURS" > $ADM/liste_user_fsdevelop2.txt
echo "ID ; UTILISATEUR ; HOME DIRECTORY" >> $ADM/liste_user_fsdevelop2.txt
/usr/sbin/lsuser -c -a id home ALL | sed '/^#.*/d' | tr ':' '\011'|awk '{print $2 "  ;  " $1 "    ;    " $3}'|sort -n >> $ADM/liste_user_fsdevelop2.txt
echo  >> $ADM/liste_user_fsdevelop2.txt
echo "LISTE GROUPES"  >> $ADM/liste_user_fsdevelop2.txt
echo "ID ; GROUP ; MEMBRES" >> $ADM/liste_user_fsdevelop2.txt
/usr/sbin/lsgroup ALL | awk '{print $2 "  ;  " $1 "   ;   " $4 }'| sed s/id=//|sed s/users=//|sort -n >> $ADM/liste_user_fsdevelop2.txt
