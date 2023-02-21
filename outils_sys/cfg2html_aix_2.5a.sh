#!/bin/ksh
#
# set -vx

PATH=$PATH:/local/bin:/local/sbin:/usr/bin:/usr/sbin:/local/gnu/bin:/usr/ccs/bin:/local/X11/bin:/usr/openwin/bin:/usr/dt/bin:/usr/proc/bin:/usr/ucb:/local/misc/openv/netbackup/bin

RCCS="@(#)Cfg2Html -IBM- Version 2.5a"		# useful for what (1)
VERSION=$(echo $RCCS | cut -c5-)

# Thanks to Olaf Morgenstern (olaf.morgenstern@web.de) for several improvements
# Thanks to Jim Lane (JLane@torontohydro.com) for lsuser & lsgroup command
# "Stolen" Command-line option structure with getopts from HP-UX version from Ralph Roth
# Thanks to colleague Marco Stork for supplying the PrtLayout function

# TODO: alstat  emstat  gennames  locktrace  truss  wimmon
# TODO: errpt -a bij -x

#----------------------------------------------------------------------------
# use "yes/no" to enable/disable a collection; CASE sensitive !!
CFG_CRON=yes            # C
CFG_DEFRAG=yes          # d
CFG_DISKS=yes           # D
CFG_FILES=yes           # f
CFG_FILESYS=yes         # F
CFG_HARDWARE=yes        # H
CFG_KERNEL=yes          # K
CFG_LUM=yes             # l
CFG_LVM=yes             # L
CFG_NIM=yes             # n
CFG_NETWORK=yes         # N
CFG_PASSWD=yes          # p
CFG_PRINTER=yes         # P
CFG_QUOTA=yes           # Q
CFG_SOFTWARE=yes        # s
CFG_SYSTEM=yes          # S
CFG_USERS=yes           # U

#----------------------------------------------------------------------------
line ( ) {
   echo "--=[ "$(tput smso)"http://come.to/cfg2html"$(tput sgr0)" ]=------------------------------------------------"
}

# echo "\n"
if [ $(id -u) != 0 ] ; then
   banner "Sorry"
   line
   echo "You must run this script as Root\n"
   exit 1
fi

#-------------------------------------------
usage() {
   echo "\n usage: cfg2html_aix.sh [options]\n\ncreates HTML and plain ASCII host documentation"
   echo
   # echo "  -o		set directory to write (or use the environment variable)"
   # echo "                OUTDIR=\"/path/to/dir\" (directory must exist)"
   # echo "  -L		DIS-able: Screen tips inline"
   # echo "  -a		DIS-able: Applications"
   # echo "  -e		DIS-able: Enhancements"
   # echo "  -x		don't create background images"

   echo "  -h		display this help and exit"
   echo "  -v		output version information and exit"
   echo "  -x		eXtended output"
   echo "  -y		Debug output"
   echo
   echo "use the following (case-sensitive) options to (enable/)disable collectors"
   echo
   echo "  -^		Reverse Yes/No; MUST be first option"
   echo "  -C		DIS-able: Cron"
   echo "  -d		DIS-able: Defragfs"
   echo "  -D		DIS-able: Disks"
   echo "  -f		DIS-able: Files"
   echo "  -F		DIS-able: Filesystem"
   echo "  -H		DIS-able: Hardware"
   echo "  -K		DIS-able: Kernel"
   echo "  -l		DIS-able: LUM"
   echo "  -L		DIS-able: LVM"
   echo "  -n		DIS-able: NIM"
   echo "  -N		DIS-able: Network"
   echo "  -p		DIS-able: Password"
   echo "  -P		DIS-able: Printer"
   echo "  -Q		DIS-able: Quota"
   echo "  -s		DIS-able: Software"
   echo "  -S		DIS-able: System"
   echo "  -U		DIS-able: Users"

   echo
   # echo  "\n(#) these collectors create a lot of information!"
   echo  "Example:  $0 -C   to skip CRON"
   echo  "          $0 -^C  to do -ONLY- CRON"
   echo
}

EXTENDED=0
VERBOSE=0
YESNO="no"

while getopts ":^CdDfFhHKlLnNpPQsSUvVxXyY" Option
do
   case $Option in
      "^" ) YESNO="yes"	;
	    CFG_CRON="no"	;	# C
	    CFG_DEFRAG="no"	;	# d
	    CFG_DISKS="no"	;	# D
	    CFG_FILES="no"	;	# f
	    CFG_FILESYS="no"	;	# F
	    CFG_HARDWARE="no"	;	# H
	    CFG_KERNEL="no"	;	# K
	    CFG_LUM="no"	;	# l
	    CFG_LVM="no"	;	# L
	    CFG_NIM="no"	;	# n
	    CFG_NETWORK="no"	;	# N
	    CFG_PASSWD="no"	;	# p
	    CFG_PRINTER="no"	;	# P
	    CFG_QUOTA="no"	;	# Q
	    CFG_SOFTWARE="no"	;	# s
	    CFG_SYSTEM="no"	;	# S
	    CFG_USERS="no"	;	# U
	    ;;
      C   ) CFG_CRON=$YESNO	;;	# Cron(tab)
      d   ) CFG_DEFRAG=$YESNO	;;	# Defragfs
      D   ) CFG_DISKS=$YESNO	;;	# Disks
      f   ) CFG_FILES=$YESNO	;;	# List various files
      F   ) CFG_FILESYS=$YESNO	;;	# File System Info
      h   ) usage; exit		;;	#   Usage
      H   ) CFG_HARDWARE=$YESNO	;;	# Hardware Info
      K   ) CFG_KERNEL=$YESNO	;;	# Kernel Info
      l   ) CFG_LUM=$YESNO	;;	# License Use Manager
      L   ) CFG_LVM=$YESNO	;;	# Logical Volume Manager
      n   ) CFG_NIM=$YESNO	;;	# Network Installation Management
      N   ) CFG_NETWORK=$YESNO	;;	# Network Info
      p   ) CFG_PASSWD=$YESNO	;;	# passwd / group etc.
      P   ) CFG_PRINTER=$YESNO	;;	# Printer(s)
      Q   ) CFG_QUOTA=$YESNO	;;	# Disk quota
      s   ) CFG_SOFTWARE=$YESNO	;;	# Installed Software
      S   ) CFG_SYSTEM=$YESNO	;;	# System Information
      U   ) CFG_USERS=$YESNO	;;	# User Information
      v|V ) echo $VERSION; exit	;;	#   Print version
      x|X ) EXTENDED=1		;;	# Extra Information
      y|Y ) VERBOSE=1		;;	# Debug Info
      *   ) echo "Unimplemented option ($Option) chosen! OPTARG=$OPTARG"; usage; exit 1 ;;
   esac
done

shift $(($OPTIND - 1))
# Decrements the argument pointer so it points to next argument.

if (( EXTENDED == 0 )); then				# geen parameter  -x
   echo "\n  >> Use option '$(tput rev)[-x]$(tput sgr0)' for 'Extended' output <<$(tput bel)\n"
fi
# echo "Klaar"; exit

set ''			# schoonmaken van $1, $2 enz...; worden anders te vroeg geinterpreteerd....

HTML_OUTFILE=$(uname -n).html
HTML_OUTFILE_TEMP=/tmp/$(uname -n).html.$$
TEXT_OUTFILE=$(uname -n).txt
TEXT_OUTFILE_TEMP=/tmp/$(uname -n).txt.$$
ERROR_LOG=$(uname -n).err
# DEBUG_LOG=$(uname -n).deb; >$DEBUG_LOG		# DeBug

# Convert illegal characters for HTML into escaped ones.
# Convert '&' first! (Peter Bisset [pbisset@emergency.qld.gov.au])
CONVSTR='
s/&/\&amp;/g
s/</\&lt;/g
s/>/\&gt;/g
s/\\/\&#92;/g
'

touch $HTML_OUTFILE

