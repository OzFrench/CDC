README.txt for nmon

nmon is a free performance tool for AIX and Linux available from 
http://www.ibm.com/developerworks/eserver/articles/analyze_aix/index.html

There is also a spreadsheet analyser for nmon captured data from
http://www.ibm.com/developerworks/eserver/articles/nmon_analyser/index.html

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Remember: The nmon tool is NOT OFFICIALLY SUPPORTED. 
No warrantee is given or implied, and you cannot obtain help from IBM. 

Contact the author for assistance.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CONTENTS

- Welcome to nmon 9 - new features
- Frequently Asked Questions
- Current version help (-h) output
- User Guide
- Documentation - First Draft
- Versions and What is new?

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Dear nmon user,

Here are the ten new features that come with version 9 of nmon, some are
massive improvements like WLM, NFS, better rrdtool and Linux Support but
also an important bug fix for Dynamic LPAR.

It includes a number of new features:
a) Async I/O saved in file output
b) NETPACKET saved to file output
c) New HDS driver stats now work
d) Work Load manager (online and file output) for AIX 5L
e) AIX 5.2 DLPAR deactivate CPU NaN bug fixed
f) nmon2rrd tool rewrite generate .gif files for web pages
g) NFS stats - new tool
h) nmon for Linux for pSeries SuSE, Pentium SuSE 8.2 and Red Hat 9.
i) nmon for AIX 433 separate binary
j) Variable threshold for ignoring process using little CPU when saved to file

PLEASE NOTE: 
- AIX 433 is regarded as "old" and you need to run nmon_aix433 and NOT nmon.
- For AIX 5L, we have 32 and 64 bit kernels
- There is not longer a "normal" most often used AIX kernel
  AIX 5L - 32 bit is used where applications are not certified for 64 bit kernel
  AIX 5L - 64 bit should otherwise be the default and increasingly used version
  therefore nmon is now called nmon32 or nmon64
- I suggest you create a hard link for the version the machine needs i.e.
  ln nmon64 nmon
  So you can type just type:  nmon
  And only if you change kernel remake the link

Again in more detail:
a) Saving Asynchronous I/O stats to the nmon file
- if you want AIO stats then add the -A option to the nmon command 
    as in nmon -fTA ....
- This allows application using AIO to be monitored and the
minimum and maximum AIO server set appropriately

b) Saving NETPACKET stats to the nmon file for graphing 
- Stephen Atkins has added support for this in the analyser too.
- NETPACKET is now always collected

c) The new HDS disks (the newest HDS drive is not SDD based like the ESS).
While we don't support the HDS as well as the ESS the stats are now right
	- should just work

d) AIX 5L only Work Load Management stats - type W (upper-case) to see them
Note: AIX 433 does not support the gathering of WLM stats 
Note: you should all be moving to AIX 5L - real soon now 
	- to maintain IBM full support but this is another reason.

Work Load Management - this is the major benefit of AIX and no charge too.
I am writing a white paper to introduce WLM in a simple to follow and
implement way and at zero risk.
If you use passive mode you can use WLM to find out which applications
are taking the CPU, RAM and IO resources of the machine with zero overhead.
I tested this and could not detect WLM taking any resources at all or
at least below 0.25% of one CPU.
nmon outputs
	actual resource use percentage per class
	desired precent AIX sets as a target based on active class shares and 
		limits. These are worth watching as for example classes 
		without processes get zero targets.
		- see the Junk class in the example below.
	the share values (-1 means it is not set)
	the number of processes per class (try for zero in Default class)
	the class Inheritance and Shared Memory flags

	Is there missing data you need?
	 - remember things like min hard and soft are for CPU/RAM/BIO and 
		for each class there are limits to what we can output 
		on the screen

The nmon file capture records the full WLM details once (at the start) in 
the BBBP section but then only the actual resources used to reduce output

Online the output looks like this:
Work Load Manager CPU MEM BIO  CPU MEM IO  CPU   MEM   BIO     Tier Inheritance
Class Name       |---Used----||--Desired-||----Shares-----|Proc's T I Localshm
Unclassified       0%  0%  0% 100 100 100    -1    -1    -1     1 0 0 0
Unmanaged          0% 11%  0% 100  99 100    -1    -1    -1     1 0 0 0
Default            0% 29%  0% 100  98 100    -1    -1    -1    34 0 0 0
Shared             0% 21%  0% 100  98 100    -1    -1    -1     0 0 0 0
System             0% 50%  0% 100  99 100    50    -1    -1    80 0 0 0
database          72%  0%  0%  75 100 100   300    -1    -1     9 0 1 0
batch             26%  0%  0%  25 100 100   100    -1    -1     4 0 1 0
junk               0%  0%  0% 100 100 100   400    -1    -1     0 0 0 0


e) DLPAR mark two resent AIX 5.2 changes resulted in nmon sometimes but no
always reporting duff figures after CPU deactivation. Interestingly, some
AIX tools failed too but now fixed with PTFs! - this is fixed in this version


f) RRD support for graphing - a new version in C with source
nmon2rrd - generates about 33 to 50 or more graphs in .gif format (depending
on the datafile contents) and an index.html ready for a Web Server,
 so that you can access it from any Web Browser.
It is performed on AIX and so can be completely automated.
Thus cutting out the need for FTP to Windows and Excel/1-2-3 spreadsheets.
This avoids the terrible problems Stephen Atkins has to deal with limits in 
	the spreadsheets.

Note: I include the source code so you can fix up the code and return it to me.
You will, of course, require a compiler but it is straight forward stuff
and I learn a lot about some silly stuff in the nmon output file (sorry Steve)
and it compiles with no options: cc nmon2rrd.c
- it is not my best code but a quick hack :-)

Note: use standard nmon output files and NOT the rrd format 
- (i.e. NOT the -R flag).
Note: I would like to remove the rrd format output from nmon
- complaints to me please.
Note: nmon2rrd does not support (i.e. ignores) new stuff like AIO,NFS and WLM.

Use: nmon2rrd -?      for hints
Use: 
nmon2rrd -f nmonfile [-d directory] [-x] 
         -f nmonfile    the regular CSV nmon output file
         -d directory   dirname for the output
         -x             execute the output files
Example:
 nmon2rrd -f m1_030811_1534.nmon -dir /webpages/docs/m1/030811 -x 

