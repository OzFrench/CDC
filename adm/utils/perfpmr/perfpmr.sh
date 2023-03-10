#!/bin/ksh
#
# COMPONENT_NAME: perfpmr
#
# FUNCTIONS: none
#
# ORIGINS: IBM
#
# (C) COPYRIGHT International Business Machines Corp.  2000,2001,2002,2003
# All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# perfpmr.sh
#
# collect standard performance data needed for AIX performance pmr
#

#-----------------------------
# Name: show_usage
#-----------------------------
show_usage()
{
  echo "Version: $PERFPMRVER"
  echo "\nperfpmr.sh: Usage: \n"
  echo "  perfpmr.sh [-PDgfnpsc][-F file][-x file][-d sec] monitor_seconds"
  echo "  -P preview only - show scripts to run and disk space needed"
  echo "  -D run perfpmr the original way without a perfpmr cfg file"
  echo "  -g do not collect gennames output."
  echo "  -f if gennames is run, specify gennames -f."
  echo "  -n used if no netstat or nfsstat desired."
  echo "  -p used if no pprof collection desired while monitor.sh running."
  echo "  -s used if no svmon desired."
  echo "  -c used if no configuration information is desired."
  echo "  -F file   use file as the perfpmr cfg file - default is perfpmr.cfg"
  echo "  -x file   only execute file found in perfpmr installation directory"
  echo "  -d sec  sec is time to wait before starting collection period"
  echo "                default is delay_seconds 0"
  echo "  monitor_seconds is for the the monitor collection period in seconds"

  echo "\nUse 'perfpmr.sh 600' for standard collection period of 600 seconds"
  exit 1
}

#-----------------------------
# Name: perfpmr_trace
#-----------------------------
perfpmr_trace()
{

if [ "$1" != "getargs" ]; then
	if [ "$traceexists" = "true" ]; then
   	echo "WARNING: A trace process is already running."
   	echo "         perfpmr will not gather information using trace."
   	echo "         Stop the trace process (trcstop) and rerun perfpmr"
   	echo "         to collect a complete set of standard system"
   	echo "         performance data.\n"
	return
	fi

	$PERFPMRDIR/trace.sh $@ | $TEEOUT
	return
fi
shift
/usr/bin/awk '
BEGIN {
}
/^trace.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "inhooks" && temp[3] != "")
				inhooks= "-j " temp[3]
		if (temp[1] == "exhooks" && temp[3] != "")
				exhooks= "-k " temp[3]
		if (temp[1] == "logsize" && temp[3] != "")
		{
			logsize= "-L " temp[3]
			logbytes= temp[3]
		}
		if (temp[1] == "kbufsize")
			kbufsize= "-T " temp[3]
		if (temp[1] == "interactive_trace")
		{
			if (temp[3] == "true")
				itrc= "-i"
			else
				itrc= ""
		}
		if (temp[1] == "loop_tracing")
		{
			if (temp[3] == "true")
				looptrc= "-l"
			else
				looptrc= ""
		}
		if (temp[1] == "run_gennames")
		{
			if (temp[3] == "false")
				run_gennames= "-g"
			else
				run_gennames= ""
		}
		if (temp[1] == "get_inode_table")
		{
			if (temp[3] == "true")
				get_inode_tbl= ""
			else
				get_inode_tbl= "-N"
		}
		if (temp[1] == "per_cpu_trc")
		{
			if (temp[3] == "true" )
				per_cpu_trc= ""
			else
				per_cpu_trc= "-C"
		}
		if (temp[1] == "num_traces_to_run" && temp[3] != "" )
		{
			num_traces= "-n " temp[3]
			n_traces=  temp[3]
		}
		if (temp[1] == "delay_seconds" && temp[3] != "" )
			delay_seconds= "-s " temp[3]
		if (temp[1] == "trace_time_seconds" )
			trace_time= temp[3]
		if (temp[1] == "space_required" )
			space= temp[3]
                if (temp[1] == "loop_trace_stop_file" && temp[3] != "" )
                        stop_trigger_file= "-f " temp[3]
	}
  }
