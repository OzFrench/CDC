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
# vmstat.sh
#
# invoke vmstat before/during/after measurement period and generate reports
#
export LANG=C

if [ $# -ne 1 ]; then
 echo "vmstat.sh: usage: vmstat.sh time"
 echo "      time is total time in seconds to be measured."
 exit 1
fi

# exit if vmstat executable is not installed
if [ ! -f /usr/bin/vmstat ]; then
  echo "     VMSTAT: /usr/bin/vmstat command is not installed"
  echo "     VMSTAT:   This command is part of the 'bos.acct' fileset."
  exit 1
fi

# check total time specified for minimum amount of 60 seconds
if [ $1 -lt 60 ]; then
 echo Minimum time interval required is 60 seconds
 exit -1
fi

# determine INTERVAL and COUNT
if [ $1 -lt 601 ]; then
 INTERVAL=10
 let COUNT=$1/10
else
 INTERVAL=60
 let COUNT=$1/60
fi

# need count+1 intervals for VMSTAT
let COUNT=COUNT+1

echo "\n\n\n       V M S T A T    I N T E R V A L    O U T P U T   (vmstat $INTERVAL $COUNT)\n" > vmstat.int
echo "\n\n\n        V  M  S  T  A  T    S  U  M  M  A  R  Y    O  U  T  P  U  T\n\n\n" > vmstat.sum
echo "\n\nHostname:    `hostname -s`" >> vmstat.int
echo "\n\nHostname:    `hostname -s`" >> vmstat.sum
echo "\n\nTime before run:   `date` ">> vmstat.int
echo "\n\nTime before run:   `date` ">> vmstat.sum

echo "\n     VMSTAT: Saving VMSTAT statistics before run...."
vmstat -s > vmstat.tot

echo "     VMSTAT: Starting Virtual Memory Statistics Collector [VMSTAT]...."
trap 'kill -9 $!' 1 2 3 24
vmstat  $INTERVAL $COUNT > vmstat.tmp &

# wait required interval
echo "     VMSTAT: Waiting for measurement period to end...."
wait

# save time after run
echo "\n\nTime after run :   `date`" >> vmstat.int
echo "\n\nTime after run :   `date`" >> vmstat.sum
echo "     VMSTAT: Saving VMSTAT statistics after run...."
vmstat -s >> vmstat.tot

echo "     VMSTAT: Generating reports...."

# put awk script in temp file for later use with periodic vmstat output
/usr/bin/cat <<EOF > vmstat.awk
BEGIN {
 # SUM="vmsum.file";
}

{
   if(\$2 == "memory") { # next rec is underlines
      state = 1;
      next;
   }
   if(state == 1) { # underlines
      state = 2;
      next;
   }

   if(state == 2) { # header
      state = 3;
      vmhdr = \$0; # save vm header
      next;
   }

   { # data line
      vmcnt++;
      Fields = NF;
      for(i = 1; i <= NF; i++) {
         sum[i] += \$i;
      }
      next;
   }

}

END {
   for(i = 1; i <= Fields; i++) {
      aver[i] += sum[i] / vmcnt;
   }

   print vmhdr;
   printf("%2d", aver[1]); 
   printf("%3d", aver[2]);

   printf("%3d", aver[3]);

   printf("%6d", aver[4]);
   printf("%6d", aver[5]);

   printf("%4d", aver[6]);

   printf("%4d", aver[7]);
   printf("%4d", aver[8]);
   printf("%4d", aver[9]);
   printf("%4d", aver[10]);
   printf("%5d", aver[11]);
   printf("%4d", aver[12]);
   printf("%5d", aver[13]);
   printf("%4d", aver[14]);
   printf("%3d", aver[15]);
   printf("%3d", aver[16]);
   printf("%3d", aver[17]);
   printf("%3d", aver[18]);
   printf("\n");
}
EOF

# put awk script in temp file for later use with vmstat -s output
/usr/bin/cat <<EOFSUM > vmstat.sumawk
BEGIN {
        sum = 1;
        FS = " ";
}

/address/ && sum == 1 {
        for(i=0;i < 23;i++)
        {
                totals1[i] = \$1;
                getline;
        }
        sum++;
}

sum == 2 {
        # Process second vmstat summary and storing the difference between the
        # two summaries in diffs
        for(i=0;i < 23;i++)
        {
                diffs[i] = \$1 - totals1[i];
                getline;
        }
}

END {
    printf(" %6d total address trans. faults \n",diffs[0]);
    printf(" %6d  page ins\n",diffs[1]);
    printf(" %6d page outs\n",diffs[2]);
    printf(" %6d paging space page ins\n",diffs[3]);
    printf(" %6d paging space page outs\n",diffs[4]);
    printf(" %6d total reclaims\n",diffs[5]);
    printf(" %6d zero filled pages faults\n",diffs[6]);
    printf(" %6d executable filled pages faults\n",diffs[7]);
    printf(" %6d pages examined by clock\n",diffs[8]);
    printf(" %6d revolutions of the clock hand\n",diffs[9]);
    printf(" %6d pages freed by the clock\n",diffs[10]);
    printf(" %6d backtracks\n",diffs[11]);
    printf(" %6d lock misses\n",diffs[12]);
    printf(" %6d free frame waits\n",diffs[13]);
    printf(" %6d extend XPT waits\n",diffs[14]);
    printf(" %6d pending I/O waits\n",diffs[15]);
    printf(" %6d start I/Os\n",diffs[16]);
    printf(" %6d iodones\n",diffs[17]);
    printf(" %6d cpu context switches\n",diffs[18]);
    printf(" %6d device interrupts\n",diffs[19]);
    printf(" %6d software interrupts\n",diffs[20]);
    printf(" %6d traps\n",diffs[21]);
    printf(" %6d syscalls\n",diffs[22]);
}
EOFSUM


# get rid of first vmstat report [record #4] that shows stats since ipl from interval data
/usr/bin/sed -e "4d" vmstat.tmp > vmstat2.tmp; /usr/bin/mv vmstat2.tmp vmstat.tmp
echo "\n\n\n" >> vmstat.int
/usr/bin/cat vmstat.tmp >> vmstat.int

# generate summary report from interval data
echo "\n\n\n        V  M  S  T  A  T    I  N  T  E  R  V  A  L    A  V  E  R  A  G  E  S\n\n\n" >> vmstat.sum
/usr/bin/awk -f vmstat.awk vmstat.tmp >> vmstat.sum

# generate summary report from vmstat -s data
echo "\n\n\n        V  M  S  T  A  T    -s         'D  E  L  T  A  S'\n\n\n" >> vmstat.sum
/usr/bin/awk -f vmstat.sumawk vmstat.tot >> vmstat.sum

/usr/bin/rm  vmstat.tot vmstat.sumawk vmstat.awk vmstat.tmp

echo "     VMSTAT: Interval report is in file vmstat.int"
echo "     VMSTAT: Summary report is in file vmstat.sum"
