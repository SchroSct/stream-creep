#!/bin/bash
#Numbers data collected by tcpflow/rtmprec.bash into 'part###' files then converts to flv.  Creates photo gallery.
##requires netcat rtmpdump
let n=1 ; for i in $(find -printf "%C@ %p\n"|sort | sed -e 's/.*\.\///g' | grep -v " .") ; do mv -vn "$i" "part$(printf %03d ${n}).${i}" ; let n=$n+1 ; done
for i in *
do
cat "$i" | netcat -l 1935 &
netcatID="$!"
sleep 3
rtmpdump -r "rtmp://127.0.0.1$PWD/$i" -c 1935 -o "$i.flv"
kill "$netcatID"
done
reset
clear
find . -size 0 -delete
vcs.bash