END {

	if ( space == "" )
	{
		if ( per_cpu_trc != "-C" )
		{
			"$PERFPMRDIR/lsc -c" | getline ncpus
			close("$PERFPMRDIR/lsc -c");
			space= logbytes * ncpus
			if ( num_traces != "" )
				space= space * n_traces
		}
		else {
			space= logbytes
			if ( num_traces != "" )
				space= space * n_traces
		}
	}
	if ( trace_time == "" )
			trace_time= default_time

	printf("%s perfpmr_trace %s %s %s %s %s %s %s %s %s %s %s %s %s\n",
		space, inhooks,exhooks,logsize,kbufsize,
		itrc,looptrc,run_gennames,get_inode_tbl,per_cpu_trc,
		num_traces, delay_seconds, stop_trigger_file, trace_time);

} ' default_time=$default_time_trace $PERFPMRCFG
}  



#-----------------------------
# Name: perfpmr_config
#-----------------------------
perfpmr_config()
{
if [ "$1" != "getargs" ]; then
	if [  -z "$NO_CONFIG" ]; then
	    $PERFPMRDIR/config.sh $@ | $TEEOUT
	fi
	return
fi

shift
awk  '
BEGIN {
}
/^config.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "run_lsattr_all_devs" )
		{
			if (temp[3] == "false" )
				run_lsattr_all= "-a"
		}
		if (temp[1] == "run_gennames" )
		{
			if (temp[3] == "false" )
				run_gennames= "-g"
		}
		if (temp[1] == "detailed_LV_info" )
		{
			if (temp[3] == "false" )
				detailedLV= "-l"
		}
		if (temp[1] == "run_lspv_alldisks" )
		{
			if (temp[3] == "false" )
				runlspvall= "-p"
		}
		if (temp[1] == "get_ssa_cfg" )
		{
			if (temp[3] == "false" )
				getssacfg= "-s"
		}
		if (temp[1] == "space_required" )
			space= temp[3]
	}
 }
END {
	if ( space == "" )
		space= 2000000
	printf("%s perfpmr_config %s %s %s %s %s \n", space,
		run_lsattr_all,run_gennames,detailedLV, runlspvall, getssacfg);
} ' $PERFPMRCFG
}  


#-----------------------------
# Name: perfpmr_filemon
#-----------------------------
perfpmr_filemon()
{
if [ "$1" != "getargs" ]; then
	if [ "$traceexists" = "true" ]; then
		echo "WARNING: no filemon data will be collected since trace process was detected"
		return
	fi
	if whence filemon >/dev/null; then
		$PERFPMRDIR/filemon.sh $@ 2>/dev/null| $TEEOUT
	fi
	return
fi

shift
awk  '
BEGIN {
}
/^filemon.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "filemon_time_seconds" && temp[3] != "")
			filemon_time_secs = temp[3]
		if (temp[1] == "space_required" )
			space= temp[3]
	}
   }
END {
	if ( space == "" )
		space= 1000000
	if ( filemon_time_secs  == "" )
			filemon_time_secs= default_time
	printf("%s perfpmr_filemon %s\n", space, filemon_time_secs);
} ' default_time=$default_time_filemon $PERFPMRCFG
}  


#-----------------------------
# Name: perfpmr_netpmon
#-----------------------------
perfpmr_netpmon()
{
if [ "$1" != "getargs" ]; then
	if [ "$traceexists" = "true" ]; then
		echo "WARNING: no netpmon data will be collected since trace process was detected"
		return
	fi
	if whence netpmon >/dev/null; then
		$PERFPMRDIR/netpmon.sh $@ 2>/dev/null| $TEEOUT
	fi
	return
fi

shift
awk  '
BEGIN {
}
/^netpmon.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "netpmon_time_seconds" && temp[3] != "")
			netpmon_time_secs = temp[3]
		if (temp[1] == "space_required" )
			space= temp[3]
	}
   }
END {
	if ( space == "" )
		space= 1000000
	if ( netpmon_time_secs == "" )
		netpmon_time_secs= default_time
	printf("%s perfpmr_netpmon %s\n", space, netpmon_time_secs);
} ' default_time=$default_time_netpmon $PERFPMRCFG
}  


