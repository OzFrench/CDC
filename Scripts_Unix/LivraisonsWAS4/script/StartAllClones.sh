#!/bin/ksh

#
# Script qui lance le noeud Websphere puis tous les clones de la machine
#

# Repertoire WAS4
REP_WAS="/fsdevelop2/product/was4"
# Repertoire des scripts de fonctions
REP_SCRIPT="/fsdevelop2/product/was4/livraison/script"

echo "Demarrage de Websphere4"
${REP_WAS}/bin/startupServer.sh

echo "une petite paude de 10s avant de lancer tous les clones"
sleep 10

$REP_WAS/bin/wscp.sh \
-p $REP_WAS/properties/wscp_fsdevelop2.properties \
-c 'exec echo DEMARRAGE CLONE R4' \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneR4/' \
-c 'exec echo ETAT DU CLONE R4' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneR4/ -attribute CurrentState' \
-c "exec echo \n\nDEMARRAGE CLONE CW" \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneCW/' \
-c 'exec echo ETAT DU CLONE CW' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneCW/ -attribute CurrentState' \
-c "exec echo \n\nDEMARRAGE CLONE II" \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneII/' \
-c 'exec echo ETAT DU CLONE II' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneII/ -attribute CurrentState' \
-c "exec echo \n\nDEMARRAGE CLONE AG" \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneAG/' \
-c 'exec echo ETAT DU CLONE AG' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneAG/ -attribute CurrentState' \
-c "exec echo \n\nDEMARRAGE CLONE GC" \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneGC/' \
-c 'exec echo ETAT DU CLONE GC' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneGC/ -attribute CurrentState' \
-c "exec echo \n\nDEMARRAGE CLONE XX" \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneXX/' \
-c 'exec echo ETAT DU CLONE XX' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneXX/ -attribute CurrentState' \
-c "exec echo \n\nDEMARRAGE CLONE CD" \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneCD/' \
-c 'exec echo ETAT DU CLONE CD' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneCD/ -attribute CurrentState' \
-c "exec echo \n\nDEMARRAGE CLONE AO" \
-c 'ApplicationServer start /Node:fsdevelop2/ApplicationServer:CloneAO/' \
-c 'exec echo ETAT DU CLONE AO' \
-c 'ApplicationServer show /Node:fsdevelop2/ApplicationServer:CloneAO/ -attribute CurrentState'
-c "exec echo \n\n---FIN---"

echo "---FSDEVELOP2---Clones Websphere 4 demarres, Noeud Websphere 4 demarre, proceder a une verification"|mail -s '---FSDEVELOP2--- Script de relance Noeud-Clone Websphere 4 execute' root