echo "Starting up $VERSION\r"
[ -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null

SEP="================================"
DATE=$(date "+%Y-%m-%d")			# ISO8601 compliant date string
DATEFULL=$(date "+%Y-%m-%d - %H:%M:%S")		# ISO8601 compliant date and time string
CURRDATE=$(date +"%b %e %Y")

# Let the cache expire since this script runs every night
EXPIRE_CACHE=$(date "+%a, %d %b %Y ")"23:00 GMT"

# IPADRES=$(cut -d"#" -f1 /etc/hosts | awk '{for (i=2; i<=NF; i++) if ("'$HOSTNAME'" == $i) {print $1; exit}}') # n.u.
ANTPROS=$(lscfg | grep 'proc[0-9]' | awk 'END {print NR}')
# SPEED=$(psrinfo -v | awk '/MHz/{print $(NF-1); exit }')	# TODO... VEEL werk, stom... IBM ?....
SPEED=XXX							# TODO
# CPU=$(lscfg | grep Architecture | cut -d: -f2)		# n.u.

# Bruce Spencer, IBM # 2/4/99
# This program identifies the CPU type on a RS/6000
# Note:  newer RS/6000 models such as the S70 do not have a unique name
CODE=$(uname -m | cut -c9,10 )
case $CODE in
   02) MODEL="7015-930";;
   10) MODEL="7016-730, 7013-530, 7016-730";;
   14) MODEL="7013-540";;
   18) MODEL="7013-53H";;
   1C) MODEL="7013-550";;
   20) MODEL="7015-930";;
   2E) MODEL="7015-950";;
   30) MODEL="7013-520, 7018-740/741";;
   31) MODEL="7012-320";;
   34) MODEL="7013-52H";;
   35) MODEL="7012-32H";;
   37) MODEL="7012-340";;
   38) MODEL="7012-350";;
   41) MODEL="7011-220";;
   42) MODEL="7006-41T/41W";;
   43) MODEL="7008-M20";;
   46) MODEL="7011-250";;
   47) MODEL="7011-230";;
   48) MODEL="7009-C10";;
   4C) MODEL="7248-43P";;
   57) MODEL="7012-390, 7030-3BT";;
   58) MODEL="7012-380, 7030-3AT";;
   59) MODEL="7012-39H, 7030-3CT";;
   5C) MODEL="7013-560";;
   63) MODEL="7015-970/97B";;
   64) MODEL="7015-980/98B";;
   66) MODEL="7013-580/58F";;
   67) MODEL="7013-570/770/771/R10";;
   70) MODEL="7013-590";;
   71) MODEL="7013-58H";;
   72) MODEL="7013-59H/R12";;
   75) MODEL="7012-370/375/37T";;
   76) MODEL="7012-360/365/36T";;
   77) MODEL="7012-355/55H/55L";;
   79) MODEL="7013-590";;
   80) MODEL="7015-990";;
   82) MODEL="7015-R24";;
   89) MODEL="7013-595";;
   90) MODEL="7009-C20";;
   91) MODEL="7006-42x";;
   94) MODEL="7012-397";;
   A0) MODEL="7013-J30";;
   A1) MODEL="7013-J40";;
   A3) MODEL="7015-R30";;
   A4) MODEL="7015-R40";;
   A6) MODEL="7012-G30";;
   A7) MODEL="7012-G40";;
   C0) MODEL="7024-E20";;
   C4) MODEL="7025-F40";;
    *) MODEL="Unknown";;
esac
TYPE=$MODEL

#----------------------------------------------------------

exec 2> $ERROR_LOG

if [ ! -f $HTML_OUTFILE ] ; then
   banner "Error"
   line
   echo "You have not the rights to create $HTML_OUTFILE! (NFS?)\n"
   exit 1
fi

RECHNER=$(uname -n)
OSLEVEL=$(oslevel)			# n.u...
typeset -i HEADL=0			# Headinglevel

osrever="$(uname -v)$(uname -r)"
osrev=$(uname -v)

if [ "$osrev" -lt 4 ] ; then
   banner "Sorry"
   line
   echo "$0: Requires AIX 4.x or better!\n"
   exit 1
fi

####################################################################
# needs improvement!
# trap "echo Signal: Aborting!; rm $HTML_OUTFILE_TEMP"  2 13 15
####################################################################
#  Beginn des HTML Dokumentes mit Ueberschrift und Titel
####################################################################
#  Header of HTML file
####################################################################
open_html () {
   echo " \
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML> <HEAD>
 <META NAME="GENERATOR" CONTENT="Selfmade-$RCCS-vi AIX 4.x">
 <META NAME="AUTHOR" CONTENT="Gert.Leerdam@getronics.com">
 <META NAME="CREATED" CONTENT="\"Gert Leerdam\"">
 <META NAME="CHANGED" CONTENT="$(id) %A%">
 <META NAME="DESCRIPTION" CONTENT="$Header: cfg2html.sh,v 0.0x $DATE root Exp $">
 <META NAME="subject" CONTENT="$VERSION on $RECHNER by Gert.Leerdam@getronics.com">
<TITLE>${RECHNER} - Documentation - $VERSION</TITLE>
</HEAD><BODY>
<BODY LINK="#0000ff" VLINK="#800080" BACKGROUND="cfg2html_back.jpg">
<H1><CENTER><FONT COLOR=blue>
<P><hr><B>$RECHNER - AIX "$(oslevel)" - System Documentation</P></H1>
<hr><FONT COLOR=blue><small>Created: - "$DATEFULL" - with: " $VERSION "</font></center></B></small>
<HR><H1>Contents\n</font></H1>\n\
" >$HTML_OUTFILE

   (line;banner $RECHNER;line) > $TEXT_OUTFILE
   echo "\n" >> $TEXT_OUTFILE
   echo "\n" > $TEXT_OUTFILE_TEMP
}

######################################################################
#  Increases the headling level
######################################################################
inc_heading_level () {
   HEADL=HEADL+1
   echo "<UL>\n" >> $HTML_OUTFILE
}

######################################################################
#  Decreases the heading level
######################################################################
dec_heading_level () {
   HEADL=HEADL-1
   echo "</UL>\n" >> $HTML_OUTFILE
}

######################################################################
#  Creates an own paragraph, $1 = heading
######################################################################
paragraph () {
   if [ "$HEADL" -eq 1 ] ; then
      echo "\n<HR>\n" >> $HTML_OUTFILE_TEMP
   fi

   # echo "\n<table WIDTH="90%"><tr BGCOLOR="#CCCCCC"><td>\n" >> $HTML_OUTFILE_TEMP
   echo "<A NAME=\"$1\">" >> $HTML_OUTFILE_TEMP
   echo "<A HREF=\"#Inhalt-$1\"><H${HEADL}> $1 </H${HEADL}></A><P>" >> $HTML_OUTFILE_TEMP
   # echo "<A HREF=\"#Inhalt-$1\"><H${HEADL}> $1 </H${HEADL}></A></table><P>" >> $HTML_OUTFILE_TEMP

   if [ "$HEADL" -eq 1 ] ; then
      echo "<IMG SRC="profbull.gif" WIDTH=14 HEIGHT=14>" >> $HTML_OUTFILE
   else
      echo "<LI>\c" >> $HTML_OUTFILE
   fi
   echo "<A NAME=\"Inhalt-$1\"></A><A HREF=\"#$1\">$1</A>" >> $HTML_OUTFILE
   if [ "$HEADL" -eq 1 ] ; then
      # echo "\nCollecting: " $1 " .\c"
      echo "\nCollecting: $1 .\c"
      if (( VERBOSE == 1 )) ; then
	 echo " +++"
      fi
   fi
   echo "    $1" >> $TEXT_OUTFILE
}

######################################################################
#  Documents the single commands and their output
#  $1  = unix command,  $2 = text for the heading
######################################################################
exec_command () {
   if [ -z "$3" ] ; then	# if string 3 is zero
      TiTel="$1"
   else
      TiTel="$3"
   fi

   if (( VERBOSE == 1 )) ; then
      echo "$(date '+ %b-%d %T') - $TiTel +++"
   else
      echo ".\c"
   fi

   echo "\n---=[ $2 ]=----------------------------------------------------------------" |
      cut -c1-74 >> $TEXT_OUTFILE_TEMP
   echo "       - $2" >> $TEXT_OUTFILE

   ###### the working horse ##########
   TMP_EXEC_COMMAND_ERR=/tmp/exec_cmd.tmp.$$
   EXECRES=$(eval $1 2> $TMP_EXEC_COMMAND_ERR | expand | cut -c 1-150 | sed "$CONVSTR")
   if [ -z "$EXECRES" ] ; then
      EXECRES="n/a"
   fi

   if [ -s $TMP_EXEC_COMMAND_ERR ] ; then
      echo "stderr output from \"$1\":" >> $ERROR_LOG
      cat $TMP_EXEC_COMMAND_ERR | sed 's/^/    /' >> $ERROR_LOG
   fi
   rm -f $TMP_EXEC_COMMAND_ERR

   echo "\n" >> $HTML_OUTFILE_TEMP	# write header above output
   echo "<A NAME=\"$2\"></A> <H${HEADL}><A HREF=\"#Inhalt-$2\" title=\"$TiTel\"> $2 </A></H${HEADL}>\n" >> $HTML_OUTFILE_TEMP	# orig screentips by Ralph

   # display inhoud ($EXECRES)
   echo "<PRE><B>$EXECRES</B></PRE>\n"  >> $HTML_OUTFILE_TEMP					# write contents
   echo "<meta http-equiv=\"expires\" content=\"${EXPIRE_CACHE}\">">> $HTML_OUTFILE_TEMP	# expires...

   echo "<LI><A NAME=\"Inhalt-$2\"></A><A HREF=\"#$2\" title=\"$TiTel\">$2</A>\n" >> $HTML_OUTFILE	# writes header of index
   echo "$EXECRES\n" >> $TEXT_OUTFILE_TEMP
}

