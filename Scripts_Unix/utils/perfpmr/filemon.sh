#!/bin/ksh
# @(#)78        1.4     src/bos/usr/sbin/perf/pmr/filemon.sh, perfpmr, bos411, 9428A410j 4/14/94 10:08:01
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
# filemon.sh
#
# invoke RISC System/6000 filemon command and generate file system report
#
export LANG=C

if [ $# -ne 1 ]; then
 echo "filemon.sh: usage: filemon.sh time"
 echo "       time is total time in seconds to be traced."
 exit 1
fi

# exit if filemon executable is not installed
if [ ! -f /usr/bin/filemon ]; then
  echo "     FILEMON: /usr/bin/filemon command is not installed"
  echo "     FILEMON:   This command is part of the optional"
  echo "                'bos.perf.tools' fileset."
  exit 1
fi

echo "\n\n\n        F  I  L  E  M  O  N    O  U  T  P  U  T    R  E  P  O  R  T\n" > filemon.sum
echo "\n\nHostname:  "  `hostname -s` >> filemon.sum
echo "\n\nTime before run:  " `date` >> filemon.sum
echo "Duration of run:  $1 seconds"  >> filemon.sum

echo "\n     FILEMON: Starting filesystem monitor for $1 seconds...."
filemon -d -T 512000 -O all -uv >> filemon.sum
trap 'kill -9 $!' 1 2 3 24
trcon
echo "     FILEMON: tracing started"
sleep $1 &
wait
nice --20 trcstop
echo "     FILEMON: tracing stopped"

#echo "Time after run :  " `date` "\n\n\n" >> filemon.sum
echo "     FILEMON: Generating report...."

# wait until filemon has closed the output file
ps -fu root | grep ' filemon ' | grep -v grep > /dev/null
while [ $? = 0 ]; do
  sleep 5
  ps -fu root | grep ' filemon ' | grep -v grep > /dev/null
done

echo "\c     FILEMON: Report is in filemon.sum"