#-----------------------------
# Name: perfpmr_tprof
#-----------------------------
perfpmr_tprof()
{
if [ "$1" != "getargs" ]; then
	if [ "$traceexists" = "true" ]; then
		echo "WARNING: no tprof data will be collected since trace process was detected"
		return
	fi
	if whence tprof >/dev/null; then
		$PERFPMRDIR/tprof.sh $@ 2>/dev/null| $TEEOUT
	fi
	return
fi

shift
awk  '
BEGIN {
}
/^tprof.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "tprof_time_seconds" && temp[3] != "")
				tprof_time_secs= temp[3]
		if (temp[1] == "space_required" )
			space= temp[3]
	}
   }
END {
	if ( space == "" )
		space= 1000000
	if ( tprof_time_secs == "" )
		tprof_time_secs= default_time
	printf("%s perfpmr_tprof %s\n", space, tprof_time_secs);
} '  default_time=$default_time_tprof $PERFPMRCFG
}  


#-----------------------------
# Name: perfpmr_iptrace
#-----------------------------
perfpmr_iptrace()
{
if [ $1 != "getargs" ]; then
	$PERFPMRDIR/iptrace.sh $@ | $TEEOUT
	return
fi
shift
awk  '
BEGIN {
}
/^iptrace.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "iptrace_time_seconds" && temp[3] != "")
			iptrace_time_secs = temp[3]
		if (temp[1] == "space_required" )
			space= temp[3]
	}
   }
END {
	if ( space == "" )
		space= 1000000

	if ( iptrace_time_secs == "" )
		iptrace_time_secs= default_time;

	space= space * iptrace_time_secs

	printf("%s perfpmr_iptrace %s\n", space, iptrace_time_secs);
} ' default_time=$default_time_iptrace $PERFPMRCFG
}


	
#-----------------------------
# Name: perfpmr_tcpdump
#-----------------------------
perfpmr_tcpdump()
{
if [ "$1" != "getargs" ]; then
	if [ "$traceexists" = "true" ]; then
   	echo "WARNING: no tcpdump data will be collected since trace process has been detected"
	return
	fi

	$PERFPMRDIR/tcpdump.sh $@ | $TEEOUT
	return
fi
shift
awk  '
BEGIN {
}
/^tcpdump.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "tcpdump_time_seconds" && temp[3] != "")
			emstat_time_secs = temp[3]
		if (temp[1] == "space_required" )
			space= temp[3]
	}
   }
END {
	if ( space == "" )
		space= 1000000

	if ( tcpdump_time_secs == "" )
		tcpdump_time_secs= default_time;

	space= space * tcpdump_time_secs
	printf("%s perfpmr_tcpdump %s\n", space, tcpdump_time_secs);
} ' default_time=$default_time_tcpdump $PERFPMRCFG
}

#-----------------------------
# Name: perfpmr_monitor
#-----------------------------
perfpmr_monitor()
{
if [ "$1" != "getargs" ]; then
	$PERFPMRDIR/monitor.sh $MONFLAGS $@ | $TEEOUT
	return
fi

shift
awk  '
BEGIN {
}
/^monitor.sh/ {
	while (status=getline >0) 
	{
		if ($0 == "")
			exit;
		split($0,temp)
		if (temp[1] == "run_netstat_nfsstat" )
		{
			if (temp[3] == "false" )
				run_netstatnfsstat= "-n"
		}
		if (temp[1] == "run_pprof" )
		{
			if (temp[3] == "false" )
				run_pprof= "-p"
		}
		if (temp[1] == "run_svmon" )
		{
			if (temp[3] == "false" )
				run_svmon= "-s"
		}
		if (temp[1] == "run_emstat" )
		{
			if (temp[3] == "false" )
				run_emstat= "-e"
		}
		if (temp[1] == "monitor_time_seconds" )
			monitor_time_secs= temp[3]

		if (temp[1] == "space_required" )
			space= temp[3]
	}
 }
END {
	if ( space == "" )
		space= 2000000;

	if ( monitor_time_secs == "" )
		monitor_time_secs= default_time

	printf("%s perfpmr_monitor  %s %s %s %s %s \n", space,
	 run_netstatnfsstat,run_pprof,run_svmon,run_emstat,monitor_time_secs);
} ' default_time=${MONITOR_TIME:-$default_time_monitor} $PERFPMRCFG
}

