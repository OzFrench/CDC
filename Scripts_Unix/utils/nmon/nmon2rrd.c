#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <strings.h>
#include <time.h>
#include <ctype.h>

#define VERSION "5.0"

int debug = 0;
int debug2 = 0;
int interval, snapshots;
/* +++++++++++++++++++++++++++++++++++++ UTC Stuff here */
long tarray[10240];

char dirname[1024] = "./";
char filename[1024];

#define TOP_PROCESSES 20 /* should be a multiple of 4 */

long utc(int sec, int min, int hour, int day, int mon, int year)
{
struct tm *timp;
time_t timt;

        timt = time(0);
        timp = localtime(&timt);
        timp->tm_hour=hour;
        timp->tm_min=min;
        timp->tm_sec=sec;
        timp->tm_mday=day;
        timp->tm_mon=mon,
        timp->tm_year=year;

        timt = mktime(timp);
        if(debug)printf("%d:%02d.%02d %02d/%02d/%04d = %ld\n", timp->tm_hour, timp->tm_min, timp->tm_sec, timp->tm_mday, timp->tm_mon+1, timp->
tm_year+1900,timt);
        return (long)timt;
}

search_for_tstring(char *s)
{
long len=strlen(s);
int i;

        for(i=0;i<len;i++) {
                if( s[i] == ',' &&
                        s[i+1] == 'T' &&
                        isdigit(s[i+2]) &&
                        isdigit(s[i+3]) &&
                        isdigit(s[i+4]) &&
                        isdigit(s[i+5]) &&
                              s[i+6] == ',' )
                        return i+1;

        }
        return 0;
}

/* Top Disk Data */
#define NUMOFNAMES 1024
#define NUMOFSHOTS 300
#define NUMOFITEMS (NUMOFNAMES * NUMOFSHOTS)

struct topdisk {
        float min;
        float max;
        float percent;
        int hits;
        char *name;
} topdisk[NUMOFNAMES];

int topdisks=NUMOFNAMES;
int diskrows=0;

/* Top Disk Code */
start_disks()
{
int i;
        for(i=0;i<topdisks;i++){
                topdisk[i].min = 100.0;
                topdisk[i].max = -1.0;
                topdisk[i].percent = 0.0;
                topdisk[i].hits = 0;
        }
}
save_diskname(int disk, char *name)
{
        topdisk[disk].name = malloc(strlen(name)+1);
        strcpy(topdisk[disk].name, name);

}
save_disk(int disk, int percent)
{
        if(percent > topdisk[disk].max)
                topdisk[disk].max = percent;
        if(percent < topdisk[disk].min)
                topdisk[disk].min = percent;
        topdisk[disk].percent += percent;
        topdisk[disk].hits++;
}

compare_disk( void *a, void *b)
{
        return (int)((((struct topdisk *)b)->percent*1000)  - (((struct topdisk *)a)->percent*1000) );
}

print_disk()
{
int i;
        qsort((void *)&topdisk[0], topdisks, sizeof(struct topdisk), &compare_disk);
        for(i=0;i<topdisks;i++){
                if(topdisk[i].max == -1.0)
                        return;
                printf("disk %d min=%5.2f max=%5.2f totalpercent=%5.2f hits=%d\n avg=%5.2f wavg=%5.2f",
                i,
                topdisk[i].min,
                topdisk[i].max,
                topdisk[i].percent,
                topdisk[i].hits,
                topdisk[i].percent/diskrows,
                topdisk[i].percent/ topdisk[i].hits
                );
        }
}

/* Top Processes Data */
struct top {
        float cpu;
        char *name;
        int tnum;
} tops[NUMOFITEMS];

int topnum=NUMOFITEMS;

struct topname {
        float cpu;
        float tmp;
        char *name;
} topname[NUMOFNAMES];

int topnames=NUMOFNAMES;

/* Top Processes Code */
compare_top( void *a, void *b)
{
        return (int)((((struct topname *)b)->cpu*1000)  - (((struct topname *)a)->cpu*1000) );
}

void start_top(int num)
{
int i;
        for(i=0;i<topnum;i++)
                tops[i].tnum = -1;
        for(i=0;i<topnames;i++) {
                topname[i].cpu = -1;
                topname[i].name = 0;
	}
}

void save_top(int tnum, float busy, char *name)
{
int i;
        if(busy < 0.0001)
                return;

	/* clean up the name */
        if(!strncmp("gil = TCP/IP",name,12))
                name[3]=0;
        if(!strncmp("defunct",name,7))
                name[7]=0;
	replace1(name,".","");
	replace1(name,"-","");
	replace1(name," ","");
        for(i=0;i<topnum;i++) {
                if( tops[i].tnum < 0) { /* no match */
                        tops[i].name = malloc(strlen(name)+1);
                        strcpy(tops[i].name,name);
                        tops[i].cpu = busy;
                        tops[i].tnum = tarray[tnum];
                        if(debug)printf("topnew %d %7.2f cmd=%s.\n",tnum,busy,name);
                        break;
                }
                if( tops[i].tnum == tarray[tnum] && !strcmp(name,tops[i].name)) {
                        tops[i].cpu += busy;
                        if(debug)printf("topadd %d %7.2f cmd=%s. now=%7.2f\n",tnum,busy,name,tops[i].cpu);
                        break;
                }
        }
        for(i=0;i<topnames;i++) {
                if( topname[i].cpu < 0){
                        topname[i].name = malloc(strlen(name)+1);
                        strcpy(topname[i].name,name);
                        topname[i].cpu = busy;
                        break;
                }
                if( !strcmp(name,topname[i].name)) {
                        topname[i].cpu += busy;
                        break;
                }
        }
	if(debug)printf("topname i=%d  %7.2f cmd=<%s> now=%7.2f\n",i,busy,name,topname[i].cpu);
}