################# Schedule a job for killing commands which ###############
################# may hang under special conditions. <mortene@sim.no> #####
# Argument 1: regular expression to search processlist for. Be careful
# when specifiying this so you don't kill any more processes than
# those you are looking for!
# Argument 2: number of minutes to wait for process to complete.
######################################################################
KillOnHang () {
   TMP_KILL_OUTPUT=/tmp/kill_hang.tmp.$$
   at now + $2 minutes 1>$TMP_KILL_OUTPUT 2>&1 <<EOF
   ps -ef | grep root | grep -v grep | egrep $1 | awk '{print \$2}' | sort -n -r | xargs kill
EOF
   AT_JOB_NR=$(egrep '^job' $TMP_KILL_OUTPUT | awk '{print \$2}')
   rm -f $TMP_KILL_OUTPUT
}

######################################################################
# You should always match a KillOnHang() call with a matching call
# to this function immediately after the command which could hang
# has properly finished.
######################################################################
CancelKillOnHang () {
   at -r $AT_JOB_NR
}

######################################################################
################# adds a text to the output files, rar, 25.04.99 ##########
######################################################################
AddText () {
   echo "<p>$*</p>" >> $HTML_OUTFILE_TEMP
   echo "$*\n" >> $TEXT_OUTFILE_TEMP
}

######################################################################
#  end of the html document
######################################################################
close_html () {
   echo "<hr>" >> $HTML_OUTFILE
   echo "</P><P>\n<hr><FONT COLOR=blue>Created "$DATEFULL" with " $VERSION " by <A HREF="mailto:Gert.Leerdam@getronics.com?subject=$VERSION_">Gert Leerdam, SysAdm</A></P></font>" >> $HTML_OUTFILE_TEMP
   echo "</P><P>\n<FONT COLOR=blue>Based on the original script by <A HREF="mailto:Ralph_Roth@hp.com?subject=$VERSION_">Ralph Roth</A></P></font>" >> $HTML_OUTFILE_TEMP
   echo "<hr><center>\
   <A HREF="http://come.to/cfg2html">  [ Download cfg2html from external home page ] </b></A></center></P><hr></BODY></HTML>\n" >> $HTML_OUTFILE_TEMP
   cat $HTML_OUTFILE_TEMP >> $HTML_OUTFILE
   cat $TEXT_OUTFILE_TEMP >> $TEXT_OUTFILE
   rm $HTML_OUTFILE_TEMP $TEXT_OUTFILE_TEMP
   echo "\n\nCreated "$DATEFULL" with " $VERSION " (c) 2000-2002 by Gert Leerdam, SysSupp\n" >> $TEXT_OUTFILE
}

######################################################################
######################################################################
ShowLVM () {
   export PATH=$PATH:/usr/sbin

   pvs=/tmp/lvm.pvs_$$
   mnttab=/tmp/lvm.mnttab_$$

   echo "Primary:Altern:Tot.PPs:FreePPs:PPsz:Group / Volume:Filesys:LVSzPP:Cpy:Mount-Point:HW-Path / Product"

   pvs=$(lsvg -p $(lsvg) | egrep -v ':$|^PV' | awk '{printf "%s:%s:%s:%s\n",$1,"",$3,$4}')

   #  process for each physical volume (Prim. Link)
   for line in $(echo $pvs)
   do
      dev=$(echo $line | cut -d':' -f1 )
      vg=$(lspv | grep "^$dev " | awk '{print $3}')
      hwpath=$(echo $(lscfg -l $dev | tail -1) | cut -d' ' -f2- | sed 's- - / -')
      lspvs=$(lspv -l $dev | egrep -v ':$|^LV')
      lvs=$(echo "$lspvs" | awk '{print $1}')

      #  search for mount points of logical volumes
      n=1
      for lv in $(echo $lvs)
      do
	 mnt=$(echo "$lspvs" | grep "^$lv " | awk '{print $5}')
	 lvsiz=$(echo "$lspvs" | grep "^$lv " | awk '{print $2}')
	 lslv=$(lslv $lv)
	 mir=$(echo "$lslv" | grep "^COPIES:" | awk '{print $2}')
	 fstyp=$(echo "$lslv" | grep "^TYPE:" | awk '{print $2}')
	 ppsiz=$(echo "$lslv" | grep "PP SIZE" | awk '{print $6}')

	 if [[ $n = 1 ]] ; then
	    echo "$line:${ppsiz}MB:$vg/$lv:$fstyp:$lvsiz:$mir:$mnt:$hwpath"
	 else
	    echo ":::::$vg/$lv:$fstyp:$lvsiz:$mir:$mnt:"
	 fi

	 let n=$n+1
      done
   done
}

######################################################################
PrintLVM () {
   ShowLVM | awk '
      BEGIN { FS=":" }
      {
	 printf("%-7s %-7s ", $1, $2);		# prim, alt
	 printf("%-18s ", $6);			# vg/lvol
	 printf("%7s %-7s %4s ", $3, $4, $5);   # tot, free, size
	 printf("%7s %7s %3s ", $8, $7, $9);    # size, fs, mir
	 printf("%-20s %s", $10, $11);		# mnt, hwpath/prod
	 printf("\n");
      }'
}