This assumes that rrdtool is on your system and in your PATH.
rrdtool is on my top tools list with VMC, vim, filezilla and, of course, Linux
The creator is Tobi Oetiker.
To learn more about rrdtool and the writer go to:
Home site   http://people.ee.ethz.ch/~oetiker/webtools/rrdtool/
AIX binary  http://aixpdslib.seas.ucla.edu/aixpdslib.html

Miss off the -x  out if you want to run the generated scripts yourself as in 
$ mkdir output
$ nmon2rrd -f my.nmon -dir output 
$ cd output
$ rrdtool - <rrd_create >rrd_create.log
$ rrdtool - <rrd_update >rrd_update.log
if there is a TOP section in the nmon output file
$ rrdtool - <rrd_top    >rrd_top.log
$ rrdtool - <rrd_graph  >rrd_graph.log

This allows you to change the create script to collect long term data
and see how to create more/different graphs.

If you want a very small and ultra low risk web server (because it only
servers out .html, .gif, .jpg files from a fixed directory) then take a look
at nweb which is in the ncp package also available from IBM at:
http://www.ibm.com/servers/esdd/articles/free_tools/

Included is a sample nmon output file sample.nmon. 
Get a copy of rrdtool and place it and nmon2rrd in your path.
To see the output run:
$ mkdir /tmp/test
$ cp sample.nmon /tmp/test
$ cd /tmp/test
$ nmon2rrd -f sample.nmon -x
You need to then get it available via a web server and start at the generated
index.html file.
Or use nweb:
nweb 8181 /tmp/test &

If your AIX machine hostname is bonzo.abc.com - in your web browser goto 
http:/ bonzo.abc.com:8181/index.html

nmon2rrd compiles on Linux but core dumps - help wanted.

g) NFS
We have long wanted to add NFS to nmon but there are issues as there is
so many stats and NFS V2 and V3 and it is a kernel extension.  
So as a compromise we have a separate tool called nmonnfs.
This runs (like nmon) on a dumb screen or captures to a file that can be merged
with an nmon capture file for full information.
It actually runs nfsstat in the background to gather the data.
You need a xterm (or similar) window of 35 lines to see all the data so a real
dumb screen or unexpandable telnet is not going to work.
The output looks something like this
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
nmonnfs v3 Hostname=blue  Refresh=2 seconds  loop=22
        S  E  R  V  E  R                          C  L  I  E  N  T       
    v2     v2       v3     v3   NFS version   v2     v2       v3     v3
   Total   Now     Total   Now               Total   Now     Total   Now
       0 [    0]                 root            0 [    0]
       0 [    0]                 wrcache         0 [    0]
       0 [    0]       1 [    0] null            0 [    0]       0 [    0]
       0 [    0]       0 [    0] getattr         0 [    0]    3263 [   34]
       0 [    0]       0 [    0] setattr         0 [    0]       0 [    0]
       0 [    0]       4 [    0] lookup          0 [    0]    6361 [  107]
       0 [    0]       0 [    0] readlink        0 [    0]       0 [    0]
       0 [    0]      22 [    0] read            0 [    0]  184730 [    0]
       0 [    0]       0 [    0] write           0 [    0]       0 [    0]
       0 [    0]       0 [    0] create          0 [    0]       0 [    0]
       0 [    0]       0 [    0] mkdir           0 [    0]       0 [    0]
       0 [    0]       0 [    0] symlink         0 [    0]       0 [    0]
       0 [    0]       0 [    0] remove          0 [    0]       0 [    0]
       0 [    0]       0 [    0] rmdir           0 [    0]       0 [    0]
       0 [    0]       0 [    0] rename          0 [    0]       0 [    0]
       0 [    0]       0 [    0] link            0 [    0]       0 [    0]
       0 [    0]       0 [    0] readdir         0 [    0]       0 [    0]
       0 [    0]       0 [    0] fsstat          0 [    0]       1 [    0]
                       6 [    0] access                       7025 [   30]
                       0 [    0] mknod                           0 [    0]
                       1 [    0] readdir+                      395 [   13]
                       1 [    0] fsinfo                          1 [    0]
                       0 [    0] pathconf                        0 [    0]
                       0 [    0] commit                          0 [    0]
---TOTAL NFS STATS--------------------------------------------------------
       0 [    0]      35 [    0] calls           0 [    0]  201776 [  184]
Server Calls=         35 Bad=0   KEY
Client Calls=     201761 Bad=0   "q"=quit        "-"=faster Space=Refresh
Total  Calls=     201796         "p"=Percentages "+"=slower     Screen
--------------------------------------------------------------------------
This tool uses "nfsstat" command in the background, see "man nfsstat".
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

For details of the fields read the manual page for nfsstat or your NFS
book.

WARNING: 
The stats on the screen are per snapshot period NOT per second like nmon.
This allows you to simply see the actual number of transfers/operations
The captured to file data is per second like nmon.
Busy NFS servers might experience over flow in the counters - let me know 
what happens as my NFS server is busy but not that busy.

How to merge nmon and nmonnfs data?
You should start nmon and nmonnfs at the same time and the same snapshot time and snapshot count (-s and -c parameters).
For example:
$ nmon -fTWA -s 30 -c 300
$ nmonnfs -f -s 30 -c 300
Then concatenate the files together with the cat command :-)
cat *.nmon *.nfs >data.csv
And the data.csv can be used in the nmon analyser.

The analyser produces four extra sections for client/server and V2 and V3.

h) nmon for Linux for pSeries SuSE, Intel 32bit (i.e Pentium) SuSE and Red Hat.
The core of nmon has been ported to Linux, so it has the same
online look and feel and file capture modes.
The bulk of the data comes from /proc filesystem but there are some
things missing because I can't find the data.
Also note some of the data is drastically different - for example,
there is very little in common between the AIX and Linux memory data.
This is not the same code quality as nmon for nmon as it is early days
but I am looking for feedback.
It has only been tried on:
	SUSE SLES8 for pSeries
	SUSE 8.1 and 8.2 for Intel
	Red Hat 9 for Intel (recent version just to check the libraries worked).
If you find it will not run on recent Linux version, please let me know.
I am not interested in older Linux versions.