#-----------------------------
# Name: perfpmr_uptime
#-----------------------------
perfpmr_uptime()
{
if [ $1 != "getargs" ]; then
	echo " Uptime information $1 collection:" >> $PERFPMROUT
	echo " \c" >> $PERFPMROUT
	/usr/bin/uptime >> $PERFPMROUT
	return
else
	if [ -z "$uptimeagain"  ]; then
		echo "80 perfpmr_uptime before"
	else
		echo "80 perfpmr_uptime after"
		uptimeagain=1
	fi
fi
}

#-----------------------------
# Name: perfpmr_w
#-----------------------------
perfpmr_w()
{
if [ "$1" != "getargs" ]; then
	echo "\n\t\tW Command output $1 monitoring session\n\n\n" >> w.int
	/usr/bin/w >> w.int
	return
else
	if [ -z "$wagain"  ]; then
		echo "800 perfpmr_w before"
		> w.int
	else
		echo "800 perfpmr_w after"
		wagain=1
	fi
fi
}

#-----------------------------
# Name: get_other_cmds
#-----------------------------
get_other_cmds()
{
oc_count=0
awk  '
BEGIN {
}
/^perfpmr.sh/ {
        while (status=getline >0)
        {
                if ($0 == "")
                        exit;
                split($0,temp)
                if (temp[1] == "other_command_to_run" && temp[3] !="")
                {
                        sub("other_command_to_run = ", "", $0);
                        print $0
                }
        }
   }
END {
} ' $PERFPMRCFG | while read other_cmd; do
        other_cmds[$oc_count]="$other_cmd"
        let oc_count=oc_count+1
done
}


#-----------------------------
# Name: run_other_cmds
#-----------------------------
run_other_cmds()
{
	arg_other_cmd=$1
	if [ "$oc_count" -gt 0 ]; then
		j=0;
		while [ $j -lt $oc_count ];  do
			if [ "$arg_other_cmd" = "show" ]; then
				echo "\t ${other_cmds[$j]}"
			else
				eval  ${other_cmds[$j]}
			fi
			let j=j+1
		done
	fi
}


#-----------------------------
# Name: get_tools_to_run
#-----------------------------
get_tools_to_run()
{
sc_count=0
awk  '
BEGIN {
}
/^perfpmr.sh/ {
        while (status=getline >0)
        {
                if ($0 == "")
                        exit;
                split($0,temp)
                if (temp[1] == "perfpmr_tool" && temp[3] != "")
                {
                        sub("perfpmr_tool = ", "", $0);
                        print $0
                }
        }
   }
END {
} ' $PERFPMRCFG 

}

#-----------------------------
# Name: check_for_authority
#-----------------------------
check_for_authority()
{
	# check for root id
	/usr/bin/id | grep root  > /dev/null 2>&1 ||
  	{
    		echo "\nperfpmr.sh: Please obtain root authority and rerun this shell script\n"
    		exit 1
  	}
}


