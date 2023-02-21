#!/usr/bin/ksh
#
# CALCUL DU TOTAL PPS ET DU FREE PPS EN UTILISANT LA COMMANDE LSVG
#
DATE=$(date +%d-%m-%y" A "%HH%M)
DATEJ=$(date +_%d-%m-%y_%HH%M)
DATEN=$(date +_%w)
MACHINE=$(hostname)
let SOMME_TOTAL=0;let SOMME_FREE=0;let SOMME_UTILISE=0;
printf "VOLUMETRIE_SUR_$(hostname)_EN_DATE_DU$DATEJ\n"
for VG in `lsvg|egrep -v "alt|128|64"`
do
X=$(lsvg $VG | egrep "TOTAL PPs|FREE PPs|USED PPs|PP SIZE" |cut -f3- -d":" |awk '{ print $1 }')
set $X
TOTAL=$(expr $2 \* $1)
FREE=$(expr $3 \* $1)
UTILISE=$(expr $4 \* $1)
SOMME_TOTAL=$(expr $SOMME_TOTAL \+ $TOTAL)
SOMME_FREE=$(expr $SOMME_FREE \+ $FREE)
SOMME_UTILISE=$(expr $SOMME_UTILISE \+ $UTILISE)
printf "VG(Mo):%-10s TOTAL:%10s FREE:%10s UTILISE:%10s \n" $VG $TOTAL $FREE $UTILISE
done
printf "%-18s SOM_TOTAL:%10s SOM_FREE:%10s SOM_UTILISE:%10s \n" "BILAN(Mo):TOTAL" $SOMME_TOTAL $SOMME_FREE $SOMME_UTILISE
