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
# monitor.sh
#
# invoke system performance monitors and collect interval and summary reports
#

show_usage()
{
 echo  "monitor.sh: usage: monitor.sh [-n] [-p] [-s] time"
 echo  "      -n used if no netstat or nfsstat desired."
 echo  "      -p used if no pprof desired."
 echo  "      -s used if no svmon desired."
 echo  "      time is total time in seconds to be measured."
 exit 1
}

function lsps_as
{
echo "Date/Time:  " `date`
echo "\n"
echo "lsps -a"
echo "-------"
lsps -a

echo "\n\n"
echo "lsps -s"
echo "-------"
lsps -s
}


function vmstat_i
{
echo "Date/Time:  " `date`
echo "\n"
echo "vmstat -i"
echo "---------"
vmstat -i
}

function vmtune_a
{
echo "Date/Time:  " `date`
echo "\n"
echo "vmtune -a"
echo "---------"
/usr/samples/kernel/vmtune -a  2>&1
}

#--------------------------------------------------------
# MAIN
#--------------------------------------------------------
PERFPMRDIR=`whence $0`
PERFPMRDIR=`/usr/bin/ls -l $PERFPMRDIR |/usr/bin/awk '{print $NF}'`
PERFPMRDIR=`/usr/bin/dirname $PERFPMRDIR`


export LANG=C

if [ $# -eq 0 ]; then
        show_usage
fi

NET=1
PROF=1
SVMON=1
while getopts nps flag ; do
        case $flag in
                n)     NET=0;;
                p)     PROF=0;;
                s)     SVMON=0;;
                \?)    show_usage
        esac
done
shift OPTIND-1
SLEEP=$@

# check total time specified for minimum amount of 60 seconds
if [ $SLEEP -lt 60 ]; then
 echo Minimum time interval required is 60 seconds
 exit 1
fi


if [ $SVMON = 1 ]; then
  echo "\n     MONITOR: Capturing initial lsps, svmon, and vmstat data"
else
  echo "\n     MONITOR: Capturing initial lsps and vmstat data"
fi

# pick up lsps output at start of interval
lsps_as > lsps.before

# pick up vmstat -i at start of interval
vmstat_i > vmstati.before

# pick up vmtune -a at start of interval
vmtune_a > vmtunea.before

# pick up svmon output at start of interval
# skip if svmon executable is not installed
# or if -s flag was specified
if [ ! -f /usr/bin/svmon ]; then
  echo "     MONITOR: /usr/bin/svmon command is not installed"
  echo "     MONITOR: This command is part of the optional"
  echo "              'perfagent.tools' fileset."
else
  if [ $SVMON = 1 ]; then
    $PERFPMRDIR/svmon.sh -o svmon.before
  fi
fi

echo "     MONITOR: Starting system monitors for $SLEEP seconds."

# skip nfsstat and netstat if -n flag used
if [ $NET = 1 ]; then
 if [ -x /usr/sbin/nfsstat ]; then
  $PERFPMRDIR/nfsstat.sh $SLEEP > /dev/null &
 fi
 $PERFPMRDIR/netstat.sh $SLEEP > /dev/null &
fi

$PERFPMRDIR/ps.sh $SLEEP > /dev/null &

$PERFPMRDIR/vmstat.sh $SLEEP > /dev/null &

$PERFPMRDIR/emstat.sh $SLEEP > /dev/null &

$PERFPMRDIR/sar.sh $SLEEP > /dev/null &

$PERFPMRDIR/iostat.sh $SLEEP > /dev/null &

$PERFPMRDIR/aiostat.sh $SLEEP > /dev/null &


if [ $PROF = 1 ]; then
  # Give some time for above processes to startup and stabilize
  sleep 5
  $PERFPMRDIR/pprof.sh $SLEEP > /dev/null &
fi

# wait until all child processes finish
echo "     MONITOR: Waiting for measurement period to end...."
trap 'echo MONITOR: Stopping...but data collection continues.; exit -2' 1 2 3 24
sleep $SLEEP &
wait

if [ $SVMON = 1 ]; then
  echo "\n     MONITOR: Capturing final lsps, svmon, and vmstat data"
else
  echo "\n     MONITOR: Capturing final lsps and vmstat data"
fi

# pick up lsps output at end of interval
lsps_as > lsps.after

# pick up vmstat -i at end of interval
vmstat_i > vmstati.after

# pick up vmtune -a at end of interval
vmtune_a > vmtunea.after

# pick up svmon output at end of interval
# skip if svmon executable is not installed
# or if -s flag was specified
if [ -f /usr/bin/svmon -a $SVMON = 1 ]; then
  $PERFPMRDIR/svmon.sh  -o svmon.after
fi

echo "     MONITOR: Generating reports...."

# collect all reports into two grand reports

echo "Interval File for System + Application\n" > monitor.int
echo "Summary File for System + Application\n" > monitor.sum

/usr/bin/cat ps.int >> monitor.int
/usr/bin/cat ps.sum >> monitor.sum
/usr/bin/rm ps.int ps.sum

echo "\f" >> monitor.int
/usr/bin/cat sar.int >> monitor.int
echo "\f" >> monitor.sum
/usr/bin/cat sar.sum >> monitor.sum
/usr/bin/rm sar.int sar.sum

echo "\f" >> monitor.int
/usr/bin/cat iostat.int >> monitor.int
echo "\f" >> monitor.sum
/usr/bin/cat iostat.sum >> monitor.sum
/usr/bin/rm iostat.int iostat.sum

echo "\f" >> monitor.int
cat vmstat.int >> monitor.int
echo "\f" >> monitor.sum
/usr/bin/cat vmstat.sum >> monitor.sum
/usr/bin/rm vmstat.int vmstat.sum

#echo "\f" >> monitor.int
#/usr/bin/cat emstat.int >> monitor.int
#/usr/bin/rm emstat.int

echo "\f" >> monitor.int
/usr/bin/cat aiostat.int >> monitor.int
/usr/bin/rm aiostat.int

# skip nfsstat and netstat if -n flag used
if [ $NET = 1 ]; then
 if [ -x /usr/sbin/nfsstat ]; then
  echo "     MONITOR: Network reports are in netstat.int and nfsstat.int"
 else
  echo "     MONITOR: Network report is in netstat.int"
 fi
fi

echo "     MONITOR: Monitor reports are in monitor.int and monitor.sum"
