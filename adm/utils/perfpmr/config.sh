#!/bin/ksh
#
# COMPONENT_NAME: perfpmr
#
# FUNCTIONS: none
#
# ORIGINS: IBM
#
# (C) COPYRIGHT International Business Machines Corp. 2000
# All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# config.sh
#
# invoke configuration commands and create report
#
#set -x
unset EXTSHM
export LANG=C
CFGOUT=config.sum
PERFPMRDIR=`whence $0`
PERFPMRDIR=`/usr/bin/ls -l $PERFPMRDIR |/usr/bin/awk '{print $NF}'`
PERFPMRDIR=`/usr/bin/dirname $PERFPMRDIR` ; export PERFPMRDIR
BIN=/usr/bin
if [ "$GETGENNAMES" = 0 ]; then
        nogennames=1
fi

show_usage()
{
	echo "Usage: config.sh [-aglps]"
	echo "\t-a  do not run lsattr on every device"
	echo "\t-g  do not run gennames command"
	echo "\t-l  do not run detailed LVM commands on each LV"
	echo "\t-p  do not run lspv on each disk"
	echo "\t-s  do not run SSA cfg commands"
	echo "\toutput is generated in $CFGOUT"
	exit 1
}


while getopts :gslap flag ; do
        case $flag in
                p)     nolspv=1;;
                g)     nogennames=1;;
                s)     nossa=1;;
                l)     nolv=1;;
                a)     nolsattr=1;;
                \?)    show_usage
        esac
done


echo "\n     CONFIG.SH: Generating SW/HW configuration"

echo "\n\n\n        C O N F I G U R A T I O N     S  U  M  M  A  R  Y     O  U  T  P  U  T\n\n\n" > $CFGOUT
echo "\n\nHostname:  "  `$BIN/hostname -s` >> $CFGOUT
echo     "Time config run:  " `$BIN/date` >> $CFGOUT
echo     "AIX VRLM (oslevel):  " `$BIN/oslevel` >> $CFGOUT

echo "\n\nPROCESSOR TYPE  (uname -m)" >> $CFGOUT
echo     "--------------------------\n" >> $CFGOUT
$BIN/uname -m  >> $CFGOUT
echo     "        ## = model" >> $CFGOUT

echo "\n\nMEMORY  (bootinfo -r):  " `bootinfo -r`  >> $CFGOUT
echo     "MEMORY  (lscfg -l memN)" >> $CFGOUT
echo     "-----------------------\n"  >> $CFGOUT
lscfg -l mem* >> $CFGOUT

# get current paging space info
echo "\n\nPAGING SPACES  (lsps -a)" >> $CFGOUT
echo     "------------------------\n" >> $CFGOUT
lsps -a  >> $CFGOUT

echo "\n\nPAGING SPACES  (lsps -s)" >> $CFGOUT
echo     "------------------------\n" >> $CFGOUT
lsps -s  >> $CFGOUT

echo "\n\nINTERPROCESS COMMUNICATION FACILITY STATUS (ipcs -a)" >> $CFGOUT
echo     "----------------------------------------------------\n" >> $CFGOUT
$BIN/ipcs -a  >> $CFGOUT

# get detail device info
echo "\f\n\nPHYSICAL / LOGICAL DEVICE DETAILS  (lsdev -C | sort +2)" >> $CFGOUT
echo       "-------------------------------------------------------\n" >> $CFGOUT
lsdev -C | $BIN/sort +2 >> $CFGOUT

# get current physical volume names
echo "\f\n\nPHYSICAL VOLUMES  (lspv)" >> $CFGOUT
echo       "------------------------\n" >> $CFGOUT
lspv  >> $CFGOUT

# get detail physical volume info
if [ ! -n "$nolspv" ]; then
 for i in `lspv | $BIN/awk '{print $1}'`; do
    echo "\n\nPHYSICAL VOLUME DETAILS FOR $i  (lspv -l $i)" >> $CFGOUT
    echo     "------------------------------------------------------\n" >> $CFGOUT
    lspv -l $i >> $CFGOUT   2>&1
 done
fi

# get detail volume group info
for i in `lsvg -o`; do
  echo "\n\nVOLUME GROUP DETAILS  (lsvg -l $i)" >> $CFGOUT
  echo     "-------------------------------------------\n" >> $CFGOUT
  lsvg -l $i >> $CFGOUT
done

# get current mount info
echo "\f\n\nMOUNTED FILESYSTEMS  (mount)" >> $CFGOUT
echo       "----------------------------\n" >> $CFGOUT
mount  >> $CFGOUT