i) Note AIX 433 is now old and AIX 5L has been out 2 years.
As AIX 433 can't support the WLM function I can no longer create
a single binary for AIX 433 and AIX 5L.
So there is now a separate nmon for AIX 433 - nmon_aix433

j) nmon will not save to file process using less than 0.1% of a CPU
This is to reduce the file output to usful information.
But 0.1% of the fastest CPU is now quite a lot of CPU power, so the threashold
is now changeable using the -I option.  This was requested as a useful idea.

 -I <percent>  Ignore process percent threshold (default 0.1)
               don't save TOP stats if proc using less CPU than this %
Example: nmon -f -I 0.01 -s 10 -c 300


+++++++++ End of new features +++++++++

What are the improvements in recent versions? 
See the last section of this file.

Remember to save your old version until your happy with this one.

What else would you like to see? - New ideas are always welcome.

Thanks Nigel

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Frequently Asked Questions

Question: Which nmon for my version of AIX?
Answer: This nmon release works on the following AIX versions and we given the 
nmon filename to use:
o AIX 4.1.5 - nmon_aix415
o AIX 4.2.0 - nmon_aix420
o AIX 4.3.2 - nmon_aix432
o AIX 4.3.3 - nmon_aix433
o AIX 5.1 and 5.2 32 bit kernel - nmon32
o AIX 5.1 and 5.2 64 bit kernel - nmon64

Why not make a link (or rename) the nmon version you for this particular 
machine with to just plain "nmon".
For example: ln nmon64 nmon
Then you will know for any machine just type nmon and it starts the 
right version.

Some feature go missing with older AIX version (the data is just not there).

Question: I have a problem with nmon running on AIX 4.0.3 
(or any really old AIX versions)?
Answer: Hard luck :-)
I will actively help get AIX 4.3.3, AIX 5.1 and AIX 5.2 bugs fixed 
but older versions are very much less interesting.
In particular AIX 4.1.5 TOP processes does not work but I am not going to 
fix it unless some one offers me a bride in hard currency :-)

Question: All I get is "nmon not found"?
Answer: First check it is executeable (gets switched off by FTP).
Second if your root you have to name the executeable directly with the 
full path name or (if in the current working directory) ./nmon

Question: Can you add the monitoring tape drive?
Answer: No - the data is not in the kernel.
The best you can do is watch the disks and guess what the tape is doing.
The adapter stats is only adding up the attached disks - so it does not help.

Question: Can I get the adapters stats from other tools?
Answer: No - there are no adapter stats in AIX.
nmon is adding up the disk stats to workout what the disk adapters are
doing - really it should be called Deduced Disk Adapter Stats

Question: Can you add the monitoring of process priority?
Answer: This is only available in the AIX 5.1 64 bit kernel.

Question: nmon does not run, please fix?
reports: 
read error: No such device or address
nmon file=nmon.c line=1278 version=XXX
Answer: In 95% of the time it is because AIX was upgraded or a maintenance 
level added but the AIX/system was not rebooted.
It easy to miss the "You must reboot" message in the installp output.
The reboot is required because the AIX kernel image has been updated and 
the reboot is the only way to activate the new /unix file.
nmon reads the /unix file to find kernel data structure addresses but if 
the /unix file does no match what is actually running, you get this message.

You can also get really weird effects if you have messed up LIBPATH.

Question: Can I decide the filename it saves data too?
Answer: Use nmon -h and check out the -F option

Question: I want nmon output piped into a further command, how?
Answer: Use a FIFO and the -F option.
mkfifo /tmp/xyz
nmon -F /tmp/xyz
your-command </tmp/xyz

Question: Why do you support all these old unsupported AIX versions?
Answer: You would be amazed at what versions are running out there.
I guess its a case of - "if it isn't broken don't touch it"

Question: What if I want support?
Answer: You have to options - given me money (and I have no problem with this) 
or pay for and use Performance Toolbox/6000 which can do most of nmon and 
lots more too.

Question: Why don't you add a Java front end to nmon and get graphical output?
Answer: I don't have the time - see previous question.

Question: The options don't seem to work right for file capture?
Answer: The -f, -F, -x, -X or -z MUST be the first option on the line and
only one of them.
These option set all the other option flags, you can then use the other 
flags to modify the default behaviour.
This has improved with the latest nmon versions.

Question: What is paging to a filesystem?
Hopefully, you already understand paging to paging space (also called virtual
memory).
AIX (and other UNIX versions) page in the read-only code from a program
as you start it and as it runs. This is just like paging in from the paging 
space but is directly from the filesystem, this is also true for 
shared libraries (which you might not be aware you are using).
Also programs using memory mapped files access the files by simply reading and 
writing memory addresses - AIX will page in the file pages as necessary 
and they will get paged back to the filesystem to free up memory or 
if the program forces it.

Question: Where can I get nmon and further information?
Answer:
Every can get nmon from:
	http://www.ibm.com/servers/esdd/articles/analyze_aix/
	You need to fill in a small feedback page to get to the download
	image but its quite painless - it also includes an article about
	nmon and where to get the nmon analyser spreadsheet or try:
	http://www.ibm.com/servers/esdd/articles/nmon_analyser/index.html
IBMers can get nmon from an internal web site:
	http://w3.aixncc.uk.ibm.com/tools/index.html

If you email nag@uk.ibm.com - I will manually place you on my e-mail list
for when nmon gets updated and will send you email to get a fresh copy.
This is roughly 2 or 3 times a year. Use an email title explaining its the
nmon list you want to go on.

If you want to be an nmon beta tester for the next version - also send me email.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Hint: nmon64 [-h] [-s <seconds>] [-c <count>] [-f -d -t -r <name>] [-x]

        -h            FULL help information - much more than here
        Interactive-Mode:
        read startup banner and type: "h" once it is running
        For Data-Collect-Mode (-f)
        -f            spreadsheet output format [note: default -s300 -c288]
        optional
        -s <seconds>  between refreshing the screen [default 2]
        -c <number>   of refreshes [default millions]
        -t            spreadsheet includes top processes
        -x            capacity planning (15 min for 1 day = -fdt -s 900 -c 96)

