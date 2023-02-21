#!/usr/bin/ksh
##########################################
#                A.BOUR                  #
#               03/04/02                 #
#                 V1.1                   #
#   Controle du remplissage des files    #
#          system d'un serveur           #
##########################################


####### Seuil d'alerte en pourcent #######
LVL=80
##########################################

integer k=0
integer f=0
i=0
DFFOLD=/

df -k /fsdevelop2/product/mqm | awk '{print $4$7}' > df_chk_result

print -r "Seuil d'alerte = $LVL%" >> rebloup
print -r "" >> rebloup

for i in `cat df_chk_result`
	do
		print "$i" >bloup
		f=`cat bloup | awk -F% '{print $1}'`
		DFFOLD=`cat bloup | awk -F% '{print $2}'`
		if ((f>$LVL)) then
			k=k+1
			print "Attention, le file system $DFFOLD est plein a $f%." >> rebloup
		fi
done

if ((k!=0)) then
 cat rebloup | mail -s "Surveillance des file systems" eric.petitjean@exchdabf.dabfi.cdc.fr,mohamed.sayad@exchdabf.dabfi.cdc.fr,arnaud.bour@exchdabf.dabfi.cdc.fr
fi

rm rebloup
rm df_chk_result
rm bloup