echo "\n\nFILE SYSTEM INFORMATION:  (lsfs -q)"  >> $CFGOUT
echo     "-----------------------------------\n" >> $CFGOUT
lsfs -q  >>  $CFGOUT   2>&1

echo "\n\nFILE SYSTEM SPACE:  (df)"  >> $CFGOUT
echo     "------------------------\n" >> $CFGOUT
$BIN/df    >>  $CFGOUT &
dfpid=$!
dfi=0;dftimeout=30
while [ $dfi -lt $dftimeout ]; do
        /usr/bin/ps -p $dfpid >/dev/null
        if [ $? = 0 ]; then
                sleep 2
        else
                break
        fi
        let dfi=dfi+1
done
if [ "$dfi" = $dftimeout ]; then
        echo "Killing <df> process"
        kill -9 $dfpid
fi


if [ ! -n "$nolv" ]; then
 for LV in $(lsvg -o|lsvg -il|awk '{print $1}'|egrep -v ':|LV') ; do
   echo "\n\nLOGICAL VOLUME DETAILS   (lslv $LV)"
   echo     "---------------------------------------\n"
   lslv $LV
   echo
 done >> $CFGOUT
fi


# ============================= SSA CFG ====================================

if [ ! -n "$nossa" ]; then
  echo "\n\nMapping of SSA hdisk to pdisk" >> $CFGOUT
  echo     "-----------------------------\n" >> $CFGOUT
  for i in $(lsdev -Csssar -thdisk -Fname)
  do
    echo "ssaxlate -l $i: `ssaxlate -l $i`"  >> $CFGOUT
  done

  echo "\n\nMapping of SSA pdisk to hdisk" >> $CFGOUT
  echo     "-----------------------------\n" >> $CFGOUT
  for i in $(lsdev -Csssar -cpdisk -Fname)
  do
    echo "ssaxlate -l $i: `ssaxlate -l $i`"   >> $CFGOUT
  done

  echo "\n\nSSA connection data (ssaconn -l pdiskN -a ssaN)" >> $CFGOUT
  echo     "-----------------------------------------------\n" >> $CFGOUT
  for pdisk in $(lsdev -Csssar -cpdisk -Fname)
  do
      for adap in $(ssaadap -l $pdisk 2>/dev/null)
      do
        ssaconn -l $pdisk -a $adap    >> $CFGOUT
      done
  done

  echo "\n\nSSA connection data sorted by link" >> $CFGOUT
  echo "(ssaconn -l all_pdisks -a all_ssa_adapters | $BIN/sort -d +4 -5 +2 -3)"   >> $CFGOUT
  echo "-----------------------------------------------------------------"  >> $CFGOUT
  unset Cssa
  for adap in $(lsdev -Ctssa -Fname) $(lsdev -Ctssa160 -Fname)
  do
    for pdisk in $(lsdev -Csssar -cpdisk -Fname)
    do
      xssa=$(ssaconn -l $pdisk -a $adap 2>/dev/null )
      if [[ -n $xssa ]]
      then
        Cssa="$Cssa\\n$xssa"
      fi
    done
    echo "$Cssa" | $BIN/sort -d +4 -5 +2 -3      >> $CFGOUT
    unset Cssa
    unset string
  done

  for adap in $(ssaraid -M 2>/dev/null)
  do
    echo "\n\nssaraid -l $adap -I"    >> $CFGOUT
    echo     "-------------------"   >> $CFGOUT
    ssaraid -l $adap -I           >> $CFGOUT
  done

fi   # no ssa

# =====================   END OF SSA CFG ===================================


# get static network configuration info
echo "\f\n\nNETWORK  CONFIGURATION  INFORMATION" >> $CFGOUT
echo       "-----------------------------------\n" >> $CFGOUT
for i in  in rn D an c
do
  echo "netstat -$i:"  >> $CFGOUT
  echo "------------\n"  >> $CFGOUT
  netstat -$i >> $CFGOUT
  echo "\n\n" >> $CFGOUT
done

echo "\n\nINTERFACE CONFIGURATION:  (ifconfig -a)" >> $CFGOUT
echo     "------------------------\n"  >> $CFGOUT
ifconfig -a >>  $CFGOUT

echo "\n\nNETWORK OPTIONS:  (no -a)" >> $CFGOUT
echo     "-------------------------\n"  >> $CFGOUT
no -a >>  $CFGOUT

echo "\n\nNFS OPTIONS:  (nfso -a)" >> $CFGOUT
echo     "-----------------------\n"  >> $CFGOUT
nfso -a >>  $CFGOUT

