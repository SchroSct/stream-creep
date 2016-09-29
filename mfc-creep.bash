#!/bin/bash
#Monitors the model page for being 'online' and then spawns firefox instances to activate the stream.
##Requires curl, xvfb, firefox, flashplugin-installer, pgrep
mname="$1"
dur="600"
check(){
echo "${model}"
site="http://profiles.myfreecams.com/${model}"
status=$(curl -s "$site" | grep -e "profileState" | sed -e 's/.*:\"//g' -e 's/\".*//g')
while [[ "$status" == "Offline" ]]
do
	echo "${model} MyFreeCams $status (offline) $(date)"
	let random=$RANDOM%360
	let sleepy=45+$random
	echo "sleeping $sleepy"
	sleep $sleepy
	status=$(curl -s "$site" | grep -e "profileState" | sed -e 's/.*:\"//g' -e 's/\".*//g')
done

while [[ ! "$status" == "Online" ]]&&[[ "$status" != "Offline" ]]
do
	echo "${model} $status on $(date)"
	let sleepy=$RANDOM%60
	echo "sleeping $sleepy"
	sleep $sleepy
	status=$(curl -s "$site" | grep -e "profileState" | sed -e 's/.*:\"//g' -e 's/\".*//g')
done

while [[ "$status" == "Online" ]]
do
	echo "${model} Online: $status on $(date)"
	xvfb-run -s '-ac' -a firefox -no-remote -private "http://www.myfreecams.com/#${model}" & ff=$!
	echo "$ff"
	sleep 7
	xvfbpid="$(pgrep -o -P "$ff")"
	echo "$xvfbpid"
	sleep "$dur"
	while pgrep -f "firefox -no-remote -private http://www.myfreecams.com/#${model}" > /dev/null
	do
		kill -- $(pgrep -f -o "firefox -no-remote -private http://www.myfreecams.com/#${model}")
	done
	kill -- "$ff"
	kill -- "$xvfbpid"
        while pgrep -U "$(whoami)" firefox > /dev/null
        do
                kill -- $(pgrep -U "$(whoami)" firefox)
        done
        rm -rf "/home/$(whoami)/.mozilla"
        rm -rf "/home/$(whoami)/.cache/mozilla"
        rm -rf /tmp/xvfb*
        sleep 2
	echo "Firefox Killed"
	status=$(curl -s "$site" | grep -e "profileState" | sed -e 's/.*:\"//g' -e 's/\".*//g')
done
}

while true
do
if curl -s -I "http://profiles.myfreecams.com/${mname}" | grep -qi "200 OK"
then
   model="${mname}"
   check
else
   model=$(curl -s -I "http://profiles.myfreecams.com/${mname}" | grep -i "Location" | sed -e 's/.*\///g' | tr -dc '[[:print:]]' )
   check
fi
done
