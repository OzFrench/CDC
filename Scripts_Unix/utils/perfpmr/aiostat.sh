#!/bin/ksh
#
# COMPONENT_NAME: perfpmr
#
# FUNCTIONS: none
#
# ORIGINS: 27
#
# (C) COPYRIGHT International Business Machines Corp.  2000
# All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# aiostat.sh
#
# invoke iostat for specified interval and create interval and summary reports
#
export LANG=C

if [ $# -ne 1 ]; then
 echo "aiostat.sh: usage: aiostat.sh time"
 echo "      time is total time in seconds to be measured."
 exit 1
fi


# determine interval and count
if [ $1 -lt 601 ]; then
 INTERVAL=10
 let COUNT=$1/10
else
 INTERVAL=60
 let COUNT=$1/60
fi

# need count+1 intervals for IOSTAT
let COUNT=COUNT+1

echo "\n\n\n     A I O S T A T    I N T E R V A L    O U T P U T   (aiostat $INTERVAL $COUNT)\n" > aiostat.int
echo "\n\nHostname:  "  `hostname -s` >> aiostat.int
echo "\n\nTime before run:  " `date` >> aiostat.int

trap 'kill -9 $!' 1 2 3 24
echo "\n     AIOSTAT: Starting AIO Statistics Collector [AIOSTAT]...."
if whence aiostat >/dev/null; then
  aiostatexe=aiostat
else  
  aiostatexe=$PERFPMRDIR/aiostat
fi
$aiostatexe >/dev/null 2>&1
if [ $? != 0 ]; then
	echo "aiostat failed - AIO may not be enabled" >> aiostat.int
 	exit 0
fi
$aiostatexe -t 10000  $INTERVAL $COUNT >> aiostat.int &


# wait required interval
echo "     AIOSTAT: Waiting for measurement period to end...."
wait

# save time after run
echo "\n\nTime after run :  " `date` >> aiostat.int
echo "     AIOSTAT: Interval report is in file aiostat.int"