echo "\n\nshowmount -a" >> $CFGOUT
echo     "------------\n"  >> $CFGOUT
showmount -a      >>  $CFGOUT    2>&1


# Capture all lsattr settings
if [ ! -n "$nolsattr" ]; then
  lsdev -C -r name | while read DEVS; do
      	echo "\n\nlsattr -E -l $DEVS"
      	echo     "--------------------\n"
      	lsattr -E -l $DEVS  2>&1
  done >> $CFGOUT
fi

# collect schedtune and vmtune current settings
echo "\n\nSCHEDTUNE SETTINGS   (schedtune)" >> $CFGOUT
echo     "--------------------------------\n"  >> $CFGOUT
if [ -f /usr/samples/kernel/schedtune ]; then
     /usr/samples/kernel/schedtune  >> $CFGOUT
else
     echo "/usr/samples/kernel/schedtune not installed" >> $CFGOUT
     echo "   This program is part of the bos.adt.samples fileset" >> $CFGOUT
fi


echo "\n\nVMTUNE SETTINGS  (vmtune)" >> $CFGOUT
echo     "-------------------------\n"  >> $CFGOUT
if [ -f /usr/samples/kernel/vmtune ]; then
     /usr/samples/kernel/vmtune  >> $CFGOUT
     echo "\n\nVMTUNE SETTINGS  (vmtune -a)" >> $CFGOUT
     echo     "----------------------------\n"  >> $CFGOUT
     /usr/samples/kernel/vmtune -a   >> $CFGOUT   2>&1
     echo "\n\nVMTUNE SETTINGS  (vmtune -A)" >> $CFGOUT
     echo     "----------------------------\n"  >> $CFGOUT
     /usr/samples/kernel/vmtune -A   >> $CFGOUT 2>&1
else
     echo "/usr/samples/kernel/vmtune not installed" >> $CFGOUT
     echo "   This program is part of the bos.adt.samples fileset" >> $CFGOUT
fi

# =====================  WORKLOAD MANAGER ===============================
echo "\n\nworkload manager status  (wlmcntrl -q ; echo \$?)" >> $CFGOUT
echo     "-------------------------------------------------" >> $CFGOUT
wlmcntrl -q  2>&1 >> $CFGOUT
echo $?      >> $CFGOUT

echo "\n\nworkload manager classes (lsclass -C)" >> $CFGOUT
echo     "-------------------------------------" >> $CFGOUT
 lsclass -C   >> $CFGOUT
# =====================  END OF WORKLOAD MANAGER ===========================



# =====================  GEN* COMMANDS ===============================
# get genkld and genkex output
echo "\n\nGENKLD OUTPUT  (genkld)" >> $CFGOUT
echo     "-----------------------\n"  >> $CFGOUT
whence genkld > /dev/null  2>&1
if [ $? = 0 ]; then
     #genkld |$BIN/sort > genkld.out
     genkld  > genkld.out
else
     echo "genkld not installed or not in current PATH"  >> $CFGOUT
     echo "   This program is part of the optional perfagent.tools fileset" >> $CFGOUT
fi

echo "\n\nGENKEX OUTPUT  (genkex)" >> $CFGOUT
echo     "-----------------------\n"  >> $CFGOUT
whence genkex > /dev/null  2>&1
if [ $? = 0 ]; then
     #genkex | $BIN/sort >  genkex.out
     genkex  >  genkex.out
else
     echo "genkex not installed or not in current PATH"  >> $CFGOUT
     echo "   This program is part of the optional perfagent.tools fileset" >> $CFGOUT
fi

# ==================  END OF GEN* COMMANDS ===============================


echo "\n\nSYSTEM AUDITING STATUS  (audit query)"    >> $CFGOUT
echo     "-------------------------------------\n"  >> $CFGOUT
audit query  >>  $CFGOUT


echo "\n\nSHELL ENVIRONMENT  (env)"    >> $CFGOUT
echo     "------------------------\n"  >> $CFGOUT
env   >>  $CFGOUT

echo "\n\nSHELL ENVIRONMENTS (getevars -l > getevars.out)" >> $CFGOUT
echo     "--------------------------------------------\n"  >> $CFGOUT
$PERFPMRDIR/getevars -l > getevars.out