#-----------------------------
# Name: get_tools_and_space
#-----------------------------
get_tools_and_space()
{
	toolcount=0
	sumspace=0
	for tool in $@; do
		ptool=${tool%%.sh}; ptool=perfpmr_${ptool}
		if whence $ptool >/dev/null 2>&1; then
			cmd_to_run=`$ptool getargs $PERFPMRCFG`
			set $cmd_to_run
			size[$toolcount]=$1; shift
			cmd[$toolcount]=$@
			shift;scmd[$toolcount]="$tool $@"
#			echo "size=${size[$toolcount]} \c"
#			echo $PERFPMRDIR/${cmd[$toolcount]}
		else
			cmd[$toolcount]=$tool
			scmd[$toolcount]=$tool
			size[$toolcount]=500000
		fi
		let sumspace=sumspace+${size[$toolcount]}
		let toolcount=toolcount+1
	done

	# determine if there is sufficient disk space in the current directory
	freespace=`/usr/bin/df -k .|/usr/bin/tail -1|/usr/bin/awk '{print $3}'`
	let freespace=freespace/1024  # Mbytes free
	let sumspace=sumspace/1048576 # Mbytes needed
	if [ -n "$PREVIEWONLY" ]; then
            echo "PERFPMR: tools located in: $PERFPMRDIR"
	    echo "PERFPMR: tools to be run include:"
	    tc=0
	    while (( $tc < $toolcount )); do
		echo "\t ${scmd[$tc]}"
		let tc=tc+1
	    done
	    # get other cmds	  
	    run_other_cmds show
	
	    echo "PERFPMR: disk space needed is at least :  <$sumspace> Mbytes"
	    echo "PERFPMR: free space in this directory  :  <$freespace> Mbytes"
	    exit 0
	fi

	if [ "$freespace" -lt "$sumspace" ]; then
           echo "\nperfpmr.sh: There may not be enough space in this filesystem"
           echo "perfpmr.sh: Make sure there is at least $sumspace Mbytes"
           exit 1
	fi
}

#-----------------------------
# Name: check_lpp_reqs
#-----------------------------
check_lpp_reqs()
{
  EXIT_YORN=0
  LPPOUT=lslpp.l.out
  /usr/bin/lslpp -l > $LPPOUT
  bosfilesets="bos.acct bos.sysmgt.trace perfagent.tools bos.adt.samples"
  bosnetfilesets="bos.net.tcp.server"

  for fileset in $bosfilesets $bosnetfilesets; do
        grep $fileset $LPPOUT >/dev/null ||
                {
                EXIT_YORN=1
                echo "PERPFMR: fileset <$fileset> not installed"
                echo "PERPFMR: please install fileset <$fileset>"
                }
  done

  /usr/bin/rm $LPPOUT
  # exit if missing any of the above LPPs
  if [ $EXIT_YORN = 1 ]; then
    exit 1
  fi
}

#-----------------------------
# Name: begin_perfpmr
#-----------------------------
begin_perfpmr()
{
> $PERFPMROUT
> w.int
echo "    PERFPMR: perfpmr.sh Version $PERFPMRVER" | $TEEOUT
echo "    PERFPMR: current directory: $PWD" | $TEEOUT
echo "    PERFPMR: perfpmr tool directory: $PERFPMRDIR" | $TEEOUT
echo "    PERFPMR: Parameters passed to perfpmr.sh: $PERFPMRPARMS" | $TEEOUT
echo "    PERFPMR: Data collection started in foreground (renice -n -20)" | $TEEOUT

# save a little info from just before session begins
echo "\n     Date and time before data collection is \c" >> $PERFPMROUT

/usr/bin/date >> $PERFPMROUT
perfpmr_uptime before
perfpmr_w before
}


#-----------------------------
# Name: end_perfpmr
#-----------------------------
end_perfpmr()
{
	# collect perfpmr ending status
	echo "\n     Date and time after data collection is \c" >> $PERFPMROUT
	date >> $PERFPMROUT
	perfpmr_uptime after
	# also save 'w' command output (uptime info + user info)
	perfpmr_w after
	echo "\n    PERFPMR: Data collection complete.\n" | $TEEOUT
}


#-----------------------------
# Name: run_tools
#-----------------------------
run_tools()
{
	tc=0
	while (( $tc < $toolcount )); do
	#		echo "PERFPMR: executing < ${cmd[$tc]} >"
			${cmd[$tc]}
		let tc=tc+1
	done
}

#-----------------------------
# Name: check_for_trace
#-----------------------------
check_for_trace()
{
	if /usr/bin/ps -ea | /usr/bin/grep -q -w ' trace '; then
   		traceexists=true
	fi
}

#-----------------------------
# Name: disp_copyright
#-----------------------------
disp_copyright()
{
	echo " " 1>&2
	echo "(C) COPYRIGHT International Business Machines Corp., 2000,2001,2002,2003" 1>&2
	echo " " 1>&2
	sleep 1
}