######################################################################
PrtLayout () {
   DEBUG=0

   VGS="$1"
   if (( $# == 0 )); then
      VGS=$(lsvg | awk '{print $1}')
   fi

   if [[ "$2" != "" ]]; then
      MAN_LV="$2"
   fi

   DB ()
   {
   if (( $DEBUG == 1 )); then
      echo $* | tee -a $DB_F
   fi
   }  ## DEBUG MODE ##

   COL ()   ########## ( put var on positions )
   {
      case $1 in
      1)
	 shift
	 echo $* | awk '{printf("%10s%10s%9s%9s%16s%23s\n",$1,$2,$3,$4,$5,$6 )}'
	 ;;
      2)
	 shift
	 echo $* | awk '{printf("%10s%5s%7s%9s%5s%2s%-17s\n",$1,$2,$3,$4,$5," ",$6 )}'
	 ;;
      3)
	 shift
	 echo $* | awk '{printf("%47s%8s%22s\n",$1,$2,$3 )}'
	 ;;
      esac
   }

   DB [-]  running on debug mode

   L0="=========================================================================="
   L1="--------------------------------------------------------------------------"
   PID=$(echo $$)
   PDD=$(date "+%y%m%d")

   DB [1] $PID $PDD

   ## maak PHD list ###
   if lsdev -Cc pdisk | grep pdisk >/dev/null
   then
      >/tmp/PHD.tmp
      lsdev -Cc pdisk | awk '{print $1}' | while read PHD
      do
	 echo " $PHD $(lsattr -l $PHD -E -a=connwhere_shad 2>/dev/null | awk '{print $2}') " >> /tmp/PHD.tmp
      done
   fi  ##############

   for VG in $VGS    ### check per Volume group #########
   do
      D=$(date "+%D")
      NAME=$(uname -n)
      PP=$(lsvg $VG 2>/dev/null | awk '/SIZE/ {print $6}')

      ######### PRINT VG #####
      echo "-*-"$L0
      echo " | $VG    PPsize:$PP	          date: $D 	from: $NAME "
      echo " + $L1"
      #######################
      HDS=$(lspv 2>/dev/null | grep $VG | awk '{print $1}')

      DB [2] HDS= $HDS

      COL 1 Logical Physical  Tot_Mb Used_Mb location [Free_distribution]

      for HD in $HDS
      do
	 CAP=$(lspv $HD 2>/dev/null | awk '/PPs/{print $4}' | cut -c2-)
	 echo $CAP | read TOT_MB USED_MB USE_C  ## CAP p/ disk
	 lsvg -p $VG 2>/dev/null | awk "/$HD/{print \$5}" | sed s'/\.\./:/g' | \
	 awk -F: '{printf("%.3d:%.3d:%.3d:%.3d:%.3d\n",$1,$2,$3,$4,$5)}' | read FREE_DISTR
	 ### convert HDS PDS
	 if lsattr -l $HD -E -a=connwhere_shad 2>/dev/null >/dev/null
	 then
	    CWiD=$(lsattr -l $HD -E -a=connwhere_shad | awk '{print $2}')
	    awk "/$CWiD/{print \$1}" </tmp/PHD.tmp | read ITEM
	    PD=$(lsdev -Cc pdisk | grep "$ITEM " | awk '{print $1}')
	 else
	    PD="$HD"
	 fi
	 #### end convert ###

	 lsdev -Cc disk | awk "/$HD/{print \$3}" | read LOC

	 #####  HD  info #########################################
	 COL 1 $HD $PD $TOT_MB $USE_C $LOC $FREE_DISTR
	 #############################################################

	 DB [3]  "${PID}_${PDD} ${VG}_${HD} $PD  $TOT_MB $USED_MB $LOC $FREE_DISTR "
      done

      if [[ "$MAN_LV" = "" ]]; then
	 LVS=$(lsvg -l $VG 2>/dev/null | egrep -v "$VG|NAM"| awk '{print $1"_"$2"_"$3}')	# gen LVS
      else
	 if lsvg -l $VG | grep "$MAN_LV" >/dev/null ; then
	    LVS=$(lsvg -l $VG | egrep -v "$VG|NAM"| grep "$MAN_LV" | awk '{print $1"_"$2"_"$3}')	# gen LVS
	 else
	    echo " \n ERROR :  $MAN_LV   not on $VG ! \n"
	    exit
	 fi
      fi

      echo "   $L1 \n"

      ########################################## show ############
      COL 2 LVname LPs FStype Size used FS
      ############################################################

      for RLV in $LVS
      do
	 echo  $RLV | awk -F_ '{print $1,$2,$3}' | read LV TLV LP
	 B_SZ=$(expr $LP \* $PP)
	 case $TLV in
	    jfs|jfs2)
	       lsfs | awk "/$LV/{print \$5,\$3}" | read SZK MP
	       if [[ "$SZK" = "" ]]; then
		  SZ="${B_SZ}MB"
		  TLV="-"
	       else
		  SZ=$(expr $SZK / 2048 2>/dev/null)
		  if [[ "$B_SZ" != "$SZ" ]]; then
		     SZ="->${SZ}MB"	## warning: fs-size < lv-size
		  else
		     SZ="${SZ}MB"
		  fi
	       fi
	       df | awk "/$LV/{print \$4}" | read PRC

	       if [[ "$PRC" = "" ]]; then
		  PRC="n/a"
	       fi
	       ;;
	    paging)
	       lsps -a | grep "$LV" | grep "$VG" | awk '{print $4,$5"%"}' | read SZ PRC
	       ;;
	    *)
	       SZ=" "
	       PRC=" "
	       MP=" "
	       ;;
	 esac

	 ############### show LV  info ####################
	 COL 2 $LV  $LP  $TLV  $SZ  $PRC $MP
	 ##################################################

	 lslv -m $LV 2>/dev/null | egrep -v "LP" | awk '{print $3,$5,$7}' | sort | uniq | while read A B C
	 do
	    echo $A >>/tmp/PV_1
	    echo $B >>/tmp/PV_2
	    echo $C >>/tmp/PV_3
	 done

	 for C in 1 2 3
	 do
	    cat /tmp/PV_${C} | sort | uniq | while read PV
	    do
	       if [[ "$PV" != "" ]]; then
	       lslv -l $LV 2>/dev/null | awk "/$PV/{print \$4}" | sed 's/000/---/g' | read PPP

	       DB [4]  " PPP = $PPP "

	       if [[ "$C" = "1" ]]; then
		  Y="+"
		  PRE_PV="$PV"
	       else
		  Y="copy_$C"
		  if [[ "$PRE_PV" = "$PV" ]]; then
		     PPP=$(echo $PPP | tr "0-9" "|||||||||")
		  fi
	       fi

	       if lspv | grep $PV >/dev/null ; then  ## if hdisk not avail
		  :
	       else
		  PV="N/A"
	       fi

	       ########## show PV position  #####
	       COL 3  $Y   $PV   $PPP
	       ######################################

	       DB [5]  "${PID}_${PDD} ${VG}_${PV} $LV $LP $TLV $SZ $PRC $MP $Y $PV $PPP "
	       fi
	    done
	 done

	 rm /tmp/PV_?
      done

      echo
   done

   rm /tmp/PHD.tmp 2>/dev/null
}

######################################################################
CpuSpeed ()
{
   # cpu-speed (moeilijk-moeilijk, zie CpuSpeed[12].txt)
   #    in AIX V5:  lsattr -El proc0	# frequency 333000000      Processor Speed False
   #    of: In AIX V5 you can use the pmcycles  command (perfagent.tools fileset).
   #    zie ook: http://www.rootvg.net/RSmodels.htm

   # AIX 5.x: Determine CPU speed:
   # typeset -i10 mhz                      # integer base 10
   # lscfg -vp | grep PS= | tail -1 | awk -F= '{print $2 }' | awk -F, '{print $1}' | read f
   # typeset -i10 f=16#$f                  # integer base 10 from base 16
   # if [ $f -eq 0 ] ; then
   #    print "Cannot determine CPU speed"
   # else
   #    mhz=f/1000000                      # From Hz to MHz
   #    print "CPU Clock Speed is: $mhz MHz"
   # fi
   :						# Dummy: *NIET* weghalen !!!
}

######################################################################
bdf_collect () {
   # Stolen from: cfg2html for HP-UX
   # Revision 1.2  2001/04/18  14:51:34  14:51:34  root (Guru Ralph)

   # echo "Total Used Local Diskspace\n"
   df -Pk | grep ^/ | grep -v '^/proc' | awk '
      {
	 alloc += $2;
	 used  += $3;
	 avail += $4;
      }

      END {
	 print  "Allocated\tUsed \t \tAvailable\tUsed (%)";
	 printf "%ld \t%ld \t%ld\t \t%3.1f\n", alloc, used, avail, (used*100.0/alloc);
   }'
}

######################################################################
cron_tabs () {
   CRON_PATH=/var/spool/cron/crontabs
   for i in `ls $CRON_PATH`; do
      echo "\n-=[ Crontab entry for user $i ]=-\n"
      # cat $CRON_PATH/$i | grep -v "^#"
      cat $CRON_PATH/$i | egrep -v "^#|^[ 	]*$"	# remove comment and empty lines
   done
}

######################################################################
LsConfig () {
   for i in $(lsvg)
   do
      lsvg $i
   done | awk '
      BEGIN      { printf("%10s\t%10s\t%10s\t%10s\t%10s\n","VG","Total(MB)","Free","USED","Disks") }
      /VOLUME GROUP:/ { printf("%10s\t", $3)  }
      /TOTAL PP/ {    B=index($0,"(") + 1
		      E=index($0," megaby")
		      D=E-B
		      printf("%10s\t", substr($0,B,D) )
		 }
      /FREE PP/  {    B=index($0,"(") + 1
		      E=index($0," megaby")
		      D=E-B
		      printf("%10s\t", substr($0,B,D) )
		 }
      /USED PP/  {    B=index($0,"(")  + 1
		      E=index($0," megaby")
		      D=E-B
		      printf("%10s\t", substr($0,B,D) )
		 }
      /ACTIVE PV/ { printf("%10s\t\n", $3)  } '
}