# get 2000 lines of verbose error report output
echo "\n\nVERBOSE ERROR REPORT   (errpt -a | head -2000 > errpt_a)" >> $CFGOUT
echo     "--------------------------------------------------------\n" >> $CFGOUT
$BIN/errpt -a | head -2000 > errpt_a
# get 100 most recent entries in errpt
echo "ERROR REPORT   (errpt | head -100)" >> $CFGOUT
echo "----------------------------------\n" >> $CFGOUT
$BIN/errpt | head -100  >> $CFGOUT


# get lpp history info
echo "\f\n\nLICENSED  PROGRAM  PRODUCT  HISTORY  (lslpp -ch)" >> $CFGOUT
echo       "------------------------------------------------\n" >> $CFGOUT
/usr/bin/lslpp -ch >> $CFGOUT


# get java lpp info
echo "\n\njava -fullversion" >> $CFGOUT
echo     "-----------------\n" >> $CFGOUT
whence java >> $CFGOUT  2>&1
if [ $? = 0 ]; then
    java -fullversion >> $CFGOUT    2>&1
fi


# get slot information
echo "\f\n\nPCI SLOT CONFIGURATION  (lsslot -c pci)" >> $CFGOUT
echo       "-----------------------------------------\n" >> $CFGOUT
lsslot -c pci >> $CFGOUT 2>/dev/null


# get verbose machine configuration
#  added because it is useful to tell between 601 and 604 upgrades
echo "\f\n\nVERBOSE MACHINE CONFIGURATION  (lscfg -vp)" >> $CFGOUT
echo       "-----------------------------------------\n" >> $CFGOUT
lscfg -vp  >> $CFGOUT


# get cache info via Matt's program
echo "\f\n\nPROCESSOR DETAIL  (lsc -m)" >> $CFGOUT
echo       "--------------------------\n" >> $CFGOUT
$PERFPMRDIR/lsc -m >> $CFGOUT


# get kproc and thread info AND kernel heap stats
echo "\n\nKERNEL THREAD TABLE  (pstat -A)" >> $CFGOUT
echo     "-------------------------------\n" >> $CFGOUT
pstat -A >> $CFGOUT
echo "xm -u" | /usr/sbin/kdb >> $CFGOUT

# get vnode and vfs info
echo "vnode"|/usr/sbin/kdb > vnode.kdb
echo "vfs"|/usr/sbin/kdb > vfs.kdb


# get devtree information
/usr/lib/boot/bin/dmpdt_chrp -i > devtree.out 2>&1

# get system dump config info
echo "\n\nSYSTEM DUMP INFO (sysdumpdev -l;sysdumpdev -e)" >> $CFGOUT
echo     "----------------------------------------------\n" >> $CFGOUT
sysdumpdev -l >> $CFGOUT
sysdumpdev -e >> $CFGOUT


# get bosdebug settings
echo "\n\nbosdebug -L" >> $CFGOUT
echo     "-----------\n" >> $CFGOUT
bosdebug -L  >> $CFGOUT



# get ls of kernel in use
echo "\n\nls -al /unix INFO" >> $CFGOUT
echo     "-----------------" >> $CFGOUT
ls -al /unix  >> $CFGOUT
echo "\nls -al /usr/lib/boot/uni* INFO" >> $CFGOUT
echo   "------------------------------" >> $CFGOUT
ls -al /usr/lib/boot/uni*  >> $CFGOUT


# get power management settings
echo "\n\npower management (pmctrl -v)" >> $CFGOUT
echo     "----------------------------\n" >> $CFGOUT
pmctrl -v  >> $CFGOUT  2>&1


# get gennames output if needed (not present or older than .init.state)
if [ ! -n "$nogennames" ]; then
	echo "\n\ngennames > gennames.out" >> $CFGOUT
	echo     "-----------------------\n" >> $CFGOUT
	if [ ! -f gennames.out -o gennames.out -ot /etc/.init.state ]; then
     		gennames > gennames.out  2>&1
	fi
fi

# get crontab -l info
echo "\n\ncrontab -l > crontab_l" >> $CFGOUT
echo     "----------------------\n" >> $CFGOUT
crontab -l > crontab_l

# get /etc/security/limits
echo "\n\ncp /etc/security/limits etc_security_limits" >> $CFGOUT
echo     "-------------------------------------------\n" >> $CFGOUT
cp /etc/security/limits etc_security_limits
# get misc files
/usr/bin/cp /etc/inittab  etc_inittab
/usr/bin/cp /etc/filesystems  etc_filesystems
/usr/bin/cp /etc/rc  etc_rc

# get what output of /unix
/usr/bin/what /unix > unix.what


echo "config.sh data collection completed." >> $CFGOUT
echo "     CONFIG.SH: Report is in file $CFGOUT"

###end of shell
