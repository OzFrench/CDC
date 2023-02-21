REP=/exploit/simm/data
DATEJ=$(date +_%d-%m-%y_%HH%M)
DATE=$(date +%d-%m-%y" à "%HH%M)
DATEN=$(date +_%w)
HOST=`hostname`
rm $REP/Preleve.data_$HOST$DATEN
echo "################  PHOTO KODAK $HOST EN DATE DU : $DATE   ########" >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "#################  NOMBRE DE  CPU (cpu) ################"   >> $REP/Preleve.data_$HOST$DATEN
lsattr -El aio0|grep maxservers|awk '{ print $1" :" "\t" $2 }' >> $REP/Preleve.data_$HOST$DATEN
lsdev -Cc processor|grep  Available|wc -l |awk '{ print "Nombre Processor :" "\t" $1 }' >> $REP/Preleve.data_$HOST$DATEN
echo "INFO(maxservers=maxservers X Nombre Processor)" >> $REP/Preleve.data_$HOST$DATEN
pstat  -a|grep aioserver|wc -l |awk  '{ print "Nombre aioserver :" "\t" $1 }' >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "##### TAUX UTILISATION DES CPU(s) ( %usr, %sys, %wio, %idle )  #####"   >> $REP/Preleve.data_$HOST$DATEN
sar  -s 07:55 -e 18:00 -P ALL|grep cpu|head  -6|tail -1  >> $REP/Preleve.data_$HOST$DATEN
integer  NPro=$(lsdev -Cc processor|grep -i Avail|wc -l)*2+3 >> $REP/Preleve.data_$HOST$DATEN
sar -s 07:55 -e 18:00  -P ALL|tail -$NPro  >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "##### NOMBRE TOTAL DE BLOCK DE MEMOIRE DE 4K ET UTILISEE (size, inuse %Utilisee #####"  >> $REP/Preleve.data_$HOST$DATEN
svmon -G|head -1|awk '{ print $1 "\t" $2 "\t" "%MEMOIRE" }' >> $REP/Preleve.data_$HOST$DATEN
svmon -G|head -3|grep mem|awk '{ print   $2 "\t" $3 "\t" $3/$2*100 }' >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "########## % UTILISATION DE LA PARTIE SWAP (%swap) #############"  >> $REP/Preleve.data_$HOST$DATEN
lsps -s >> $REP/Preleve.data_$HOST$DATEN
echo "##### NOMBRE DE PAGIMMATION EN ENTREE / SORTIE DE 4K (Pagein / Pageout ) ######"  >> $REP/Preleve.data_$HOST$DATEN
vmstat 2 5  >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "################# DISPONIBLE DES DISQUES (Available)  ################"   >> $REP/Preleve.data_$HOST$DATEN
lsdev -Cc disk |grep  Available|wc -l|awk '{ print "Nombre Disques(Available) :" "\t" $1 }'  >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "############## TAUX UTILISATION DISQUES (% tm_act) ################"   >> $REP/Preleve.data_$HOST$DATEN
iostat 2 1 i|tail +2 >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "##### CONSOMMATION CPU PAR LES PROCESSUS ET THREAD (C) #####"   >> $REP/Preleve.data_$HOST$DATEN
ps -ef|head  -1  >> $REP/Preleve.data_$HOST$DATEN
ps -ef|grep -v PID|sort -r -k 4|head -10 >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "###### % CONSOMATION CPU PAR PROCESSUS (%CPU) ##########"  >> $REP/Preleve.data_$HOST$DATEN 
ps vg |head -1 >> $REP/Preleve.data_$HOST$DATEN
ps vg|grep -v PID|sort -r -k 11|head -10 >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "#########  % CONSOMMATION MEMOIRE PAR PROCESSUS (%MEM) ###########"  >> $REP/Preleve.data_$HOST$DATEN 
ps vg |head -1 >> $REP/Preleve.data_$HOST$DATEN
ps vg|grep -v PID|sort -r -k 12|head -10 >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "##########  TAILLE DU SEGMENT MEMOIRE DU PROCESSUS (SZ) #########"  >> $REP/Preleve.data_$HOST$DATEN 
ps aux|head -1 >> $REP/Preleve.data_$HOST$DATEN
ps aux|grep -v PID|sort -r -k 4|head -10 >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "######  TAILLE DU SEGMENT MEMOIRE RESIDENT DU PROCESSUS (RSS) ######"  >> $REP/Preleve.data_$HOST$DATEN 
ps aux|head -1 >> $REP/Preleve.data_$HOST$DATEN
ps aux|grep -v PID|sort -r -k 5|head -10 >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "################# CONTROLER LA ZONE MEMOIRE PARTAGE (IPCS)   ################"   >> $REP/Preleve.data_$HOST$DATEN 
ipcs -am |awk '{a=a+$10/1024/1024/1024 } END  {print a}'|awk '{ print "MEMOIRE TOTALE PARTAGEE(Go) :" "\t" $1 }'  >> $REP/Preleve.data_$HOST$DATEN
ipcs -am |grep sap |awk '{a=a+$10/1024/1024/1024 } END  {print a}' |awk '{ print "MEMOIRE PARTAGEE PAR SAP(Go) :" "\t" $1 }' >> $REP/Preleve.data_$HOST$DATEN
ipcs -am |grep ora |awk '{a=a+$10/1024/1024 } END  {print a}' |awk '{ print "MEMOIRE PARTAGEE PAR ORACLE(Mo) :" "\t" $1 }' >> $REP/Preleve.data_$HOST$DATEN
ipcs -am |egrep -v "ora|sap" |awk '{a=a+$10/1024/1024 } END  {print a}' |awk '{ print "MEMOIRE PARTAGEE DIVERS(Mo) :" "\t" $1 }' >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "#### NOMBRE ABSOLU ERREUR RESEAU  (Transmit Errors / Receive Errors) ######"   >> $REP/Preleve.data_$HOST$DATEN
#netstat -I -r 2 >> $REP/Preleve.data_$HOST$DATEN
#netstat -i -f inet  >> $REP/Preleve.data_$HOST$DATEN
netstat -v|egrep "ETHERNET STATISTICS|Transmit Errors|Receive Errors|Link Status|Media Speed Running|100|1000|Ethernet|Gigabit"  >>  $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "######## TAUX DE REMPLISSAGE DES FILE SYSTEM (%Used) #######"  >> $REP/Preleve.data_$HOST$DATEN
df -k|grep -v proc|sort  -r -k 4 >>  $REP/Preleve.data_$HOST$DATEN 
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
echo "########### CONTROLER LES MESSAGES LOG SYSTEM  (errpt) ############"   >> $REP/Preleve.data_$HOST$DATEN
errpt  >> $REP/Preleve.data_$HOST$DATEN
echo "\n" >> $REP/Preleve.data_$HOST$DATEN
#echo " erreur materiel " >> $REP/Preleve.data_$HOST$DATEN
#errpt -dH  >> $REP/Preleve.data_$HOST$DATEN
#echo "################# D I V E R S "  >> $REP/Preleve.data_$HOST$DATEN
#echo "################# P A R A M E T R E S   S Y S T E M E    ################"   >> $REP/Preleve.data_$HOST$DATEN
#echo "  parametre systeme "  >> $REP/Preleve.data_$HOST$DATEN
#vmo -L  >> $REP/Preleve.data_$HOST$DATEN
#ps -elf|sort -k 4|tail -15 >>  $REP/Preleve.data_$HOST$DATEN