######################################################################
psawk () {
   awkscript='
#-------------------------------------------
function putstack(ppid,   i)
{
   if (ppids[ppid] > 1)			# is er meer dan 1 ppid met dit nr.?
   {
      for (i = 1; i <= endstack; i++)	# of deze? verschil? snelheid?
	 if (stack[i] == ppid)		# bestaat al in stack?
	    return			# ja; scheelt tijd

      stack[++endstack] = ppid		# sla op
   }
}
#-------------------------------------------
function getstack()
{
   if (endstack > 0)			# zit er wat in de stack?
   {
      while (ppids[stack[endstack]] < 1)	# verlaag aantal ppids
      {
	 endstack--			# stack leeg, neem voorgaande
	 if (endstack < 1)		# allemaal op
	    return 0
      }

      return stack[endstack]		# return stackwaarde
   }
   else
      return 0				# stack was leeg
}

#-------------------------------------------
function getlevel(curpid,   n)
{
   n = 1
   while (tree[curpid] != 0)
   {
      curpid = tree[curpid]
      n++
   }

   return n
}

#-------------------------------------------
function printnow(line,   spc, subs, ind, sub2, sub3)
{
   spc = substr(spcs,1,level - 1)
   subs = substr(line,cmd)
   ind = index(subs," ") - 1		# start vanaf 1, nu dus 0
   sub2 = substr(line,1,cmd + ind)
   sub3 = substr(line,cmd + ind + 1)

   printf("%s%s%s\n",sub2,spc,sub3)
}

#-------------------------------------------
BEGIN {
   n = 0				# teller op nul
   spcs = "                                                      "	# veel!!
}

/^.*UID / {
   head=$0				# sla header op
   cmd=index($0,"CMD") - 1
   next
}

/..*/ {
   n++					# teller (start op 1)
   line[n] = $0				# gehele regel
   pid[n] = $2				# 2e veld = PID
   ppid[n] = $3				# 3e veld = PPID
   tree[$2] = $3			# onthoud parent
   ppids[$3]++				# ppids met zelfde nummer: ++
}

#-------------------------------------------
END {
   printf("%s\n",head)			# print header

   for (i = 1; i <= n; i++)		# zoek vanaf 1e
   {
      s = getstack()

      if (ppid[i] == -1 && s == 0)
	 continue			# al gehad...

	 if (s > 0)
	 {
	    current = i			# zet alvast regelnummer
	    for (j = 1; j <= n; j++)	# zoek regelnr. met deze ppid
	       if (ppid[j] == s)
	       {
		  current = j		# zet regelnummer
		  break			# na 1e gevonden eruit
	       }
	 }
	 else
	    current = i			# zet alvast regelnummer

	 curpid = pid[current]		# startpunt

	 putstack(curpid)		# zet op stack als (nog) niet aanwezig
	 level = getlevel(curpid)	# reken terug

	 printnow(line[current])	# "1e" regel van groep

	 ppids[ppid[current]]--		# geprint, dus geen sub meer
	 ppid[current] = -1		# is geprint

	 do				# loop
	 {
	    found = 0
	    if (ppids[curpid] == 0)
	       break

	    for (j = 1; j <= n; j++)	# start weer op 1e pos
	       if (curpid == ppid[j])	# gevonden ?
	       {
		  curpid = pid[j]	# prep. volgende
		  level = getlevel(curpid)	# reken terug
		  putstack(curpid)	# zet op stack als (nog) niet aanwezig

		  printnow(line[j])	# volg. regel(s) printen

		  ppids[ppid[j]]--	# geprint, dus geen sub meer
		  ppid[j] = -1		# zet op "gehad"
		  found = 1		# blijf zoeken
	       }

	    if (! found)		# na groep lege regel
	       printf("%%%\n")

	 } while (found)		# nodig ivm soms omgek. volgorde
   }
}'

   ps -Af | grep -v "awk ?" | sort +2 -3 -n +1 -2 | awk "$awkscript"
}

######################################################################
######################################################################
# Hauptprogramm mit Aufruf der obigen Funktionen und deren Parametern
######################################################################
#######################  M A I N  ####################################
######################################################################

line
echo "Starting          "$VERSION" on an "$(uname -s)" box"
echo "Path to Cfg2Html  "$0
echo "HTML Output File  "$PWD/$HTML_OUTFILE
echo "Text Output File  "$PWD/$TEXT_OUTFILE
echo "Errors logged to  "$PWD/$ERROR_LOG
echo "Started at        "$DATEFULL
echo "Problem           If Cfg2Html hangs on Hardware, press twice ENTER"
echo "                  or Ctrl-D. Then check or update your Diagnostics!"
echo "WARNING           USE AT YOUR OWN RISK!!! :-))"
echo "License           Freeware"
line

logger "Start of $VERSION"
open_html
inc_heading_level

######################################################################
#	System Information
######################################################################

if [ "$CFG_SYSTEM" = "yes" ]
then
   SNr=$(lscfg -vpl sysplanar0 | grep Machine/Cabinet | awk '{print $2,$3}')
   paragraph "AIX/System - $SNr"
   inc_heading_level

   exec_command "hostname" "Display the name of the current host system"
   if [ "$EXTENDED" = 1 ] ; then
      exec_command "uname -n" "Display the name of the current operating system"
   fi
   exec_command "prtconf" "Print Configuration"
   exec_command "oslevel" "OS Version (Version.Release.Modification.Fix)"
   # exec_command "piet=$(oslevel -r); (( $? = 0 )) && echo \"$piet\" || echo N/a" "HHHHHHHHHHHHHH"
   if [[ "$osrever" > "42" ]]				#  > 4.2.x.x ?
   then
      exec_command "oslevel -r" "OS Maintenance Level"
   else
      exec_command "echo n/a" "OS Maintenance Level" "oslevel -r"
   fi
   # exec_command "oslevel -g" "OS ML higher"	# To determine the filesets at levels later than the current ML
   exec_command "bootinfo -T" "Hardware Platform Type"
   exec_command "bootinfo -p" "Model Architecture"
   exec_command "echo \"$(bootinfo -r) KB / $(echo $(bootinfo -r)/1024 | bc) MB\"" \
      "Memory Size (KBytes/MBytes)" "bootinfo -r"

   if [[ "$osrever" > "42" ]]				#  > 4.2.x.x ?
   then
      exec_command "bootinfo -y" "CPU 32/64 bit"
   else
      exec_command "[[ $(bootinfo -p) = chrp ]] && echo 64 || echo 32" \
	 "CPU 32/64 bit" "'bootinfo -p' == chrp"
   fi
   exec_command "bootinfo -K" "Installed Kernel 32/64 bit"
   exec_command "(( $(bootinfo -z) == 0 )) && echo No || echo Yes" "Multi-Processor Capability" "bootinfo -z"

   # COMMAND: bootinfo -K
   #     Reports whether the system is running a 32-bit or 64-bit KERNEL.
   #     - AIX4.3 has only a 32-bit kernel
   #     - AIX5.1 has both 32-bit and 64-bit kernels. Only one [1]
   #         can be active on a system [or within a LPAR] at a time.
   #
   # COMMAND: bootinfo -y:
   #     Reports whether the CPU is 32-bit or 64-bit.

   # cputype=`getsystype -y`		# alleen 5.x wordt gebruikt door prtconf
   # kerntype=`getsystype -K`		# alleen 5.x

   exec_command "lscfg | grep Implementation | cut -d: -f2 | tr -d ' '" \
      "Model Implementation" "lscfg | grep Implementation"

   exec_command "bootlist -m normal -o" "Boot Device List"
   exec_command "bootinfo -m" "Machine Model Code"
   exec_command "bootinfo -b" "Boot device (booted from)"

   exec_command "echo 'CPU's:' $ANTPROS of type: $(lsattr -El proc0 | \
      grep type | awk '{print $2}')" "CPU's" "lsattr -El proc0 | grep type"

   piet=$(lsattr -El proc0 -a frequency -F value)
   exec_command "echo $(expr ${piet:-1} / 1000000) MHz" "CPU's Speed" "lsattr -El proc0 | grep freq"

   exec_command "lsrset -av" "Display System Rset Contents"
   exec_command "pmctrl -v" "Display Power Management Information"

   exec_command "w; sar" "Uptime, Who, Load & Sar Cpu"
   # exec_command "sar -b 1 9" "Buffer Activity"		# sar -b ????	# TODO??
   exec_command "sar -b" "Sar: Buffer Activity"

   exec_command "vmstat" "Display Summary of Statistics since boot"
   exec_command "vmstat -f" "Display Fork statistics"
   exec_command "vmstat -i" "Displays the number of Interrupts"
   exec_command "vmstat -s" "List Sum of paging events"

   exec_command "iostat" "Report CPU and I/O statistics"

   exec_command "lspath" "Display the status of MultiPath I/O (MPIO) capable devices"
   exec_command "locktrace -l" "List Kernel Lock Tracing current Status"

   dec_heading_level
fi	# terminates CFG_SYSTEM wrapper