For Interactive-Mode
        -s <seconds>  between refreshing the screen [default 2]
        -c <number>   of refreshes [default millions]
        -g <filename> User decided Disk Groups
                      - file = on each line: group_name <hdisk_list> space separated
                      - like: rootvg hdisk0 hdisk1 hdisk2
                      - upto 32 groups hdisks can appear more than once
        -b            black and white [default is colour]
        example: nmon64 -s 1 -c 100

For Data-Collect-Mode = spreadsheet format (comma separated values)
        Note: use only one of f,F,z,x or X and make it the first argument
        -f            spreadsheet output format [note: default -s300 -c288]
                         output file is <hostname>_YYYYMMDD_HHMM.nmon
        -F <filename> same as -f but user supplied filename
        -r <runname>  goes into spreadsheet file [default hostname]
        -t            include top processes in the output
        -T            as -t plus saves command line arguments in UARG section
        -s <seconds>  between snap shots
        -c <number>   of refreshes
        -l <dpl>      disks/line default 150 to avoid spreadsheet issues. EMC=64.
        -g <filename> User decided Disk Groups (see above -g)
        -D            Skip disk configuration sections
        -E            Skip ESS  configuration sections
        -W            Include WLM sections
        -I <percent>  Ignore process percent threshold (default 0.1)
                      don't save TOP stats if proc using less CPU than this %
        -A            Include Async I/O Section
        -m <dir>      nmon changes to this directory before saving data to a file
        example: collect for 1 hour at 30 second intervals with top procs
                 nmon64 -f -t -r Test1 -s30 -c120

        To load into a spreadsheet like Lotus 1-2-3:
        sort -A *nmon >stats.csv
        transfer the stats.csv file to your PC
        Start 1-2-3 and then Open <char-separated-value ASCII file>

Capacity planning mode - use cron to run each day
        -x            sensible spreadsheet output for CP =  one day
                      every 15 mins for 1 day ( i.e. -ft -s 900 -c 96)
        -X            sensible spreadsheet output for CP = busy hour
                      every 30 secs for 1 hour ( i.e. -ft -s 30 -c 120)

Set-up and installation
        If you get a "can't open /dev/kmem" message
        then as root run: chmod ugo+r /dev/kmem
                or run the tool as the root user
        To enable disk stats as root: chdev -l sys0 -a iostat=true
        - this adds the disk % busy numbers (otherwise they are zero)
        If you have hundreds of disk this can take 1% to 2% CPU

Interactive Mode Commands
        key --- Toggles to control what is displayed ---
        h   = Online help information
        r   = RS6000/pSeries type, machine name, cache details and AIX version + LPAR
        c   = CPU by processor stats with bar graphs
        l   = long term CPU (over 75 snapshots) with bar graphs
        m   = Memory and Paging stats
        k   = Kernel Internal stats
        n   = Network stats
        d   = Disk I/O Graphs
        D   = Disk I/O Stats
        o   = Disk I/O Map (one character per disk showing how busy it is)
        g   = Disk Group I/O Stats (have to use -g commandline option)
        a   = Adapter I/O Stats
        e   = ESS vpath Logical Disk I/O Stats
        j   = JFS Stats
        f   = Fast Response Cache Accelerator Stats (IBM HTTP web server)
        t   = Top Process Stats  1=Basic-Details 2=Accumulated-CPU
               Performance sorted by 3=CPU 4=Size 5=I/O
        u   = Top but with command arguments shown (used with 3,4 & 5)
               to refresh arguments (for new processes) hit u twice
        U   =  as u plus Workload Management Classes
        W   =  Workload Management Stats
        w   = use with top to show AIX wait processes (good for SMP)
        A   = Summarise Async I/O (aioserver) processes
        v   = Verbose this highlights problems on the machine and
              categorises them as either danger, warnings or OK
        b   = black and white mode (or use -b option)
        .   = minimum mode i.e. only busy disks and processes

        key --- Other Controls ---
        +   = double the screen refresh time
        -   = halves the screen refresh time
        q   = quit (also x, e or control-C)
        0   = reset peak counts to zero (peak = ">")
        space = refresh screen now

Startup Control
        If you find you always type the same toggles every time you start
        then place them in the NMON shell variable. For example:
         export NMON=cmdrvtan

Others:
        a) Use shell variable NMONAIX=4.3.2 to a force AIX version
           To you want to stop nmon - kill -USR2 <nmon-pid>
        b) Use -p and nmon outputs the background process pid
        c) To limit the processes nmon lists (online and to a file)
           Either set NMONCMD0 to NMONCMD63 to the program names
           or use -C cmd:cmd:cmd etc. example: -C ksh:vi:syncd
        d) If you want to pipe nmon output to other commands use a FIFO:
           mkfifo /tmp/mypipe
           nmon -F /tmp/mypipe &
           grep /tmp/mypipe
        e) If nmon fails please report it with:
           1) nmon version like: v9a
           2) the output of lslpp -L bos.mp  (or for uniprocessor bos.up)
           3) some clue of what you were doing
           4) I may ask you to run the debug version
        f) From version 7 nmon can output rrdtool friendly output
           Use -R  - you then have to create suitable rrd databases
           and can run nmon output via ksh to update them
           This is still experimental - help needed (see the README.txt)

        Written by Nigel Griffiths nag@uk.ibm.com and Richard Cutler
        Feedback welcome - on the current release only and state exactly the problem
        Version v9a - updated for each AIX release
        No warranty given or implied.

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

User Guide

Free tool to analyze AIX performance

Get a wealth of performance information by running just one tool
from Nigel Griffiths, nag@uk.ibm.com

This free tool gives you a huge amount of information all on one screen. 
Even though IBM does not officially support the tool and you must use it at 
your own risk, you can get a wealth of performance statistics. 
Why use five or six tools when one free tool can give you everything you need?

Usage notes: 
The nmon tool is NOT OFFICIALLY SUPPORTED. 
No warrantee is given or implied, and you cannot obtain help with it from IBM. 

The tool currently comes in two versions for running on different 
versions of AIX:
- nmon - Use with 32-bit kernels (AIX 4.3 and AIX 5.1 on 32 or 64-bit hardware)
- nmon64 - Use with the 64-bit kernel (AIX 5.1)
- For older AIX version use nmon_aix415, nmon_aix420 or nmon_aix432
The tool is updated roughly every six months or when AIX releases are available. 
To place your name on the e-mail list for updates, contact Nigel Griffiths.

