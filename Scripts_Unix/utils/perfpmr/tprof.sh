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
# tprof.sh
#
# invoke tprof to collect data for specified interval and again to produce report
#
export LANG=C

if [ $# -eq 0 ]
then
 echo "tprof.sh: usage: tprof.sh [-p program] time"
 echo "          time is total time to measure"
 echo "          -p program is optional executable to be profiled,"
 echo "          which, if specified, must reside in current directory"
 exit -1
fi

# exit if tprof executable is not installed
if [ ! -x /usr/bin/tprof ]
then
  echo "     TPROF: /usr/bin/tprof command is not installed"
  echo "     TPROF:   This command is part of the optional"
  echo "                'perfagent.tools' fileset."
  exit 1
fi

# see if optional application program in current directory specified
case $1 in
  -p)  PGM=$2
       shift
       shift;;
   *)  PGM=tprof;;
esac

# collect raw data
echo "\n     TPROF: Starting tprof for $1 seconds...."
tprof -x sleep $1 > /dev/null 2>&1
echo "     TPROF: Sample data collected...."

# get gennames output if needed (not present or older than .init.state)
if [ "$GETGENNAMES" != 0 ]; then
  if [ ! -f gennames.out -o gennames.out -ot /etc/.init.state ]; then
    echo "     TPROF: collecting gennames data"
    if [ "$GETGENNAMESF" = 1 ]; then
      gennames -f >gennames.out  2>&1
    else
      gennames >gennames.out  2>&1
    fi
  fi
fi

# reduce data
echo "     TPROF: Generating reports in background (renice -n 20)"
PID=$$
renice -n 20 -p $PID

if [ $PGM = "tprof" ]
then
 tprof  -k -s -e > /dev/null 2>&1
else
 tprof  -p $PGM -k -s -e > /dev/null 2>&1
fi

# save final output as $PGM.sum
if [ $PGM = "tprof" ]
then
  if [ -f prof.all ]
  then
    mv prof.all $PGM.sum
  else
    mv __prof.all $PGM.sum
  fi
else
  if [ -f $PGM.all ]
  then
    mv $PGM.all $PGM.sum
  else
    mv __$PGM.all $PGM.sum
  fi
fi

# final cleanup
rm stripnm.* lib.all tlib.all > /dev/null 2>&1
echo "     TPROF: Tprof report is in $PGM.sum"
