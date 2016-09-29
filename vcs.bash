#!/bin/bash
for i in *.flv
do
vcs-1.13.2.sh -i 15 -c 5 "$i"
done
for i in *.png
do
convert -resize 50% "$i" "${i%%.png}.jpg"
rm "$i"
done