#-----------------------------
# Name: check_for_space
#-----------------------------
check_for_space_old_way()
{
	# determine if there is sufficient disk space in the current directory
	ncpus=`$PERFPMRDIR/lsc -c`
	let trace_space=ncpus*10  # 10MB * number of cpus
	iptrace_space=30                # 10MB for iptrace (rough estimate)
	gennames_space=30               # 30MB for gennames output
	extraspace=10                       # for other stuff
	let totspace=trace_space+iptrace_space+gennames_space+extraspace
	freespace=`/usr/bin/df -k .|/usr/bin/tail -1|/usr/bin/awk '{print $3}'`
	let freespace=freespace/1024  # Mbytes free

	if [ -n "$PREVIEWONLY" ]; then
             echo "PERFPMR: tools located in: $PERFPMRDIR"
	     echo "PERFPMR: tools to be run include:"
		echo "\t trace.sh $default_time_trace"
		echo "\t monitor.sh $MONITOR_TIME"
		echo "\t iptrace.sh $default_time_iptrace"
		echo "\t tcpdump.sh $default_time_tcpdump"
		echo "\t filemon.sh $default_time_filemon"
		echo "\t tprof.sh $default_time_tprof"
#		echo "\t netpmon.sh $default_time_netpmon"
		echo "\t config.sh"
	    echo "PERFPMR: disk space needed is at least :  <$totspace> Mbytes"
	    echo "PERFPMR: free space in this directory  :  <$freespace> Mbytes"
	    exit 0
	fi

	if [ "$freespace" -lt "$totspace" ]; then
        echo "\nperfpmr.sh: There may not be enough space in this filesystem"
        echo "perfpmr.sh: Make sure there is at least $total_space Mbytes"
        exit 1
	fi
}



#-----------------------------
# Name: do_old_way
#-----------------------------
do_old_way()
{
	echo "PERFPMR: running without perfpmr.cfg file"
	check_for_space_old_way
	begin_perfpmr
	perfpmr_trace $default_time_trace
	if [ "$traceexists" = "true" ]; then
		perfpmr_monitor -p $MONFLAGS $MONITOR_TIME
	else
		perfpmr_monitor $MONFLAGS $MONITOR_TIME
	fi
	perfpmr_iptrace $default_time_iptrace
	perfpmr_tcpdump $default_time_tcpdump
	perfpmr_filemon $default_time_filemon
	perfpmr_tprof $default_time_tprof
#	perfpmr_netpmon $default_time_netpmon
	perfpmr_config
	end_perfpmr
}


validate_int()
{
	num=$1
	if [ -n "$num" -a "${num##*([0-9])}" = "" ]; then
		return 0
	else
		return 1
	fi
}

#-----------------------------
# Name: validate_monitor_time
#-----------------------------
validate_monitor_time()
{
    validate_int "$MONITOR_TIME"  || 
    {
	echo "<$MONITOR_TIME>: Must specify integer value for perfpmr time"
	exit 1
    }
# check total time specified for minimum amount of 60 seconds
if [ "$MONITOR_TIME" -lt 60 ]; then
 echo "    PERFPMR: Minimum time interval required is 60 seconds"
 exit 1
fi
}

		
#-----------------------------
# Name: run_sanity_check
#-----------------------------
run_sanity_check()
{
   grep "config.sh data collection completed" config.sum >/dev/null || 
     {
	echo "PERFPMR: Warning: config.sum file is not complete"
     } | $TEEOUT
}

#-----------------------------
# Name: get_monitor_time
#-----------------------------
get_monitor_time()
{
awk  '
BEGIN {
}
/^perfpmr.sh/ {
        while (status=getline >0)
        {
                if ($0 == "")
                        exit;
                split($0,temp)
                if (temp[1] == "perfpmr_time_seconds" && temp[3] !="")
                        perfpmr_time_seconds= temp[3]
        }
   }
END {
	printf("%s\n", perfpmr_time_seconds);
} ' $PERFPMRCFG 

}