void end_top(void)
{
int i;
int j;
int current;
FILE *tfp;

        qsort((void *)&topname[0], topnames, sizeof(struct topname), &compare_top);
        if(debug)for(i=0;i<topnum;i++) {
                if( tops[i].tnum < 0)
                        break;
                printf("top:%d %7.2f cmd=%s.\n",
                        tops[i].tnum,tops[i].cpu,tops[i].name);
        }
        current = tops[0].tnum;
        for(j=0;j<TOP_PROCESSES;j++) {
                topname[j].tmp=0.0;
        }
	sprintf(filename,"%s/%s",dirname,"rrd_top");
	tfp = fopen(filename,"w");
	if(tfp==NULL) {
		perror("failed to open file");
		printf("file: \"%s\"\n",filename);
		exit(72);
	}
        for(i=0;i<topnum;i++) {
                if( tops[i].tnum < 0)
                        break;
                if(tops[i].tnum != current) { /* then print this entry */
                        fprintf(tfp,"update top.rrd %d",current);
                        for(j=0;j<TOP_PROCESSES;j++) {
                                fprintf(tfp,":%.2f", topname[j].tmp);
                                topname[j].tmp=0.0;
                        }
                        fprintf(tfp,"\n");
                        current = tops[i].tnum;
                }
                /* save this one */
                for(j=0;j<TOP_PROCESSES;j++) {
                        if(!strcmp(tops[i].name,topname[j].name)){
                                topname[j].tmp = tops[i].cpu;
                                break;
                        }
                }
        }
	fclose(tfp);
}

/* General use buffer */
#define STRLEN 8196
char string[STRLEN];

/* UTC */
int utc_start;
int utc_end;

/* Static Variable lists for nmon sections */
char *a_cpu[] = { "User","Sys","Wait","Idle"};
int a_cpu_size = sizeof(a_cpu)/sizeof(char *);
char *a_mem[] = { "RealFree","VirtualFree","RealFreeMB","VirtualFreeMB","RealMB","VirtualMB" };
int a_mem_size = sizeof(a_mem)/sizeof(char *);
char *a_memuse[] = { "numperm","minperm","maxperm","minfree","maxfree"};
int a_memuse_size = sizeof(a_memuse)/sizeof(char *);
char *a_page[] = { "faults","pgin","pgout","pgsin","pgsout","reclaims","scans","cycles" };
int a_page_size = sizeof(a_page)/sizeof(char *);
char *a_proc[] = { "Runnable","Swapin","pswitch","syscall","read","write","fork","exec","rcvin","xmtint","sem","msg" };
int a_proc_size = sizeof(a_proc)/sizeof(char *);

char *a_file[] = { "iget","namei","dirblk","readch","writech","ttyrawch","ttycanch","ttyoutch" };
int a_file_size = sizeof(a_file)/sizeof(char *);

int lines=1024;

char **line;
int linemax;
int longest = 0;

#define ARRAYMAX 1024
#define ARRAYWIDTH 128
char *array[ARRAYMAX];

char *host;
char time_and_date[1024];

FILE *ufp;
FILE *cfp = NULL;
FILE *gfp = NULL;
FILE *wfp = NULL;

int str2array(int skip, char *s)
{
int i;
int j;
int k;
int len;
	len=strlen(s);
	for(i=0,j=0;i<len&&j<skip;i++) {
		if(s[i] == ' ')
			j++;
	}
	if(j!=skip) {
		printf("str2array skip failure <%s> skip=%d\n",s,skip);
		return 0;
	}
	if(debug)printf("str2array str=%s skip to <%s> skip=%d\n",s,&s[i],skip);
		
	for(j=0,k=0;i<len;i++) {
		if(s[i]== ' ') {
			array[j][k]=0; /* add null terminator */
			k=0;
			j++;
		} else {
			array[j][k]=s[i];
			k++;
			array[j][k]=0; /* add null terminator */
		}
	}
	if(s[i-1] != ' ') j++;
	return j;
}

webgraph(char *name)
{
	fprintf(wfp,"<IMG SRC=%s.gif>\n",name);
}


char *colourmap[] = {
"F0F0F0", "FF0000", "00FF00", "0000FF", "FFFF00", "00FFFF", "FF00FF", "0F0F0F",
"FF8800", "00FF88", "8800FF", "880000", "008800", "000088", "888800", "008888",
"880088", "080808", "884400", "008844", "440088", "888888", "BB0000", "00BB00",
"0000BB", "BBBB00", "00BBBB", "BB00BB", "0B0B0B", "BB8800", "00BB88", "8800BB",
"BBBBBB", "440000", "004400", "000044", "444400", "004444", "440044", "040404",
"448800", "004488", "880044", "444444", "DD0000", "00DD00", "0000DD", "DDDD00",
"00DDDD", "DD00DD", "0D0D0D", "DD8800", "00DD88", "8800DD", "DDDDDD", "660000",
"006600", "000066", "666600", "006666", "660066", "060606", "668800", "006688",
"E0E0E0", "EE0000", "00EE00", "0000EE", "EEEE00", "00EEEE", "EE00EE", "0E0E0E",
"EE7700", "00EE77", "7700EE", "770000", "007700", "000077", "777700", "007777",
"770077", "070707", "773300", "007733", "330077", "777777", "AA0000", "00AA00",
"0000AA", "AAAA00", "00AAAA", "AA00AA", "0A0A0A", "AA7700", "00AA77", "7700AA",
"AAAAAA", "330000", "003300", "000033", "333300", "003333", "330033", "030303",
"337700", "003377", "770033", "333333", "CC0000", "00CC00", "0000CC", "CCCC00",
"00CCCC", "CC00CC", "0C0C0C", "CC7700", "00CC77", "7700CC", "CCCCCC", "550000",
"005500", "000055", "555500", "005555", "550055", "050505", "557700", "005577",
"880066", "666666", "770055", "555555" };

char *colour(int col)
{
	if(col > sizeof(colourmap)/sizeof(char *) )
		return "111111";
	return colourmap[col+1];
}

#define ANY 0
#define PERCENT 1
#define AREA 2
#define LINE 3