###########################################################################
#	Kernel Information
###########################################################################

if [ "$CFG_KERNEL" = "yes" ]
then
   paragraph "Kernel"
   inc_heading_level

   if [ "$EXTENDED" = 1 ] ; then
      exec_command "genkex" "Loaded Kernel Modules"
   fi

   if [ -x /usr/samples/kernel/vmtune ] ; then
      exec_command "/usr/samples/kernel/vmtune" \
	 "Virtual Memory Manager Tunable Parameters"
   fi

   exec_command "lssrc -a" "List current status of all defined subsystems"
   exec_command "chcod" "List Capacity upgrade On Demand values"
   exec_command "lsvpd -v" "List Vital Product Data"
   exec_command "lsrsrc" "List Resources"

   if [ "$EXTENDED" = 1 ] ; then
      exec_command "ps -lAf" "List Processes (extended)"	# helaas, geen -H (XPG4)
   else
      exec_command "ps -Af" "List Processes"		# helaas, geen -H (XPG4) a la HP...
   fi
   exec_command "psawk" "List Processes hierarchically" "ps -Af | awk '{...}'"	# dan maar zo...

   dec_heading_level
fi	# terminates CFG_KERNEL wrapper

######################################################################
#	Hardware Information
###########################################################################

if [ "$CFG_HARDWARE" = "yes" ]
then
   paragraph "Hardware"
   inc_heading_level

   exec_command "lscfg" "Hardware Configuration"
   exec_command "lscfg -pv" "Hardware Configuration (extended)"
   exec_command "lsdev -C | while read i j; \
      do lsresource -l \$i | grep -v \"no bus resource\"; done" \
	 "Display Bus Resources for available Devices" "lsresource -l <Name>"

   dec_heading_level
fi	# terminates CFG_HARDWARE wrapper

######################################################################
#	Filesystem Information
###########################################################################

if [ "$CFG_FILESYS" = "yes" ]
then
   paragraph "Filesystems, Dump- and Paging-configuration"
   inc_heading_level

   exec_command "lsfs -l" "List Filesystems"
   exec_command "lsfs -q" "List Filesystems (extended)"
   exec_command "mount" "Mounted Filesystems"
   exec_command "df -vk" "Filesystems and Usage"
   exec_command bdf_collect "Total Used Local Diskspace" "df -Pk | count \$2, \$3, \$4"

   # lsfs -l | xargs lsattr -El <lv>	# bijv. lsattr -El hd3, better getlvcb, same info...

   if [ "$EXTENDED" = 1 ] ; then
      exec_command "lspv | awk '{print \$1}' | while read i; \
	 do echo \"Physical Volume: \$i\"; lqueryvg -At -p \$i; echo \$SEP; done | uniq | sed '\$d'" \
	    "Query Physical Volumes" "lqueryvg -At -p <pvol>"

      # output=$(lsfs | grep '^/' | awk '{print $1}' | cut -d/ -f3 | while read i
      output=$(lsvg -l $(lsvg -o) | grep -v 'LV NAME' | grep -v '.*:' | \
	 awk '{print $1}' | while read i
      do
	 echo "Logical Volume: $i"
	 getlvcb -AT $i | sed 's/^[ ]*	/ -/g' | grep -v '^ $'
	 echo $SEP
      done)
      exec_command "echo \"\$output\" | uniq | sed '\$d'" "Get Logical Volume Control Block" "getlvcb -AT <lvol>"
   fi

   exec_command "exportfs" "Exported NFS Filesystems"			# TODO juiste text?
   exec_command "lsnfsexp" "Exported NFS Filesystems"	# TODO juiste text? (zelfde als exportfs)
   # exec_command "nfsstat -m" "Mounted Exported NFS Filesystems"	# TODO opties???
   exec_command "lsnfsmnt" "Mounted Exported NFS Filesystems"	# TODO hoe listen van bij MIJ gemounte fs?

   exec_command "lsps -a" "Paging"
   exec_command "vmstat -s" "Kernel paging events"
   exec_command "sysdumpdev -l 2>&1" "List current value of dump devices" "sysdumpdev -l"
   exec_command "/usr/lib/ras/dumpcheck -p" "Check dump resources"
   exec_command "sysdumpdev -L 2>&1" "Most recent system dump" "sysdumpdev -L"

   exec_command "printf '%-10s %s %2s %s %-14s %s\n' IDENTIFIER DATE/TIMESTAMP T C RESOURCE_NAME DESCRIPTION; \
      errpt | tail +2 | awk '{printf \"%-10s %s-%s-%s %s:%s %2s %s %-14s %s %s %s %s %s %s %s %s %s %s\n\",
	 \$1, substr(\$2,3,2), substr(\$2,1,2), substr(\$2,9,2), substr(\$2,5,2), substr(\$2,7,2),
	 \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13, \$14, \$15}'" "Error Report" "errpt | awk {...}"

   dec_heading_level
fi	# terminates CFG_FILESYS wrapper

###########################################################################
#	Device Information
###########################################################################

if [ "$CFG_DISKS" = "yes" ]
then
   paragraph "Devices"
   inc_heading_level

   exec_command "lsdev -C -H -S a" "Available Physical Devices"
   exec_command "lsdev -C -H -S d" "Defined Physical Devices"

   if [ "$EXTENDED" = 1 ] ; then
      exec_command "lsdev -C | sort" "All Physical Devices"		# ??
      exec_command "lsdev -P -H" "Predefined Physical Devices"		# ??
      # exec_command "lsdev -C -H" "Customized Physical Devices"	# ????

      paragraph "Devices by Class"
      inc_heading_level
      for CLASS in $(lsdev -Pr class) ; do
	 exec_command "lsdev -Cc $CLASS" "Devices of Class: $CLASS"
      done
      dec_heading_level

      paragraph "Device Attributes"
      inc_heading_level
      for DEV in $(lsdev -C | awk '{print $1}') ; do
	 exec_command "lsattr -EHl $DEV" "Attributes of Device: $DEV"
      done
      dec_heading_level
   fi

   exec_command "lspv" "Physical Volumes"
   exec_command "lspv | awk '{print $1}' | while read hd ; \
      do lspv \$hd; echo \$SEP; done | uniq | sed '\$d'" "Physical Volumes per Volume Group" "lspv <hdisk>"

   exec_command "lspv | awk '{print $1}' | while read hd ; \
      do lspv -p \$hd; echo \$SEP; done | uniq | sed '\$d'" "Layout Physical Volumes" "lspv -p <hdisk>"

   # [AIX433] /tmp # getlvodm -w
   # getlvodm: A flag requires a parameter: w
   # Usage: getlvodm [-a LVdescript] [-B LVdesrcript] [-b LVid] [-c LVid]
   #         [-C] [-d VGdescript] [-e LVid] [-F] [-g PVid] [-h] [-j PVdescript]
   #         [-k] [-L VGdescript] [-l LVdescript] [-m LVid] [-p PVdescript]
   #         [-r LVid] [-s VGdescript] [-t VGid] [-u VGdescript] [-v VGdescript]
   #         [-w VGid] [-y LVid] [-G LVdescript]
   # [AIX433] /tmp #

   # getlvodm -C ( == +/- lspv)					# TODO
   # getlvodm -u | -d | -v | -L <vg>				# TODO

   lsvg | while read vg
   do
      lvs=$(\
	 lsvg -l $vg | egrep -v ':$|^LV' | awk '{print $1}' | while read lv
	 do
	    lslv -l $lv
	    echo $SEP
	 done)
      exec_command "echo \"\$lvs\" | uniq | sed '\$d'" "List Volume Distribution: $vg" "lslv -l <lvol>"
   done
#----
   h2p=$(\
      for i in $(lsdev -Csssar -thdisk -Fname)
      do
	 echo $i" ---> "$(ssaxlate -l $i 2>&1)
      done)
   exec_command "echo \"\$h2p\"" "Mapping of hdisk to pdisk" \
      "lsdev -Csssar -thdisk -Fname | ssaxlate -l <dev>"

   p2h=$(\
      for i in $(lsdev -Csssar -cpdisk -Fname)
      do
	 echo $i" ---> "$(ssaxlate -l $i 2>&1)
      done)
   exec_command "echo \"\$p2h\"" "Mapping of pdisk to hdisk" \
      "lsdev -Csssar -cpdisk -Fname | ssaxlate -l <dev>"

   conndata=$(\
      for pdisk in $(lsdev -Csssar -cpdisk -Fname)
      do
	  for adap in $(ssaadap -l $pdisk 2>/dev/null)
	  do
	    ssaconn -l $pdisk -a $adap
	  done
      done)
   exec_command "echo \"\$conndata\"" "SSA Connection Data" \
      "lsdev -Csssar -cpdisk -Fname | ssaadap -l <pdisk>"