Introduction
The nmon tool is designed for AIX and IBM eServer pSeries performance specialists 
to use for analyzing AIX performance data, including the following:
- CPU utilisation
- Memory use
- Kernel statistics and run queue information
- Disks I/O rates, transfers, and read/write ratios
- Free space on file systems
- Disk adapters
- Network I/O rates, transfers, and read/write ratios
- Paging space and paging rates
- CPU and AIX specification
- Top processors
- IBM HTTP web cache

Benefits of the tool
The nmon tool is helpful in presenting all the important performance 
tuning information on one screen and dynamically updating it. 
The tool works on any dumb screen, telnet session, or even dial-up line. 
In addition, the tool is very efficient. It does not consume many CPU cycles, 
usually below 2%. On newer machines, CPU usage is well below 1%.

Data is displayed on the screen and updated once every two seconds using a 
dumb screen. However, you can easily change this interval to a longer or 
shorter time period. If you display the data on X-Windows via telnet and 
stretch the window, nmon can output a great of information all in one place.

The nmon tool can also capture the same data to a text file for later analysis 
and graphing for reports. The output is in a spreadsheet format (.csv). 
Installing the tool
The tool is one standalone binary file that you can install in five seconds, 
probably less if you type fast.  Installation is simple: 
- copy the nmon.tar file to the AIX RS/6000 or pSeries machine
- if the file is called nmon.tar.Z then
	 uncompress the file with: uncompress nmon.tar.Z
- run:  tar xvf nmon.tar
- and start it by typing the command: nmon
- If you are the root user you may need to type: ./nmon
 

Using the tool
You must be the root user or allow regular users to read the /dev/kmem 
file by typing the following command (as root):
chmod ugo+r /dev/kmem

If you want the disk statistics, then also run (as root): 
chdev -l sys0 -a iostat=true

To run interactively
For running the tool interactively, read the front page of the file for a few hints. 
Then start the tool and use the one-key commands to see the data you want. 
For example, to get Cpu, Memory, and Disk statistics, start nmon and type:  cmd

To get help information while running interactively
Press the h key.
To get more help information 
- For brief details, type nmon -?
- For full details, type nmon -h


To capture the data to a file for later analysis and graphing
Run  nmon with the -f flag.  See nmon -h for the details but as an example:
To run nmon for an hour capturing data snapshots every 30 seconds use:
	nmon -f -s 30 -c 120
This will create the output file in the current directory called 
	<hostname>_date_time.nmon  
Before this file can be loaded into a spread sheet is needs to be sorted. 
On AIX, follow this example:
	sort -A mymachine_311201_1030.nmon > xxx.csv

Note: 
1) To load this into a spreadsheet - check the spreadsheet documentation 
for loading comma separated data files. Many spreadsheets except this data 
as just one of the possible files to load or have an import function to do this.
2) Many spreadsheet have fixed numbers of columns and rows - we suggest you 
collect a maximum of 300 snapshots to avoid hitting these issues.
3) When you are capturing data to a file, the nmon tool disconnects from the 
shell to ensure that it continues running even if you log out. 
This means that nmon can appear to crash, but it is still running in the 
background.


Sample output
Following is a sample of the screen output:

nmon      [H for help]  Hostname=ncc96  Refresh=1.0secs  15:14.21
 CPU
+---------------------------------------------------------------------+
100%-|               UUUUUU  U           UUUUUU  U           UUUUUU  |
 95%-|               UUUUUU  UU          UUUUUU  U           UUUUUU U|
 90%-|    U          UUUUUU  UU          UUUUUU  U           UUUUUU U|
 85%-|    U          UUUUUU  UU          UUUUUU  UU          UUUUUU U|
 80%-|    U          UUUUUUU UU          UUUUUU UUU          UUUUUU U|
 75%-|    U          UUUUUUU UU          UUUUUU UUU         UUUUUUU U|
 70%-|    U          UUUUUUU UU          UUUUUU UUU         UUUUUUU U|
 65%-|    U          UUUUUUUUUU         UUUUUUUUUUU         UUUUUUU U|
 60%-|    U          UUUUUUUUUU         UUUUUUUUUUU         UUUUUUU U|
 55%-|    U          UUUUUUUUUU         UUUUUUUUUUU         UUUUUUU U|
 50%-|    UU       UUUUUUUUUUUU        UUUUUUUUUUUU        UUUUUUUUUU+
 45%-|    UU       UUUUUUUUUUUUU       UUUUUUUUUUUU       UUUUUUUUUUU|
 40%-|    UU       UUUUUUUUUUUUU      UUUUUUUUUUUUU       UUUUUUUUUUU|
 35%-|    UU      UUUUUUUUUUUUUU      UUUUUUUUUUUUUU      UUUUUUUUUUU|
 30%-|    UU      UUUUUUUUUUUUUU      UUUUUUUUUUUUUU      UUUUUUUUUUU|
 25%-|    UU     UUUUUUUUUUUUUUU    UUUUUUUUUUUUUUUU    UUUUUUUUUUUUU|
 20%-|    UU     UUUUUUUUUUUUUUU    UUUUUUUUUUUUUUUU    UUUUUUUUUUUUU|
 15%-|    UU    UUUUUUUUUUUUUUUU    UUUUUUUUUUUUUUUU    UUUUUUUUUUUUU|
 10%-|   UUU    UUUUUUUUUUUUUUUUU   UUUUUUUUUUUUUUUU    UUUUUUUUUUUUU|
  5%-|   UUU    UUUUUUUUUUUUUUUUU  wUUUUUUUUUUUUUUUUU  UUUUUUUUUUUUUU|

+---------------------------------------------------------------------+
CPU Utilisation
                             +-------------------------------------------------+
CPU    User%  Sys% Wait% Idle|0         |25        |50         |75          100|
 0     94.1   1.0   0.0   5.0|UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU  >
 1     96.0   0.0   0.0   4.0|UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU >
 2     96.0   0.0   0.0   4.0|UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU >
 3    100.0   0.0   0.0   0.0|UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU>
                             +-------------------------------------------------+
       96.0   0.2   0.0   3.7|UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU >

+-------------------------------------------------+
Kernel Internal Statistics    (all per second)
RunQueue=    4.0   swapIn =    1.0  iget  =     0.0   namei =    0.0
pswitch =   44.7   syscall=   56.6  rawch =     1.0   canch =    0.0
fork    =    4.0   read   =   17.9  dirblk=     0.0   outch = 1030.5
exec    =    0.0   write  =    2.0  readch = 2188.1
msg     =    0.0   sem    =    0.0  writech= 1029.5
Network I/O
I/F Name Recv  Trans kB/s  packin  packout  insize  outsize
     lo0   0.0   0.0          0.0     0.0     0.0     0.0
     tr0   0.6   1.2          8.9     3.0    68.2   411.0
Adapter I/O    read  write      xfers  Adapter Type
10-60           0.0    0.0 kB/s   0.0 Wide/Fast-20 SCSI I/O Controller
Disk I/O
DiskName Busy  Read  Write   |0          |25         |50          |75       100|
hdisk1    0%    0.0    0.0 kB|>                                                |
hdisk2    0%    0.0    0.0 kB|>                                                |
hdisk3    25% 111.0  130.0 kB|WWWWWRRRRRR>                                     |
hdisk3    21%  13.0  201.0 kB|WWWWWWWWRR>                                      |
hdisk5    0%    0.0    0.0 kB|>                                                |
hdisk4    0%    0.0    0.0 kB|>                                                |
cd0       0%    0.0    0.0 kB|>                                                |

Top Processes Processes=49 mode=3 (1=Basic, 2=CPU 3=Perf. w=wait-procs)
PID   %CPU    Size  Res  Res    Res   Char  RAM    Paging       Command
      Used      K   Set  Text   Data   I/O  Use io other repage
 11730  11.9    96    32    16    16 38576  0%    0   17    0 pmon
 11384   1.0   744   860    76   784  3184  0%    0    0    0 nmon
  1548   0.0    12 14044 14032    12     0  5%    0    0    0 lrud
  1806   0.0    16 14048 14032    16     0  5%    0    0    0 xmgc
  2064   0.0    16 14048 14032    16     0  5%    0    0    0 netm
  2322   0.0    64 14096 14032    64     0  5%    0    0    0 gil = TCP/IP
  2580   0.0    16 14048 14032    16     0  5%    0    0    0 wlmsched
  3222   0.0   144   164     4   160     0  0%    0    0    0 syncd

Documentation
There is no special documentation with nmon other than the 
first page of the tool file. However, the data displays generated by 
nmon are similar to the displays generated by 
the standard AIX commands such as vmstat, iostat, netpnmon, df, and sar. 
Use the manual pages for these standard commands to understand 
what the displayed data means. 
If needed, you can also look into IBM Education on AIX at 
http://www.ibm.com/servers/esdd/education.html. 

Performance tuning redbooks
Following are several useful IBM Redbooks that you can buy or download for 
free from http://www.redbooks.ibm.com:
- Understanding IBM pSeries Performance and Sizing 
	(new version SG24-4810-1) 400 pages. 
	For Performance tuning on pSeries and AIX.
- Database Performance on AIX in the DB2 UDB and Oracle Environments 
	(SG24-5511) 450 pages. The techie's bible for tuning these 
	databases for high performance.
- AIX 5L Performance Tools Handbook (SG24 6039) 950 pages. 
	All the latest tools for AIX5L including truss and WLM.


About the author
Nigel Griffiths works in the IBM eServer pSeries Technical Support - 
Advanced Technology Group and specialises in performance, sizing, tools, 
benchmarks, and Oracle RDBMS. The nmon tool was developed to support 
benchmarks and performance tuning for internal use but by popular demand 
is given away to deserving friends.


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
nmon Documentation  --- First Draft

CPU 
The below four types of CPU workload always add up to 100% (the CPU has to be doing something).
User = Application code (kernel programmers call this user mode) this includes programs and RDBMS
Sys = AIX Kernel code - this is invoked by either a system call or hardware interrupt including the regular clock interrupts
Wait = waiting for IO. This really is idle but there is outstanding disk I/O.
Idle = nothing else to run 

Memory Use 
Virtual the memory backed up by paging space and called virtual memory
Physical the actual RAM in the machine 
Paging of Memory the transfers between RAM and disk In=to RAM Out=to disk 
% Used percentage of memory allocated and being used 
% Free percentage of memory not allocated and available 
MB Used amount of memory allocated and being used in megabytes 
MB Free amount of memory not allocated and available in megabytes 
Total(MB) above columns added up 

Verbose Mode
CPU - If this is high response times will suffer
Paging Space - Virtual/Real Ratio for small memory system (<128MB) this should be greater than 2.5 and for large memory systems 1.2 is a recommended minimum. Laos 20% of paging space should be free
Page Faults - If this is above 20 times the CPU this will be slowing down performance
Top Disk -  If this hotest disk is above 60% this could be slowing down performance.

Paging Space 
to Paging Space transfers between RAM and allocated paging logical volumes 
to File System transfers between RAM and allocated journal file system (i.e. read only program code) 
Paging Scans - this is how often AIX is looking for memory pages to release to the free list.
Paging Cycles - this is how often it scans all memory and fails to free any pages
Page Reclaims - this is where a program grabs the page back from the freelist before it was used, as it really needs it.

VM parameters
numperm - amount of RAm used by the JFS cache
minperm and maxperm - low and high water levels that effect the VMM's choice of which pages to take on to the freelist
minfree and max free - the low and high water levels for stopping and starting the lrd deamon to look for memory pages to free up

Network 
read kB/s and write kB/s - the kilobytes read and written on the network 
packin and packout - the number of network packets in=received out=sent 
insize and outsize - the average packet size in=received out=sent 

Disk I/O 
Busy - The percentage of the time the disk was found in use 
Read kB/s and Write kB/s - read and written kilobytes by drive per second 
Xfers - blocks transferred per second 
Rsize and Wsize - average transfer size 
Peak% - the peak Busy percentage
Peak-RW KB/s - the peak Read plus Write
Used - highlights when disk is being used 

Adapter I/O 
see Disk I/O the I/O for all disks on the adapter are added up 
Adapter Type the adapter type and so the type of disk (if known) 