#--------------------------------------------------------------
#                 MAIN 
#--------------------------------------------------------------

unset EXTSHM
PERFPMRVER='433 2003/07/24'
PERFPMRTIME=1059081857   # number of seconds since EPOCH for version of perfpmr
TOO_OLD=7776000	# number of seconds in 3 months
PERFPMRDIR=`whence $0`
PERFPMRDIR=`/usr/bin/ls -l $PERFPMRDIR |/usr/bin/awk '{print $NF}'`
PERFPMRDIR=`/usr/bin/dirname $PERFPMRDIR`
export PERFPMRDIR
PERFPMROUT=perfpmr.int
TEEOUT="/usr/bin/tee -a $PERFPMROUT"
PERFPMRCFG=$PERFPMRDIR/perfpmr.cfg
PERFPMRPARMS="$*"
export traceexists=false
export LANG=C
export GETGENNAMES=1
export GETGENNAMESF=0
default_time_monitor=600
default_time_filemon=60
default_time_netpmon=60
default_time_tcpdump=10
default_time_iptrace=10
default_time_tprof=60
default_time_trace=5

curtime=`$PERFPMRDIR/getdate`
let difftime=curtime-$PERFPMRTIME
if [ "$difftime" -gt "$TOO_OLD" ]; then
  echo "PERFPMR: Warning! This version of perfpmr is over 3 months old"|$TEEOUT
  echo "PERFPMR: You may want to check ftp site for possible newer version"|$TEEOUT
  echo "PERFPMR: sleeping for 5 seconds - will proceed with collection"
  echo "         if this command is not interrupted"
  sleep 5
fi

while getopts PDd:F:x:gcfnps flag 2>/dev/null; do
        case $flag in
	       P)     PREVIEWONLY=1;;
	       D)     OLD_WAY=1;;
	       c)     NO_CONFIG=1;;
	       d)     DELAY=$OPTARG;;
               F)     PERFPMRCFG=$OPTARG;perfpmrcfgfile=1;;
               x)     exec_prog=$OPTARG;break;;
               g)     GETGENNAMES=0;;
               f)     GETGENNAMESF=1;;
               n)     MONFLAGS="$MONFLAGS -n";;
               p)     MONFLAGS="$MONFLAGS -p";;
               s)     MONFLAGS="$MONFLAGS -s";;
                \?)    show_usage;;
        esac
done
shift OPTIND-1

if [ -n "$perfpmrcfgfile" ]; then
	if [ ! -f $PERFPMRCFG ]; then
		echo "PERFPMR: unable to read <$PERFPMRCFG>"
		exit 1
	fi
fi

if [ -n "$exec_prog" ]; then
	if [ -n "$PREVIEWONLY" ]; then
                echo "PERFPMR: tools located in: $PERFPMRDIR"
	    	echo "PERFPMR: command to execute is: $exec_prog $@"
	else
		exec $PERFPMRDIR/$exec_prog $@
	fi
	exit $?
fi



MONITOR_TIME=$1

if [ -z "$OLD_WAY" -a -f $PERFPMRCFG ]; then
	if [ "$MONITOR_TIME" = "" ]; then
		MONITOR_TIME=`get_monitor_time`
	fi
	perf_tools_to_run=`get_tools_to_run $PERFPMRCFG`
	get_other_cmds
	get_tools_and_space $perf_tools_to_run
	
else
	if [ "$MONITOR_TIME" = "" ]; then
                MONITOR_TIME=$default_time_monitor
	fi
	check_for_space_old_way
fi

validate_monitor_time $MONITOR_TIME
check_for_authority
check_lpp_reqs
check_for_trace

disp_copyright

# change shell nice value
/usr/bin/renice -n -20 -p $$

# if delay time specified, sleep for delay time
validate_int "$DELAY" &&  /usr/bin/sleep $DELAY


if [ -n "$OLD_WAY" -o ! -f $PERFPMRCFG ]; then
	do_old_way
else
	begin_perfpmr
	run_tools
	run_other_cmds exec
	end_perfpmr
fi

run_sanity_check