#   conndata=$(\
#      for adap in $(lsdev -Ctssa -Fname) $(lsdev -Ctssa160 -Fname)
#      do
# 	for pdisk in $(lsdev -Csssar -cpdisk -Fname)
# 	do
# 	  xssa=$(ssaconn -l $pdisk -a $adap 2>/dev/null )
# 	  if [[ -n $xssa ]]
# 	  then
# 	    Cssa="$Cssa\\n$xssa"
# 	  fi
# 	done
# 	echo "$Cssa" | sort -d +4 -5 +2 -3
# 	unset Cssa
#      done)
#   exec_command "echo \"\$conndata\"" "SSA Connection Data sorted by Link" \
#	"ssaconn -l <pdisk> -a <adapter>"	# TODO ??

   dec_heading_level
fi	# terminates CFG_DISKS wrapper

###########################################################################
#	Logical Volume Manager Information
###########################################################################

if [ "$CFG_LVM" = "yes" ]
then
   paragraph "LVM"
   inc_heading_level

   exec_command "lsvg -o | lsvg -i | sed \"s/^\$/$SEP/\"" "Volume Groups" "lsvg -o | lsvg -i"
   exec_command "lsvg -o | xargs lsvg -p" "Volume Group State"
   exec_command "lsvg | while read i; do \
      lsvg -l \$i; echo \$SEP; done | uniq | sed '\$d'" "Logical Volume Groups" "lsvg -l <vg>"
   exec_command PrtLayout "Print Disk Layout"
   exec_command PrintLVM "List Volume Groups"

   output=$(lsvg | while read vg
   do
      echo --------------------------------
      echo "   Volume Group: $vg"
      echo --------------------------------
      lsvg -l $vg | egrep -v ":$|^LV" | while read lv rest; do lslv $lv; echo $SEP; done | uniq | sed '$d'
   done)
   exec_command "echo \"\$output\"" "List Logical Volumes" "lslv <lvol>"	# TODO mooier

   if [ "$EXTENDED" = 1 ] ; then
      output=$(lsvg | while read vg
      do
	 echo --------------------------------
	 echo "   Volume Group: $vg"
	 echo --------------------------------
	 lsvg -l $vg | egrep -v ":$|^LV" | while read lv rest; \
	    do lslv -m $lv | head; echo $SEP; done | uniq | sed '$d'
      done)
      exec_command "echo \"\$output\"" "List Logical/Physical Partition number (first 10 lines)" \
	 "lslv -m <lv> | head"

      exec_command "lsvg | while read i; do \
	 lsvg -M \$i; echo \$SEP; done | uniq | sed '\$d'" "List Logical Volume on Physical Volume" "lsvg -M <vg>"
   fi

   dec_heading_level
fi	# terminates CFG_LVM wrapper

###########################################################################
#	User & Group Information
###########################################################################

