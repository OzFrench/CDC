#!/usr/bin/ksh

###############################################
#                    A.BOUR                   #
#                   28/10/02                  #
#                     V1.0                    #
#   Script de suppression des Shared memory   #
#   Messages et Semaphores donnes par la      # 
#                commande IPCS.               #
###############################################

COUNT=0
type=""
ID=""

ipcs | grep $1 > ipcs.tmp

R=`wc -l ipcs.tmp | awk '{print $1}'`

print "Il y a $R IPC a supprimer" > ipc_result.tmp
print ""

while [ $COUNT -le $R ]
do
i=`head -$COUNT ipcs.tmp | tail -1`
print $i >> ipc_result.tmp
(( COUNT += 1 ))
type=`print $i | awk '{print $1}'`
ID=`print $i | awk '{print $2}'`
ipcrm -$type $ID
print "L'IPC ID=$ID A ete supprime" >> ipc_result.tmp
done

cat ipc_result.tmp | mail -s "Suppression des IPC appartenant au user $1 sur `hostname`." root
rm ipcs.tmp ipc_result.tmp
