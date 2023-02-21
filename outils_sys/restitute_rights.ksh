#!/usr/bin/ksh
evaluate()
{
rflag="$1"
res="n"
T=0
case "$rflag" in
"---") res="0"; break ;;
"--x") res="1"; break ;;
"-w-") res="2"; break ;;
"-wx") res="3"; break ;;
"r--") res="4"; break ;;
"r-x") res="5"; break ;;
"rw-") res="6"; break ;;
"rwx") res="7"; break ;;
"--t") res="0"; T=1; break ;;
"-wt") res="2"; T=1; break ;;
"r-t") res="4"; T=1; break ;;
"rwt") res="6"; T=1; break ;;
"--s") res="7"; T=1; break ;;
"-ws") res="2"; T=1; break ;;
"r-s") res="4"; T=1; break ;;
"rws") res="6"; T=1; break ;;
esac
echo "$res $T"
}
#set -x
# Pour chaque FS local
for fs in $(/usr/sysv/bin/df -al|egrep "sap|ora|exploit"  | awk '{ print $1 }' | egrep -v "/etc|/tmp|/proc|/var|/opt|/usr/lpp/OV|/teledist")
do
# Pour chaque fichier ou repertoire
find $fs -xdev \( -type f -o -type d \) -exec ls -ld {} \; |\
awk '{ printf("%10s %8s:%-8s %s\n",$1,$3,$4,$NF) }'|&
while read -p ligne
do
FICHIER=$(echo $ligne|awk '{ print $3 }')
FOWNER=$(echo $ligne|awk '{ print $2}')
let T=0
RES=$(evaluate $(echo "$ligne" |cut -c2-4|tr "A-Z" "a-z") )
set $RES
U=$(expr $1 \* 100 )
T=$(expr $2 \* 4000 )
R=$(expr $U \+ $T )
RES=$(evaluate $(echo "$ligne" |cut -c5-7| tr "A-Z" "a-z"))
set $RES
U=$(expr $1 \* 10 )
T=$(expr $2 \* 2000 )
R=$(expr $U \+ $T \+ $R )
RES=$(evaluate $(echo "$ligne" |cut -c8-10| tr "A-Z" "a-z"))
set $RES
U=$(expr $1 \* 1 )
T=$(expr $2 \* 1000 )
R=$(expr $U \+ $T \+ $R )
#------ Pour debuger sinon commenter les lignes ci-dessous sauf chmod
#echo "#------------------------------------------------------------------"
#[ $U = "n" -o $G = "n" -o $O = "n" ]&& ls -ld $FICHIER
# ls -ld $FICHIER
printf "chmod %d %s\n" $R "$FICHIER"
printf "chown %s %s\n" "$FOWNER" "$FICHIER"
done 
done
