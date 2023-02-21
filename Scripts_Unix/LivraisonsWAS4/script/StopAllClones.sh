#!/bin/ksh

#
# Script qui va arreter tous les clones actifs sur fsdevelop2 puis arreter le noeud
#

# Repertoire WAS4
REP_WAS="/fsdevelop2/product/was4"
# Repertoire des scripts de fonctions
REP_SCRIPT="/fsdevelop2/product/was4/livraison/script"



$REP_WAS/bin/wscp.sh \
-p $REP_WAS/properties/wscp_fsdevelop2.properties \
-c 'exec echo ARRET CLONE R4' \
-c 'ApplicationServer stop /Node:fsdevelop2/ApplicationServer:CloneR4/' \
-c 'exec echo ETAT DU CLONE R4' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneR4/ -attribute CurrentState' \
-c "exec echo \n\nARRET CLONE CW" \
-c 'ApplicationServer stop /Node:fsdevelop2/ApplicationServer:CloneCW/' \
-c 'exec echo ETAT DU CLONE CW' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneCW/ -attribute CurrentState' \
-c "exec echo \n\nARRET CLONE II" \
-c 'ApplicationServer stop /Node:fsdevelop2/ApplicationServer:CloneII/' \
-c 'exec echo ETAT DU CLONE II' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneII/ -attribute CurrentState' \
-c "exec echo \n\nARRET CLONE AG" \
-c 'ApplicationServer stop /Node:fsdevelop2/ApplicationServer:CloneAG/' \
-c 'exec echo ETAT DU CLONE AG' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneAG/ -attribute CurrentState' \
-c "exec echo \n\nARRET CLONE GC" \
-c 'ApplicationServer stop /Node:fsdevelop2/ApplicationServer:CloneGC/' \
-c 'exec echo ETAT DU CLONE GC' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneGC/ -attribute CurrentState' \
-c "exec echo \n\nARRET CLONE CD" \
-c 'ApplicationServer stop /Node:fsdevelop2/ApplicationServer:CloneCD/' \
-c 'exec echo ETAT DU CLONE CD' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneCD/ -attribute CurrentState' \
-c "exec echo \n\nARRET CLONE AO" \
-c 'ApplicationServer stop /Node:fsdevelop2/ApplicationServer:CloneAO/' \
-c 'exec echo ETAT DU CLONE AO' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneAO/ -attribute CurrentState' \
-c "exec echo \n\nARRET DU NOEUD FSDEVELOP2" \
-c 'Node stop /Node:fsdevelop2/' \
-c 'exec echo ETAT DU NOEUD FSDEVELOP2' \
-c 'Node show /Node:fsdevelop2/ -attribute CurrentState' \
-c "exec echo \n\n---FIN---"

echo "---FSDEVELOP2---Clones Websphere 4 arretes, Noeud Websphere 4 arrete, proceder a une verification"|mail -s '---FSDEVELOP2---Script arret clones-noeud WAS4 execute' root