if [ "$CFG_USERS" = "yes" ]
then
   paragraph "Users & Groups"
   inc_heading_level

   exec_command "printf '%-10s %6s %-s\n' Name Id Home &&
      echo '----------------------' &&
	 lsuser -c -a id home ALL | sed '/^#/d' |
	    awk -F: '{printf \"%-10s %6s %-s\n\", \$1, \$2, \$3}'" \
      "Display User Account Attributes" "lsuser -c -a id home ALL"

   exec_command "printf '%-10s %6s %-6s %-8s %-s\n' Name Id Admin Registry Users &&
      echo '---------------------------------------' &&
	 lsgroup -c ALL | grep -v '^#' |
	    awk -F: '
	       NF==4 {printf \"%-10s %6s %-6s %-8s\n\", \$1, \$2, \$3, \$4}
	       NF==5 {printf \"%-10s %6s %-6s %-8s %-s\n\", \$1, \$2, \$3, \$5, \$4}'" \
      "Display Group Account Attributes" "lsgroup -c ALL"

   exec_command "lsrole -f ALL | grep -v '=$'" "Display role attributes"
   exec_command "tcbck -n ALL" "Lists the security state of the system"

   dec_heading_level
fi	# terminates CFG_USERS wrapper

###########################################################################
#	Network Information
###########################################################################

if [ "$CFG_NETWORK" = "yes" ]
then
   paragraph "Network Settings"
   inc_heading_level

   exec_command "netstat -in" "List of all IP addresses"
   exec_command "ifconfig -a" "Display information about all network interfaces"
   exec_command "no -a" "Display current network attributes in the kernel"
   exec_command "nfso -a" "List Network File System (NFS) network variables"

   exec_command "netstat -r" "List of all routing table entries by name"
   exec_command "netstat -nr" "List of all routing table entries by IP-address"

   if [ "$EXTENDED" = 1 ] ; then
      exec_command "netstat -an" "Show the state of all sockets"
      exec_command "netstat -An" "Show the address of any PCB associated with the sockets"
   fi

   exec_command "netstat -s" "Show statistics for each protocol"
   exec_command "netstat -sr" "Show the routing statistics"
   exec_command "netstat -v" "Show statistics for CDLI-based communications adapters"
   exec_command "netstat -m" "Show statistics recorded by memory management routines"

   # output=$(entstat -d)
   # output=$(tokstat -d)
   # output=$(atmstat -d)
   # if [ $? != 0 ] ; then
   #    exec_command "echo \"\$output\"" "Show Asynchronous Transfer Mode adapters statistics" "XXXstat -d"
   # fi

   exec_command "nfsstat" "Show NFS statistics"

   if [ "$EXTENDED" = 1 ] ; then
      exec_command "rpcinfo" "Display a List of Registered RPC Programs"
   else
      exec_command "rpcinfo -p" "Display a List of Registered RPC Programs"
   fi
   exec_command "rpcinfo -m; echo \$SEP; rpcinfo -s" "Display a List of RPC Statistics" \
      "rpcinfo -m; rpcinfo -s"

   exec_command "lsnamsv -C 2>&1" "DNS Resolver Configuration" "lsnamsv -C"	# = /etc/resolv.conf
   exec_command "namerslv -s" "Display all Name Server Entries"
   exec_command "domainname" "NIS Domain Name"
   exec_command "ypwhich" "NIS Server currently used"
   exec_command "lsclient -l" "NIS Client Configuration"

   if [ "$EXTENDED" = 1 ] ; then
      exec_command "nslookup $(hostname) 2>&1" "Nslookup hostname" "nslookup $(hostname)"
   fi

   exec_command "ipcs" "IPC info"

   dec_heading_level
fi	# terminate CFG_NETWORK wrapper

###########################################################################
#	Printer Information
###########################################################################

if [ "$CFG_PRINTER" = "yes" ]
then
   paragraph "Printers"
   inc_heading_level

   # exec_command "lpstat -s" "Configured printers"	# TODO ?? ( == enq -A)
   exec_command "qchk -W -q" "Default printer"
   exec_command "qchk -W -A" "Printer Status"
   # lsallq / lsque ...

   dec_heading_level
fi	# terminate CFG_PRINTER wrapper

###########################################################################
#	Quota Information
###########################################################################

if [ "$CFG_QUOTA" = "yes" ]
then
   paragraph "Disk Quota"
   inc_heading_level

   exec_command "repquota -a" "Display Disk Quota"

   dec_heading_level
fi	# terminate CFG_QUOTA wrapper

###########################################################################
#	Defragmentation Information
###########################################################################

if [ "$CFG_DEFRAG" = "yes" ]
then
   paragraph "Current Fragmentation State"
   inc_heading_level

   output=""
   if [ "$EXTENDED" = 1 ] ; then
      mount | grep '^ ' | egrep -v "node| /proc " | awk '{print $2}' | while read i
      do
	 output="$output-- Status of $i --\n$(defragfs -r $i)\n$SEP\n"
      done
      exec_command "echo \"\$output\" | uniq | sed '\$d' | sed '\$d'" \
	 "Filesystem Fragmentation status" "defragfs -r <vol>"
   else
      mount | grep '^ ' | egrep -v "node| /proc " | awk '{print $2}' | while read i
      do
	 output="$output-- Status of $i --\n$(defragfs -q $i)\n$SEP\n"
      done
      exec_command "echo \"\$output\" | uniq | sed '\$d' | sed '\$d'" \
	 "Filesystem Fragmentation status" "defragfs -q <vol>"
   fi

   # TODO:
   # defragfs -s: Reports the fragmentation in the file system. This option causes defragfs
   #    to pass through meta data in the file system which may result in degraded performance.

   dec_heading_level
fi	# terminate CFG_DEFRAG wrapper

##########################################################################
#	Cron Information
##########################################################################

if [ "$CFG_CRON" = "yes" ]
then
   paragraph "Cron and At"
   inc_heading_level

   for FILE in cron.allow cron.deny
   do
      if [ -r /var/adm/cron/$FILE ]
      then
	 exec_command "cat /var/adm/cron/$FILE" "/var/adm/cron/$FILE"
      # else
	 # exec_command "echo /var/adm/cron/$FILE not found!" "$FILE"
      fi
   done

   # ls /var/spool/cron/crontabs/* >/dev/null 2>&1
   # if [ $? -eq 0 ]
   # then
      # echo "\n\n<B>Crontab files:</B>" >> $HTML_OUTFILE_TEMP
      # for FILE in /var/spool/cron/crontabs/*
      # do
	 # exec_command "cat $FILE" "Crontab for user '$(basename $FILE)'"
      # done
   # else
      # echo "No crontab files." >> $HTML_OUTFILE_TEMP
   # fi

   exec_command cron_tabs "Crontab for all users" "cat /var/spool/cron/crontabs/* | grep -v '^#'"

   for FILE in at.allow at.deny
   do
      if [ -r /var/adm/cron/$FILE ]
      then
	 exec_command "cat /var/adm/cron/$FILE " "/var/adm/cron/$FILE"
      # else
	 # exec_command "echo No At jobs present" "$FILE"
      fi
   done

   exec_command "at -l" 'AT Scheduler'

   dec_heading_level
fi	# terminate CFG_CRON wrapper

##########################################################################
#	Password & Group Information
###########################################################################

if [ "$CFG_PASSWD" = "yes" ]
then
   paragraph "Password and Group"
   inc_heading_level

   exec_command "cat /etc/passwd | \
      sed 's&:.*:\([-0-9][0-9]*:[-0-9][0-9]*:\)&:x:\1&'" "/etc/passwd" "cat /etc/passwd"	# ?????

   exec_command "pwdck -n ALL 2>&1" "Errors found in authentication" "pwdck -n ALL"
   exec_command "usrck -n ALL 2>&1" "Errors found in passwd" "usrck -n ALL"
   exec_command "cat /etc/group" "/etc/group"
   exec_command "grpck -n ALL 2>&1" "Errors found in group" "grpck -n ALL"

   # sysck -i -Nv	# TODO ??
   # sysck: Checks the inventory information during installation and update procedures.

   dec_heading_level
fi	# terminate CFG_PASSWD wrapper

######################################################################
#	Patch Statistics
######################################################################

if [ "$CFG_SOFTWARE" = "yes" ]
then
   paragraph "Software"
   inc_heading_level

   exec_command "lslpp -l" "Filesets installed"
   exec_command "lslpp -La" "Display all information about Filesets"
   exec_command "lppchk -v 2>&1" "Verify Filesets" "lppchk -v"
   if [ "$EXTENDED" = 1 ] ; then
      # -c Perform a checksum operation on the FileList items and verifies that the
      #    checksum and the file size are consistent with the SWVPD database.
      exec_command "lppchk -c 2>&1" "Check Filesets" "lppchk -c"
      # -l Verify symbolic links for files as specified in the SWVPD database.
      exec_command "lppchk -l 2>&1" "Verify symbolic links (SWVPD database)" "lppchk -l"
      # exec_command "lslpp -wa" "List fileset that owns this file"	# crasht; not enough memory (in eval)
   fi

   # lppchk -f	# TODO ? : Checks that the FileList items are present and the file size matches the SWVPD database.

   dec_heading_level
fi	# terminates CFG_SOFTWARE wrapper

######################################################################
#	Files Statistics
######################################################################

if [ "$CFG_FILES" = "yes" ]
then
   paragraph "Files"
   inc_heading_level

   if [ "$EXTENDED" = 1 ] ; then
      find /etc/rc.d/rc* -type f | while read i
      do
	 exec_command "cat $i" "$i" 
      done
   else
      exec_command "find /etc/rc.d/rc* | xargs ls -ld" "Run Command files in /etc/rc.d"
   fi

   files ()
   {
      ls /etc/aliases
      ls /etc/binld.cnf
      ls /etc/bootptab
      ls /etc/dhcpcd.ini
      ls /etc/dhcprd.cnf
      ls /etc/dhcpsd.cnf
      ls /etc/dlpi.conf
      ls /etc/environment
      ls /etc/ftpusers
      ls /etc/gated.conf
      ls /etc/hostmibd.conf
      ls /etc/hosts
      ls /etc/hosts.equiv
      ls /etc/hosts.lpd
      ls /etc/inetd.conf
      ls /etc/inittab
      ls /etc/mib.defs
      ls /etc/mrouted.conf
      ls /etc/netgroup
      ls /etc/netsvc.conf
      ls /etc/ntp.conf
      ls /etc/oratab
      ls /etc/policyd.conf
      ls /etc/protocols
      ls /etc/pse.conf
      ls /etc/pse_tune.conf
      ls /etc/pxed.cnf
      ls /etc/qconfig
      ls /etc/filesystems
      ls /etc/rc
      ls /etc/rc.adtranz
      ls /etc/rc.bsdnet
      ls /etc/rc.licstart
      ls /etc/rc.net
      ls /etc/rc.net.serial
      ls /etc/rc.oracle
      ls /etc/rc.qos
      ls /etc/rc.shutdown
      ls /etc/rc.tcpip
      ls /etc/resolv.conf
      ls /etc/rsvpd.conf
      ls /etc/sendmail.cf
      ls /etc/services
      ls /etc/slip.hosts
      ls /etc/snmpd.conf
      ls /etc/snmpd.peers
      ls /etc/syslog.conf
      ls /etc/telnet.conf
      ls /etc/xtiso.conf
      ls /opt/ls3/ls3.sh
      ls /usr/tivoli/tsm/client/ba/bin/rc.dsmsched
      ls /usr/tivoli/tsm/server/bin/rc.adsmserv
      # ls /etc/rc2.d/*
      # ls /etc/rc3.d/*
   }

   COUNT=1			# n.u... ??
   for FILE in $(files)
   do
      # exec_command "grep -v '^#' ${FILE} | uniq" "${FILE}"
      exec_command "egrep -v '^#|^[ 	]*$' ${FILE} | uniq" "${FILE}"	# remove comment and empty lines

      COUNT=$(expr $COUNT + 1)
   done

   dec_heading_level
fi	# terminates CFG_FILES wrapper

######################################################################
#	NIM Configuration
######################################################################

if [ "$CFG_NIM" = "yes" ]
then
   paragraph "Network Installation Management (NIM)"
   inc_heading_level

   exec_command "lsnim -l" "Display information about NIM"

   dec_heading_level
fi	# terminates CFG_NIM wrapper

######################################################################
#	LUM License Configuration
######################################################################

if [ "$CFG_LUM" = "yes" ]
then
   paragraph "License Use Manager"
   inc_heading_level

   files ()
   {
      ls /var/ifor/nodelock
      ls /var/ifor/i4ls.ini
      ls /var/ifor/i4ls.rc
      ls /etc/ncs/glb_site.txt
      ls /etc/ncs/glb_obj.txt
   }

   for FILE in $(files)
   do
      exec_command "cat ${FILE}" "${FILE}"
   done

   /var/ifor/i4cfg -list | grep -q 'active'
   rc=$?
   if (( $rc == 0 ))
   then
      exec_command "/var/ifor/i4blt -ll -n $(uname -n)" "Installed Floating Licenses"
      exec_command "/var/ifor/i4blt -s -n $(uname -n)" "Status of Floating Licenses"
   fi

   exec_command "inulag -lc" "License Agreements Manager"
   exec_command "lslicense" "Display fixed and floating Licenses"

   dec_heading_level
fi	# terminates CFG_LUM wrapper

######################################################################
######################################################################

dec_heading_level
close_html

###########################################################################

logger "End of $VERSION"
echo "\n"
line

rm -f core > /dev/null

########## remove the error.log if it has size zero #######################

[ ! -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null

if [ "$1" != "-x" ]
then
   exit 0
fi