Top Processes 
CPU mode 1
PID - Process indentity 
PPID - Parent Process indentity 
UID - User indentity 
Pgrp - Process group 
Nice - used in process priority calculation 
Status - see /usr/include/sys/proc.h files 
proc-Flag - see above include files 
Thrds - number of threads within the process
Files - number of files open within the process 
Command - the simple form of the command used to start the process 

CPU mode 2
Time Start - time the process was started 
System time this process was running in system (Kernel) mode inside AIX 
User time this process was running user application code 
Child CPU time used by processes started by this process 
Delta time differences between the last two screen updates 

CPU mode 3
%CPU - Used percentage of one CPU used on this process 
Size K - process size in kilobytes
Res set K - resident set in kilobytes (RAM actually allocated) 
Res Text - resident set in kilobytes for code part of program 
Res Data - resident set in kilobytes for data and stack part of program 
RAM Use - percentage of memory used 
Paging io - paging caused by this process doing I/O 
Paging other - paging caused by this process (not including doing I/O) 
Paging repage - paging caused by this process repeatedly needing pages 


Kernel Internal Statistics 
RunQueue - run queue length (processes waiting for CPU) 
SwapIn - processes swapped back in after thrashing 
iget - inode JFS file descriptor) get from the disk
namei - file/directory lookup within the JFS
dirblk - directory block read within the JFS
pswitch - process switches (changes between user applications(time sharing the CPU))
syscall - system calls (application requesting AIX services)
rawch - raw character read in from tty 
canch - canonical character read in and processes 
outch - character output to tty 
read - read system call (all types of device disk, network/socket, pipe)
write - write system call (all types of device disk, network/socket, pipe)
fork - new process creation (clone current process)
exec - new program code started (over write current process with a new program)
readch - characters read 
writech - characters written 
msg - shared messages written between applications
sem - shared semaphore operations between applications

Disk %Busy Map
This shows how busy all the disks get

Asynchronous I/O Processes
Total AIO processes = count of the number running
all Time peak = maximum every spotted running by nmon
Actually in use = number during current snapshot
Recent peak = number since user hit 0 key
CPU used = total CPU currently being used
Peak CPU used = total CPU currently being used since user hit 0 key

ESS I/O
See Disk I/O

JFS
See df command

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
nmon Versions  
VERSION 6f


	2) Hundreds of disks - cannot see the "wood for the trees"!!
	For machines with hundreds of disks it is hard to see how many are being 
	actively used and which are getting hot.
	The Disk %Busy Map (hit o) will show you - one character for each disk 
	with more pixels the hot it gets.

	Disk %Busy Map Key: #=80% X=60% O=40% o=30% +=20% -=10% .=5% _=0%
	       hdisk(s)  1         2         3         4         5         6
	       0123456789012345678901234567890123456789012345678901234567890123
hdisk0 to 63   ________________________________________________________________
	       ________________________________________________________________
	       ________________________________________________________________
	       ____________

	Yes that is 203 disks - I have benchmarked with 800 disks!!

	3) AIO monitoring
	Asynchronous I/O servers are monitored - this allows you to work out how 
	many are really active.  This will help in tuning them for Oracle
	Asynchronous I/O Processes
	 Total AIO processes=500 Actually in use= 23 CPU used=   12.1%
	       all time peak=400     resent peak= 45      peak=  24.9% 
							(use 0 to reset)

	4) Logical Partitions (LPAR)
	nmon can work out if it is in an LPAR (AIX 5.1 and p690 only at the moment).
	It is in the RS6000 details (hit r).  
	Also note that are more detailed like the NIM hardware type and bus type too
	 (if your AIX level allows this) - for example a 32 way p690 in 
	full partition mode.

	RS/6000 Details
	Hardware-Type(NIM)=chrp=CHRP Bus-Type=PCI
	Logical partition=No
	CPU Type=PowerPC POWER4, 64 bit with 32 CPUs (32 CPUs activated)
	CPU Level 1 Cache is Combined Instruction=65536 bytes & Data=32768 bytes
	    Level 2 Cache size=1474560
	AIX 5.1.0.15                            Kernel=Multi-Processor 32 bit
	uname=rhone hostname=rhone

	5) Dot
	The dot command (hit .) which shows only busy disks and processes. 
	This now works for ESS/vpaths too. For example:
	ESS I/O          AvgBusy   read-KB/s write-KB/s  xfers/s        Total vpaths=35
	vpath9           0.0%       0.0       8.0         0.5
	vpath21          0.0%       0.0       8.0         0.5
	TOTALS          0.0%       0.0KB/s      16.0KB/s         1.0    TOTAL=16.0KB/s

	6) ESS reporting fixed
	Thanks to Iain Roberts, Ralf Schmidt-Dannert (IBM USA) and 
	Marc Bouzigues (IBM MOP)
	The ESS stats now work again - sorry about the bug in early v6 nmon versions!

	7) Help Information
	Some cleaning up on the help and hints etc.

	8) Data capture
	This has been improved for the analyser spreadsheets.
	Also the -d and -e flags are now the default (but do no harm).

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VERSION 6g
	file capture
		BBBB section first disk shown 
		EMC hdiskpower disks were double counted as hdisks and 
			hdiskpower both report stats
		the only one disk in the first BBBD adapter line
		pgspouts was always zero now reported OK 
		month off by one
		it will now skip /proc (AIX 5.1)
		Disk map 0 should be O
		ESS % busy forgot to divide by the elapsed time so 
			the %busy for 2 second updates would be twice 
			the real number etc.
		special Ralf mode startup - nmon -p  -f ....   will output 
			the background child pid (currently undocumented :-)
			this allows a script to signal the nmon process to 
			stop with SIGUSR2
		nmon now starts in half a second (on my J40 and 270) and 
			may confuse less people
	Big thanks to our Bugs Reporters and testers
		BBBB error by Lance N. Castillo
		all the other reported by Ralf Schmidt-Dannert

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VERSION 6i and VERSION 7a (Sept 2002)

	Bugs removed
		ESS - Catastrophe in realloc: invalid storage ptr
		TOP - occasional crash with rapidly growing processes numbers

	Command arguments can be seen or saved to files
	online "u" will show the real command and arguments in the Top section
	capture mode use -T and you will find a new UARG section in the file

	WLM Workload Management Classes -> for AIX 5L and 64 bit kernel only
	online "U"
	capture mode (using -T) for an extra column in the TOP section

	Online Top section can now re-order processes by their 
		Hit "4" for order by Memory = Memory Resident Size
		Hit "5" for order by Character I/O 


	ESS section now includes vpath Size in MB 

	Some clean up in 
		online column positions and 
		JFS stats do not stop you unmounting the filesystems 
					(unless your very unlucky)
		kB/s => KB/s and
		improved regular flush to disk

	Selected processes only (by program name)
	Use either -C cmd:cmd:cmd (like nmon -C vi:ksh:init:fin) or  
	Set shell variables NMONCMD0 to NMONCMD63 to the program names 
		(export NMONCMD0=vi; export NMONCMD1=ksh;    etc.)
	This drastically reduces the TOP section of nmon files
	note the command is only checked upto the characters you give it 
		so "or" will match "oracle" and "orifice"
		= limited wild cards!

	Experimental rrdtools output 
		rrd is the round robin database freeware
		see http://people.ee.ethz.ch/~oetiker/webtools/rrdtool/
		AIX version can be found at http://aixpdslib.seas.ucla.edu/index.html
		first create the rrd database - see the script provided
			this will need changing depending on the # of disk etc.
		use -R to save files with seconds since 1970 timestamps
		use 
		mkfifo xyz  
		then start nmon with output redirected to the fifo
		nmon -F xyz   
		then read from the FIFO to add the data directly into 
			the rrd database in real time
		ksh <xyz

	You will need to use the next version of the nmon analyser for nmon8
		that is the version v290

	Network online stats now has peak values (reset by hitting 0)

	Disks stats (not graphs) hit D (upper case) includes qDepth 
		- if supported by the disks attached

	Adapter names are used instead of the location codes (these are 
	both in the BBB section) this makes them easier to understand.

	It should also start up faster with larger ESS configurations.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VERSION 8b (Jan 2003)

	Dynamic LPAR
	The online version automatically adjusts the screen as CPUs are 
	added or removed and the memory stats work find too.
	We do NOT support dynamic adapter (PCI slot) changes 
		- restart nmon or pray.

	User Defined Disk Groups
	On a recent benchmark with 3 x ESS = 1024 disks it became impossible to
	monitor them to ensure balanced I/O loading. So this was developed.
	The idea is to merge the disks into sets and monitor the sets.
	It is like the adapter stats but you get to choose which disks go into
	which set (adapter).  Three obviously ways of doing this are by the:
	- disk use = group disks that have common data for example
		a databases data, index, sort, logs, archive =  5 disk groups
	- disk placement = the disks in a particular rack/drawer for example
		ESS, cluster, rank, loop - makes 8 groups per ESS
	- disk type or volume group/logical volume
	Or any thing else you think up.

	To set this up create a file with:
		one line per disk group
		starting with the name of the group
		then a list of hdisks
		all space separated
	Then start nmon with the following option: -g filename 
	If online hit: g
	If saving to a file there will be more sections for diskgroups = DG
	The analyser understands these new sections thanks to Stephen Atkins.

	Here are a few examples:
	For my ESS placement disk groups I used the following script 
		(this assumes you have the lsess command):
