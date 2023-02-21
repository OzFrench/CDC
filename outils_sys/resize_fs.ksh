#!/usr/bin/ksh
SID1="HP8"
SID2="HO9"
lsfs | grep "/oracle/"$SID_SRC| grep jfs2 | awk '{ print "lsfs "$3" >/dev/nul 2>&1\nif [ $? -eq 0 ]\nthen\nN=$(lsfs "$3"|tail -1 | awk SEP{ print $5 }SEP)\nif [ $N -lt "$5" ]\nthen\necho chfs -a size="$5" "$3"\nfi\nfi" }'| sed "s?SEP?'?g"|\
sed 's?HP8?HO9?g'