void rrdgraph(char **fields, int count, char *rrdname, char *gif, int percent, 
	char *vtitle, int type, char *units) 
{
int i;
int vars;
char *percentstring, *t1, *t2, *stack;

	webgraph(gif);

	if(gfp == NULL) {
		sprintf(filename,"%s/%s",dirname,"rrd_graph");
		gfp = fopen(filename,"w");
		if(gfp==NULL) {
			perror("failed to open file");
			printf("file: \"%s\"\n",filename);
			exit(73);
		}
        }

	if(percent == PERCENT){
		percentstring = "-r -l 0 -u 100";
	} else {
		percentstring = "-r -l 0";
	}
	if(type == LINE){
		t1 = "LINE1";
		t2 = "LINE1";
		stack = "";
	} else {
		t1 = "AREA";
		t2 = "STACK";
		stack = " Stacked";
	}
	if(debug)fprintf(gfp, "info %s\n",gif);
	sprintf(filename,"%s/%s.gif",dirname,gif);
	fprintf(gfp,
	"graph %s.gif %s -v \"%s%s\" --start %d --end %d --height 300 --title \"%s %s %s\" ",
	gif, percentstring, units, stack, utc_start, utc_end, host, vtitle, time_and_date);

	vars = count;

	if(debug) for(i=0;i<vars;i++) 
		printf("arr=<%s>\n",fields[i]);

	i=0;
	fprintf(gfp,
		"DEF:%s=%s.rrd:%s:AVERAGE %s:%s#%s:\"%s\" ",
		fields[i],rrdname,fields[i], t1, fields[i], colour(i),fields[i]);
	for(i=1;i<vars;i++) {
		if(debug)printf( "DEF:%s=%s.rrd:%s:AVERAGE %s:%s#%s:\"%s\" \n",
			fields[i],rrdname,fields[i], t2, fields[i], colour(i),fields[i]);
		fprintf(gfp,
		"DEF:%s=%s.rrd:%s:AVERAGE %s:%s#%s:\"%s\" ",
		fields[i],rrdname,fields[i], t2, fields[i], colour(i),fields[i]);
	}
	fprintf(gfp,"\n");
}


void rrdcreate(char **arr, int vars,  char *rrdname )
{
int i;
	if(cfp == NULL){
		sprintf(filename,"%s/%s",dirname,"rrd_create");
		cfp = fopen(filename,"w");
		if(cfp==NULL) {
			perror("failed to open file");
			printf("file: \"%s\"\n",filename);
			exit(74);
		}
        }

	fprintf(cfp,"create %s.rrd --start %d --step %d  ", rrdname,utc_start,interval);
	for(i=0;i<vars;i++)
		fprintf(cfp,"DS:%s:GAUGE:%d:U:U ",arr[i],snapshots);
	fprintf(cfp," RRA:AVERAGE:0.5:1:%d\n",snapshots);
}

void file_io_end()
{
	fclose(cfp);
	fclose(gfp);
	fclose(wfp);
	fclose(ufp);
}


int founds=0;
char **found = (char **)0;
int foundmax;

int findfirst(char *s) {
int i;
	for(i=0;i<linemax;i++) {
		if(debug)printf("compare <%s> with <%s>\n",s,line[i]);
		if( strstr(line[i],s))
			return i;
	}
	return -1;
}

int find(char *s) {
int i;
	foundmax=0;
	for(i=0;i<linemax;i++) {
		if(debug)printf("compare <%s> with <%s>\n",s,line[i]);
		if( strstr(line[i],s))
			foundmax++;
	}
	printf("found %s %d times\n",s,foundmax);

	if(founds == 0) {
		printf("find malloc %d\n", sizeof( char *) * 1024);
	 	found = (char **)malloc(sizeof( char *) * 1024);
		founds = 1024;
	} 
	if(foundmax > founds) {
		printf("find realloc %d\n", sizeof( char *) * foundmax);
	 	found = (char **)realloc((void *)found, sizeof(char *)*(foundmax+1));
		founds = foundmax;
	}
	foundmax=0;
	for(i=0;i<linemax;i++)
		if( strstr(line[i],s)) {
			found[foundmax] = line[i];
			foundmax++;
		}
	return foundmax;
}

void straddch(char *s, char ch)
{
int len = strlen(s);
	s[len] = ch;
	s[len+1] = 0;
}

replace1(char *orig, char *old, char *new)
{
int j;
int len;
int oldlen;
char *s;
	s = malloc(longest);
	oldlen=strlen(old);
		strcpy(s,orig);
		orig[0]=0;
		len=strlen(s);
		for(j=0;j<len;j++) {
			if( !strncmp(&s[j],old,oldlen)) {
				strcat(orig,new);
				j = j + oldlen -1;
			} else
				straddch(orig,s[j]);
		}
		if(debug)printf("replaced %s with %s\n",s,orig);
	free(s);
}

void run(char *cmd)
{
	printf("%s\n",cmd);
	system(cmd);
}

hint()
{
	printf("nmon2rrd -f nmonfile [-d directory] [-x] \n");
	printf("\t -f nmonfile    the regular CSV nmon output file\n");
	printf("\t -d directory   dirname for the output\n");
	printf("\t -x             execute the output files\n");
	printf("Example:\n");
	printf(" nmon2rrd -f m1_030811_1534.nmon -dir /webpages/docs/m1/030811 -x \n");
	exit(42);
}