FILE1=/tmp/lsess_arary.tmp1
FILE2=/tmp/lsess_arary.tmp2
lsess >$FILE1
grep hdisk $FILE1 | grep -v "not ready" | awk '{ print $3 }' | cut -b 4-8 | sort | uniq >$FILE2
for j in `cat $FILE2`
do
	for i in 1100 1101 1300 1301 1500 1501 1700 1701 1000 1001 1200 1201 1400 1401 1600 1601
	do
		echo "ESS${j}_${i} \c"
		grep hdisk $FILE1 | grep $j | grep ${i} | awk '{ printf " " $1 }'
		echo
	done
done
rm $FILE1 $FILE2
exit

	and generated the following disk group file:
array_1100  hdisk44 hdisk45 hdisk46 hdisk47 hdisk48 hdisk49 hdisk50 hdisk51 
array_1101  hdisk52 hdisk53 hdisk54 hdisk55 hdisk56 hdisk57 hdisk58 hdisk59 
array_1300  hdisk60 hdisk61 hdisk62 hdisk63 hdisk64 hdisk65 hdisk66 hdisk67 
array_1301  hdisk68 hdisk69 hdisk70 hdisk71 hdisk72 hdisk73 hdisk74 hdisk75
		... etc.


	For a database setup you might need to work out the disks and 
	create something like:
root hdisk0 hdisk1
home hdisk2 hdisk3
apps hdisk4 hdisk5 hdisk6
data hdisk7 hdisk8 hdisk9 hdisk10 hdisk11 hdisk12 hdisk13 hdisk14
index hdisk15 hdisk16 hdisk17 hdisk18 hdisk19 hdisk20 hdisk21 hdisk22
archive hdisk23 hdisk24 hdisk25
sort hdisk26 hdisk27 hdisk28 hdisk29 hdisk30
logs hdisk31 hdisk32
others hdisk33 hdisk34

        nmon will report errors if it does not like your disk group file but
        starts any way - check the number of disks it found for each disk group.
        If the errors are to fast to see - capture to file with -f.
        Note: the same disk can be in more than one group - so you could
        have the placement and use at the same time by different group names.
        Limits:
        Make the disk group name 14 or less characters and no blank lines.
        You should only use 32 disk groups there are limits to the 
                number of disks in a disk group too.

        Disk Read/Write Size
        Disk read size and disk write size are now just Disk Block Size
                in the captured data it is called  DISKBSIZE
                online this has changed too.


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VERSION 8d (May 2003)

It includes a number of small fixes:
a) The User Defined Disk Group headers are working and the 
	definition is saved in the BBBG Section.
	If you are using theses this is a big improvement.
b) vmtune -a is saved at the end of a run (as well as the start)
	- so you can check if the counters have changed during a run.
c) The dot (.) command does not change the disk or top mode.
d) nmon -m dir  nmon moves to the directory .
	- removes need to run a script from cron.
e) AIX 5.2 capture vmo, ioo, no, nfso and schedo parameters in full.
f) Remove order dependency in -f, -F, -T -t options.

g) Bug fixes when running on AIX 5.2 (virtual memory stats and multipath I/O).

h) Removed the disk read and write size data - now merged into blocksize stats.

--- The End ---