int main(int argc, char ** argv)
{
int i;
int j;
int k;
int len;
char *s;
int cpus;
int cpus2;
int thour,tmins,tsecs,tnum;
float busy = 0.0;
int hour,mins,secs;
int day, month,year;
int n;
struct tm *timp;
time_t timt;
char string1[1024];
char string2[1024];
int missing;
int disksects;
char * progname;
char * nmonversion;
char * user;
char * runname;
char * hardware;
char * kernel;
char * aix;
int a_net_size;
int a_jfs_size;
int a_ess_size;
int a_dg_size;
int a_ioa_size;
char **a_net;
char **a_jfs;
char **a_jfsdummy;
char **a_ess;
char **a_dg;
char **a_ioa;
int a_disk_size[128];
char **a_disk[128];
FILE *fp;
int file_arg=1;
int execute=0;
int top_found=0;
int ess_found=0;
int dg_found=0;
int short_style=0;
char *infile = NULL;

        if(getenv("NMON2RRDDEBUG") != 0) debug++;
        if(getenv("NMON2RRDDEBUG2") != 0) debug2++;

	for(i=0;i<ARRAYMAX;i++)
		array[i] = malloc(ARRAYWIDTH);

	line = (char **)malloc(sizeof(char *)*1024);

	while ( -1 != (i = getopt(argc, argv, "?f:d:x" ))) {
                switch (i) {
                case '?':
                        hint();
                        exit(0);
			break;
		case 'x': 
			execute++;
			break;
		case 'f':
			infile=optarg;
			break;
		case 'd':
			strcpy(dirname,optarg);
			break;
		}
	}
	if(infile == NULL) {
		printf("Error: nmon filename missing\n");
		hint();
	}
        if( (fp = fopen(infile,"r")) == NULL){
                perror("failed to open file");
                printf("file: \"%s\"\n",infile);
		exit(75);
        }

	for(i=0;fgets(string,STRLEN,fp)!= NULL;i++) {
		if(i >= lines) {
			lines +=1024;
			line = (char **)realloc((void *)line, sizeof(char *)*lines);
		}
		if(string[strlen(string)-1] == '\n')
			string[strlen(string)-1] = 0;
		if(string[strlen(string)-1] == '\r')
			string[strlen(string)-1] = 0;
		if(string[strlen(string)-1] == ' ')
			string[strlen(string)-1] = 0;
		if(string[strlen(string)-1] == ',')
			string[strlen(string)-1] = 0;
		len=strlen(string)+1;
		if(len>longest)
			longest = len;
		s=malloc(len);
		strcpy(s,string);
		line[i] = (char *)s;
	}
	linemax = i;

	if(debug)for(i=0;i<linemax;i++)
		printf("line %d %s\n",i,line[i]);

	n = findfirst("AAA,progname");
	if(n == -1) {
		printf("ERROR: This does not appear to be regular nmon capture file\n");
		printf("ERROR: Can't find line starting \"AAA,progname\"\n");
		printf("ERROR: nmon2rrd does NOT use the rrd nmon output format\n");
		exit(33);
	}
	progname=&line[n][13];
	printf("progname=%s\n",progname);

	n = findfirst("AAA,version");
	nmonversion=&line[n][13];
	printf("nmonversion=%s\n",nmonversion);
	if( nmonversion[0] == '5') short_style=1;

	/* AAA,host,aix10 */
	n = findfirst("AAA,host");
	host=&line[n][9];
	printf("host=%s\n",host);

	/* AAA,user,root */
	n = findfirst("AAA,user");
	user=&line[n][9];
	printf("user=%s\n",user);

	/* AAA,runname,aix10 */
	n = findfirst("AAA,runname");
	runname=&line[n][12];
	printf("runname=%s\n",runname);

	/* AAA,AIX,4.3.3.84 */
	n = findfirst("AAA,AIX");
	aix=&line[n][8];
	printf("aix=%s\n",aix);

	/* AAA,hardware,XXX */
	n = findfirst("AAA,hardware");
	hardware=&line[n][13];
	printf("hardware=%s\n",hardware);

	/* AAA,kernel,XXX */
	n = findfirst("AAA,kernel");
	kernel=&line[n][11];
	printf("kernel=%s\n",kernel);

	/* AAA,interval,10 */
	n = findfirst("AAA,interval");
	sscanf(line[n],"AAA,interval,%d",&interval);
	printf("interval=%d\n",interval);

	/* AAA,snapshots,300 */
	n = findfirst("AAA,snapshots");
	sscanf(line[n],"AAA,snapshots,%d",&snapshots);
	printf("snapshots=%d\n",snapshots);
	snapshots++; /* make sure rrd does not compress data */
	if(snapshots > 1024) {
		printf("WARNING: truncating to 1024 snapshots (not the %d found in the nmon file)\n",snapshots);
		snapshots=1024;
	}

	/* AAA,cpus,12 */
	n = findfirst("AAA,cpus");
	sscanf(line[n],"AAA,cpus,%d,%d",&cpus,&cpus2);
	printf("cpus=%d\n",cpus);


	/* AAA,time,09:19.48 */
	n = findfirst("AAA,time");
	sscanf(line[n],"AAA,time,%d:%d.%d",&hour,&mins,&secs);
	printf("hour=%d minutes=%d seconds%d\n",hour,mins,secs);

	/* AAA,date,22/04/03 */
	n = findfirst("AAA,date");
	sscanf(line[n],"AAA,date,%d/%d/%d",&day,&month,&year);
	printf("day=%d month=%d year%d\n",day,month,year);

	timt = time(0);
	timp = localtime(&timt);
	if(debug)printf("%d:%02d.%02d %02d/%02d/%04d = %ld\n",
			timp->tm_hour,
			timp->tm_min,
			timp->tm_sec,
			timp->tm_mday,
			timp->tm_mon+1,
			timp->tm_year+1900,timt);	
	timp->tm_sec =secs;
	timp->tm_min =mins;
	timp->tm_hour=hour; 
	timp->tm_mday=day; 
	timp->tm_mon =month-1;
	timp->tm_year=year+100;

	timt = mktime(timp);
	if(debug)printf("%d:%02d.%02d %02d/%02d/%04d = %ld\n",
			timp->tm_hour,
			timp->tm_min,
			timp->tm_sec,
			timp->tm_mday,
			timp->tm_mon+1,
			timp->tm_year+1900,timt);	
	if(debug)printf("%ld\n", timt);	
	sprintf(time_and_date,"%d:%02d.%02d %02d/%02d/%04d",
			timp->tm_hour,
			timp->tm_min,
			timp->tm_sec,
			timp->tm_mday,
			timp->tm_mon+1,
			timp->tm_year+1900);	
	utc_start = (int)timt;
	utc_end   = (int)timt + interval*(snapshots +1);

	/* process ZZZZ sections */
	n = find("ZZZZ,T");
	for(i=0;i<n;i++) {
		sscanf(found[i],"ZZZZ,T%d,%d:%d:%d", &tnum, &thour, &tmins, &tsecs);
		if(debug2) {
		 printf("found T=T%04d %02d %02d %02d",tnum, thour,tmins,tsecs);
		 printf(" %02d %02d %02d\n",day,month,year);
		}
		tarray[tnum]=utc(tsecs,tmins,thour,day,month-1,year+100);
		if(debug2)printf("utc=%ld\n",tarray[tnum]);
	}

        start_top(snapshots);
	top_found = n = find("TOP,");
	if(top_found) {
	   for(k=0;k<n;k++) {
               if(isdigit(found[k][4])){
                        if( (i = search_for_tstring(found[k])) != 0) {
                                tnum=-1;
                                busy=-1.0;
                                sscanf(&found[k][i+1],"%d,%f",&tnum,&busy);
                                if(tnum== -1 || busy == -1.0) {
                                        printf("nmon2rrd: top section scanf failed - %s\n",string);
                                        continue;
                                }

                                for(i=i+5;i<strlen(found[k]);i++) {
                                        if(isalpha(found[k][i])) {
                                               for(j=i;j<strlen(found[k]);j++) {
                                                        if(found[k][j]==',')
                                                                found[k][j]=0;
                                               }
                                               save_top(tnum,busy,&found[k][i]);
                                               break;
                                         }
                                }
                        }
		}
             }
         end_top();
         }
	n = findfirst("NET,Network");
	replace1(line[n]," ","");
	replace1(line[n],","," ");
	replace1(line[n],"-read-KB/s","");
	replace1(line[n],"-read-kB/s","");
	a_net_size=str2array(2,line[n]);
	if(debug)for(i=0;i< a_net_size/2;i++)
		printf("networknames are = %s\n",array[i]);
	a_net = malloc(sizeof(char *)*a_net_size);
	for(i=0;i< a_net_size/2;i++) {
		a_net[i] = malloc(strlen(array[i])+1+5);
		strcpy(a_net[i],array[i]);
		strcat(a_net[i],"_read");
		
		a_net[i+a_net_size/2] = malloc(strlen(array[i])+1+6);
		strcpy(a_net[i+a_net_size/2],array[i]);
		strcat(a_net[i+a_net_size/2],"_write");
	}
	if(debug)for(i=0;i< a_net_size;i++) 
		printf("net are = %s\n",a_net[i]);

	n = findfirst("JFSFILE,JFS");
	replace1(line[n]," ","");
	replace1(line[n],","," ");
/*
	replace1(line[n],"/","X");
	replace1(line[n],"filesystem","fs");
	replace1(line[n],"oracle","ora");
	replace1(line[n],"archiving","A");
	replace1(line[n],"sap","S");
*/
	a_jfs_size=str2array(2,line[n]);
	a_jfs = malloc(sizeof(char *)*(a_jfs_size));
	a_jfsdummy = malloc(sizeof(char *)*(a_jfs_size));
	for(i=0;i< a_jfs_size;i++) {
		a_jfs[i] = malloc(strlen(array[i])+1);
		strcpy(a_jfs[i],array[i]);
		a_jfsdummy[i] = malloc(6);
		sprintf(a_jfsdummy[i],"fs%03d",i+1);
	}
	if(debug)for(i=0;i< a_jfs_size;i++) 
		printf("jfs are = %s\n",a_jfs[i]);

	for(missing=0,i=1;!missing;i++) {
		sprintf(string1,"DISKBUSY%d",i);
		missing = findfirst(string1);	
	}
	disksects = i -1;
	printf("Found %d DISKBUSY Sections\n",disksects);

    for(j=0;j<disksects;j++) {
	if(j==0)
		strcpy(string1,"DISKBUSY,");
	else
		sprintf(string1,"DISKBUSY%d",j);
	n = findfirst(string1);
	replace1(line[n],"%","");
	replace1(line[n]," ","");
	replace1(line[n],","," ");
	a_disk_size[j]=str2array(2,line[n]);
	a_disk[j] = malloc(sizeof(char *)*(a_disk_size[j]));
	for(i=0;i< a_disk_size[j];i++) {
		a_disk[j][i] = malloc(strlen(array[i])+1);
		strcpy(a_disk[j][i],array[i]);
	}
	if(debug)for(i=0;i< a_disk_size[j];i++) 
		printf("disk%d are = %s\n",j,a_disk[j][i]);
    }

	n = findfirst("DGBUSY,Disk");
	if(n != -1) dg_found=1;
    if(dg_found) {
	if(debug)printf("DG <%s>\n",line[n]);
	replace1(line[n]," ","");
	replace1(line[n],","," ");
	if(debug)printf("replaced <%s>\n",line[n]);
	a_dg_size=str2array(2,line[n]);
	if(debug)printf("size=%d\n",a_dg_size);
	a_dg = malloc(sizeof(char *)*(a_dg_size));
	for(i=0;i< a_dg_size;i++) {
		a_dg[i] = malloc(strlen(array[i])+1);
		strcpy(a_dg[i],array[i]);
	}
	if(debug)for(i=0;i< a_dg_size;i++) 
		printf("dg are = %s\n",a_dg[i]);
    }
	n = findfirst("ESSREAD,ESS");
	if(n != -1) ess_found=1;
    if(ess_found) {
	if(debug)printf("ESS <%s>\n",line[n]);
	replace1(line[n],"KB/s","");
	replace1(line[n]," ","");
	replace1(line[n],","," ");
	if(debug)printf("replaced <%s>\n",line[n]);
	a_ess_size=str2array(2,line[n]);
	if(debug)printf("size=%d\n",a_ess_size);
	a_ess = malloc(sizeof(char *)*(a_ess_size));
	for(i=0;i< a_ess_size;i++) {
		a_ess[i] = malloc(strlen(array[i])+1);
		strcpy(a_ess[i],array[i]);
	}
	if(debug)for(i=0;i< a_ess_size;i++) 
		printf("ess are = %s\n",a_ess[i]);
    }
	n = findfirst("IOADAPT,Disk");
	replace1(line[n]," ","");
	replace1(line[n],","," ");
	replace1(line[n],"-KB/s","");
	replace1(line[n],"-kB/s","");
	replace1(line[n],"xfer-","");
	a_ioa_size=str2array(2,line[n]);
	a_ioa = malloc(sizeof(char *)*(a_ioa_size));
	for(i=0;i< a_ioa_size;i++) {
		a_ioa[i] = malloc(strlen(array[i])+1);
		strcpy(a_ioa[i],array[i]);
	}
	if(debug)for(i=0;i< a_ioa_size;i++) 
		printf("ioadapt are = %s\n",a_ioa[i]);

	rrdcreate(a_cpu,a_cpu_size ,"cpu_all");

	if(cpus > 1) for(i=1;i<=cpus;i++) {
		sprintf(string2,"cpu%02d",i);
		rrdcreate(a_cpu,a_cpu_size,string2);
	}

	rrdcreate(a_mem,a_mem_size,"mem");
	rrdcreate(a_memuse,a_memuse_size,"memuse");
	if(short_style) {
		rrdcreate(a_page,a_page_size-3,"page");
		rrdcreate(a_proc,a_proc_size-2,"proc");
	} else {
		rrdcreate(a_page,a_page_size,"page");
		rrdcreate(a_proc,a_proc_size,"proc");
	}
	rrdcreate(a_file,a_file_size,"file");

	rrdcreate(a_net,a_net_size,"net");
    for(j=0;j<disksects;j++) {
	sprintf(string2,j?"diskbusy%d":"diskbusy",j);
	rrdcreate(a_disk[j],a_disk_size[j],string2);
	sprintf(string2,j?"diskread%d":"diskread",j);
	rrdcreate(a_disk[j],a_disk_size[j],string2);
	sprintf(string2,j?"diskwrite%d":"diskwrite",j);
	rrdcreate(a_disk[j],a_disk_size[j],string2);
	sprintf(string2,j?"diskxfer%d":"diskxfer",j);
	rrdcreate(a_disk[j],a_disk_size[j],string2);
	sprintf(string2,j?"diskbsize%d":"diskbsize",j);
	rrdcreate(a_disk[j],a_disk_size[j],string2);
    }
	rrdcreate(a_jfsdummy,a_jfs_size,"jfsfile");
	rrdcreate(a_jfsdummy,a_jfs_size,"jfsinode");
	rrdcreate(a_ioa,a_ioa_size,"ioadapt");

	if(dg_found) {
	rrdcreate(a_dg,a_dg_size,"dgbusy");
	rrdcreate(a_dg,a_dg_size,"dgread");
	rrdcreate(a_dg,a_dg_size,"dgwrite");
	rrdcreate(a_dg,a_dg_size,"dgsize");
	rrdcreate(a_dg,a_dg_size,"dgxfer");
	}
	if(ess_found) {
	rrdcreate(a_ess,a_ess_size,"essread");
	rrdcreate(a_ess,a_ess_size,"esswrite");
	rrdcreate(a_ess,a_ess_size,"essxfer");
	}


	/* webhead */
        sprintf(filename,"%s/%s",dirname,"index.html");
        if( (wfp = fopen(filename,"w")) == NULL){
                perror("failed to open file");
                printf("file: \"%s\"\n",filename);
                exit(75);
        }

		
	fprintf(wfp,"<HTML><TITLE>%s %02d/%02d/%02d %02d:%02d.%02d</TITLE><BODY>\n",host,day,month,year,hour,mins,secs);
	fprintf(wfp,"<H1>%s %02d/%02d/%02d %02d:%02d.%02d</H1>\n",
		host,day,month,year,hour,mins,secs);
	fprintf(wfp,"<OL>\n");
	fprintf(wfp,"<LI>Hostname: %s\n",host);
	fprintf(wfp,"<LI>Date: %02d/%02d/%02d\n", day,month,year);
	fprintf(wfp,"<LI>Time: %02d:%02d.%02d\n", hour,mins,secs);
	fprintf(wfp,"<LI>AIX: %s\n",aix);
	fprintf(wfp,"<LI>Runname: %s\n",runname);
	fprintf(wfp,"<LI>Interval: %d\n",interval);
	fprintf(wfp,"<LI>Snapshots: %d\n",snapshots);
	fprintf(wfp,"<LI>Hardware: %s\n",hardware);
	fprintf(wfp,"<LI>Kernel: %s\n", kernel);
	fprintf(wfp,"<LI>CPU (start/now): %d/%d\n",cpus,cpus2);
	fprintf(wfp,"<LI>Version of nmon: %s\n",nmonversion);
	fprintf(wfp,"<LI>Version of nmon2rrd: %s\n",VERSION);
	fprintf(wfp,"<LI>User: %s\n",user);
	fprintf(wfp,"</OL>\n");

rrdgraph(a_cpu,a_cpu_size,"cpu_all", "cpu_all", PERCENT,  "CPU Utilisation", AREA,"Percent");

	fprintf(wfp,"<BR>\n");
    if(top_found) {
	fprintf(wfp,"<H3>TOP Processes (note: 1 CPU = 100%, 2 CPU = 200%, etc.)</H3>\n");

	/* generate web page top table with this */
        fprintf(wfp,"<table border=1><tr><th>Process Name<th>CPU Percent</tr>\n");
        for(i=0;i<TOP_PROCESSES/4;i++) {
                if( topname[i].cpu < 0)
                        break;
                fprintf(wfp,"<tr>\n");
                        for(j=0;j<4;j++) {
                        if( topname[i+j*5].cpu < 0)
                                break;
                        fprintf(wfp,"<td>%s<td>%7.2f\n", topname[i+j*5].name, topname[i+j*5].cpu/snapshots);
                }
        }
        fprintf(wfp,"</table>\n");

        for(i=0;i<TOP_PROCESSES;i++) {
                if( topname[i].cpu < 0) {
                        sprintf(array[i],"none%d",i);
		}
		else
			strcpy(array[i],topname[i].name);
        }
rrdcreate(array,TOP_PROCESSES,"top");
rrdgraph(array,TOP_PROCESSES,"top", "tops", ANY, "Top Processes", AREA,"Percent of one CPU");
rrdgraph(array,TOP_PROCESSES,"top", "top", ANY,  "Top Processes", LINE,"Percent of one CPU");

	fprintf(wfp, "<br>\n");
    }
	fprintf(wfp, "<H3>Memory</H3>\n");

strcpy(array[0],"RealFree");
rrdgraph(array, 1, "mem","mem1",PERCENT, "Memory Free Percent",LINE,"Percent");
strcpy(array[0],"VirtualFree");
rrdgraph(array,1, "mem","mem2",PERCENT, "Virtual Memory Free Percent",LINE,"Percent");

strcpy(array[0],"RealFreeMB");
rrdgraph(array, 1, "mem","mem3",ANY, "Memory Free Size",LINE,"MBytes");
strcpy(array[0],"VirtualFreeMB");
rrdgraph(array,1, "mem","mem4",ANY, "Virtual Memory Free Size",LINE,"MBytes");

strcpy(array[0],"RealMB");
rrdgraph(array, 1, "mem","mem5",ANY, "Whole Memory Size",LINE,"MBytes");
strcpy(array[0],"VirtualMB");
rrdgraph(array,1, "mem","mem6",ANY, "Whole Virtual Memory Size",LINE,"MBytes");

/* now in own graphs
rrdgraph(a_mem,a_mem_size, "mem","mem7",ANY, "Memory Utilisation",LINE,"Various");
rrdgraph(a_memuse,a_memuse_size, "memuse","mem8",ANY, "Memory Use",LINE,"Various");
*/
strcpy(array[0],"maxperm");
strcpy(array[1],"minperm");
strcpy(array[2],"numperm");
rrdgraph(array,3, "memuse","mem9",PERCENT, "Memory Filesystem Cache",LINE,"Percent");
strcpy(array[0],"minfree");
strcpy(array[1],"maxfree");
rrdgraph(array,2, "memuse","mem10",ANY, "Memory Freelist",LINE,"Blocks");

	fprintf(wfp, "<br>\n");
	fprintf(wfp, "<H3>Paging</H3>\n");
rrdgraph(a_page,a_page_size, "page","page",ANY, "Paging",LINE,"Pages per second");
	fprintf(wfp, "<br>\n");
	fprintf(wfp, "<H3>Process Stats</H3>\n");
/* now own graphs 
rrdgraph(a_proc,a_proc_size, "proc","proc",ANY, "Proc Stats",LINE,"Various");
*/
strcpy(array[0],"Runnable");
rrdgraph(array,1, "proc","procrunq",ANY, "Run Queue",LINE,"Process on Queue");
strcpy(array[0],"Swapin");
rrdgraph(array,1, "proc","swapin",ANY, "Swapin",LINE,"Operations per second");
strcpy(array[0],"pswitch");
rrdgraph(array,1, "proc","pswitch",ANY, "Process Switch",LINE,"Per Second");
strcpy(array[0],"syscall");
rrdgraph(array,1, "proc","syscall",ANY, "System Calls",LINE,"Per Second");
strcpy(array[0],"read");
strcpy(array[1],"write");
rrdgraph(array,2, "proc","readwrite",ANY, "System Calls(read/write)",LINE,"Per Second");
strcpy(array[0],"fork");
strcpy(array[1],"exec");
rrdgraph(array,2, "proc","forkexec",ANY, "System Calls(fork/exec)",LINE,"Per Second");
strcpy(array[0],"sem");
strcpy(array[1],"msg");
rrdgraph(array,2, "proc","ipc",ANY, "System Calls(sem/msg)",LINE,"Per Second");

	fprintf(wfp, "<br>\n");
	fprintf(wfp, "<H3>Filesystem</H3>\n");
strcpy(array[0],"iget");
strcpy(array[1],"namei");
strcpy(array[2],"dirblk");
rrdgraph(array,3, "file","file",ANY, "File System functions",LINE,"Per Second");
strcpy(array[0],"readch");
strcpy(array[1],"writech");
rrdgraph(array,2, "file","filerw",ANY, "File System read/write",LINE,"Per Second");

	fprintf(wfp, "<br>\n");
	fprintf(wfp, "<H3>Filesystem Use</H3>\n");
	fprintf(wfp, "<table border=1><tr><th>Filesystem Number</th><th>Mount Point</th></tr>\n");
	for(i=0;i<a_jfs_size;i++) {
		fprintf(wfp,"<tr><td>%s</td><td>%s</td></tr>\n",a_jfsdummy[i],a_jfs[i]);
	}
	fprintf(wfp, "</table>\n");

rrdgraph(a_jfsdummy,a_jfs_size, "jfsfile","jfsfile",PERCENT, "JFS Percent Full",LINE,"Percent");
rrdgraph(a_jfsdummy,a_jfs_size, "jfsinode","jfsinode",PERCENT, "JFS Inode Percent Full",LINE,"Percent");

	fprintf(wfp, "<br>\n");
	fprintf(wfp, "<H3>Network</H3>\n");
rrdgraph(a_net,a_net_size, "net","nettotal",ANY, "Network",AREA,"Kbytes per second");
rrdgraph(a_net,a_net_size, "net","net",ANY, "Network",LINE,"Kbytes per second");

	fprintf(wfp, "<br>\n");
	fprintf(wfp, "<H3>Disk Adapter</H3>\n");
rrdgraph(a_ioa,a_ioa_size, "ioadapt","iototal",ANY, "Disk Adapter",AREA,"Kbytes per second");
rrdgraph(a_ioa,a_ioa_size, "ioadapt","ioadapt",ANY, "Disk Adapter",LINE,"Kbytes per second");

	fprintf(wfp, "<br>\n");
    if(dg_found) {
	fprintf(wfp, "<H3>Disk Group</H3>\n");
rrdgraph(a_dg,a_dg_size, "dgbusy","dgbusy",	PERCENT, "Disk Group Busy",LINE,"Percent");
rrdgraph(a_dg,a_dg_size, "dgsize","dgsize",	ANY, "Disk Group Block Size",LINE,"KBytes");
rrdgraph(a_dg,a_dg_size, "dgread","dgreadtotal",ANY, "Disk Group Read",AREA,"KBytes per second");
rrdgraph(a_dg,a_dg_size, "dgread","dgread",	ANY, "Disk Group Read",LINE,"KBytes per second");
rrdgraph(a_dg,a_dg_size, "dgwrite","dgwritetotal",ANY, "Disk Group Write",AREA,"KBytes per second");
rrdgraph(a_dg,a_dg_size, "dgwrite","dgwrite",	ANY, "Disk Group Disk Group",LINE,"KBytes per second");
rrdgraph(a_dg,a_dg_size, "dgxfer","dgxfertotal",ANY, "Disk Group Transfers",AREA,"Transfers per second");
rrdgraph(a_dg,a_dg_size, "dgxfer","dgxfer",	ANY, "Disk Group Transfers",LINE,"Transfers per second");
	fprintf(wfp, "<br>\n");
    }
    if(ess_found) {
	fprintf(wfp, "<H3>ESS</H3>\n");
rrdgraph(a_ess,a_ess_size, "essread","essreadtotal",	ANY, "ESS Read",AREA,"KBytes per second");
rrdgraph(a_ess,a_ess_size, "essread","essread",		ANY, "ESS Read",LINE,"KBytes per second");
rrdgraph(a_ess,a_ess_size, "esswrite","esswritetotal",	ANY, "ESS Write",AREA,"KBytes per second");
rrdgraph(a_ess,a_ess_size, "esswrite","esswrite",	ANY, "ESS Write",LINE,"KBytes per second");
rrdgraph(a_ess,a_ess_size, "essxfer","essxfertotal",	ANY, "ESS Transfers",AREA,"Transfers per second");
rrdgraph(a_ess,a_ess_size, "essxfer","essxfer",		ANY, "ESS Transfers",LINE,"Transfers per second");
	fprintf(wfp, "<br>\n");
    }
	fprintf(wfp, "<H3>Disks</H3>\n");
    for(j=0;j<disksects;j++) {
	fprintf(wfp, "<H4>Disks Set %d</H4>\n",j);
	sprintf(string2,j?"diskbusy%d":"diskbusy",j);
	rrdgraph(a_disk[j],a_disk_size[j], string2,string2,PERCENT, "DISK Busy",LINE,"Percent");
	sprintf(string2,j?"diskbsize%d":"diskbsize",j);
	rrdgraph(a_disk[j],a_disk_size[j], string2,string2,ANY, "DISK Block Size",LINE,"KBytes");

	sprintf(string1,j?"diskread%d":"diskread",j);
	sprintf(string2,j?"diskread%dtotal":"diskreadtotal",j);
	rrdgraph(a_disk[j],a_disk_size[j], string1,string2,ANY, "DISK Read",AREA,"KBytes per second");
	rrdgraph(a_disk[j],a_disk_size[j], string1,string1,ANY, "DISK Read",LINE,"KBytes per second");

	sprintf(string1,j?"diskwrite%d":"diskwrite",j);
	sprintf(string2,j?"diskwrite%dtotal":"diskwritetotal",j);
	rrdgraph(a_disk[j],a_disk_size[j], string1,string2,ANY, "DISK Write",AREA,"KBytes per second");
	rrdgraph(a_disk[j],a_disk_size[j], string1,string1,ANY, "DISK Write",LINE,"KBytes per second");

	sprintf(string1,j?"diskxfer%d":"diskxfer",j);
	sprintf(string2,j?"diskxfer%dtotal":"diskxfertotal",j);
	rrdgraph(a_disk[j],a_disk_size[j], string1,string2,ANY, "DISK Transfers",AREA,"Transfers per second");
	rrdgraph(a_disk[j],a_disk_size[j], string1,string1,ANY, "DISK Transfers",LINE,"Transfers per second");
    }

	/* webtail */
	fprintf(wfp,"</BODY></HTML>\n");
	fclose(wfp);


        sprintf(filename,"%s/%s",dirname,"rrd_update");
        if( (ufp = fopen(filename,"w")) == NULL){
                perror("failed to open file");
                printf("file: \"%s\"\n",filename);
                exit(75);
        }

	for(j=0;j<lines;j++) {
                if( !strncmp( line[j], "UARG",4) ) continue;
                if( !strncmp( line[j], "TOP", 3) ) continue;
                if( !strncmp( line[j], "BBB", 3) ) continue;
                if( !strncmp( line[j], "ZZZZ",4) ) continue;
                if( !strncmp( line[j], "CPU01",5) && cpus == 1) continue;

                if( (i = search_for_tstring(line[j])) != 0) {
                        sscanf(&line[j][i+1],"%d",&tnum);
                        if( string[strlen(line[j])-1] == '\n') {
                                string[strlen(line[j])-1] = 0;
                        }
                        if( string[strlen(line[j])-1] == ',') {
                                string[strlen(line[j])-1] = 0;
                        }
                        for(s=line[j];*s!=0;s++) {
                                if( *s == ',' && *(s+1) == ',') {
                                        *(s)=0; /* truncate at missing data - helps CPU_ALL */
                                }
                                if(*s == ',')
                                        *s = ':';
                        }
                        line[j][i-1]=0; /* -1 so we hit the , */
                        for(s=line[j];*s!=0;s++) {
                                *s = tolower(*s);
                        }
                        fprintf(ufp,"update %s.rrd %ld:%s\n",line[j],tarray[tnum],&line[j][i+6]);
                }
	}
	file_io_end();
	if(execute) {
		chdir(dirname);
		run("rm -f *.rrd");
		run("rm -f *.gif");
		run("rrdtool - < rrd_create");
		run("rrdtool - < rrd_update >rrd_update.log");
		if(top_found)
			run("rrdtool - < rrd_top >rrd_top.log"); 
		run("rrdtool - < rrd_graph");
	}
	return 0;
}
