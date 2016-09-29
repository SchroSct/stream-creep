#!/bin/bash
################################
## Streamate Creep Script     ##
## Monitors Model Profile     ##
## Opens Firefox when Online  ##
################################
## Depends: curl, firefox,    ##
## xvfb, ngrep, timeout,      ##
## pgrep, flashplugin-installer#
################################
##Following in /etc/sudoers   ##
##$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/ngrep, /usr/bin/timeout
################################
##su - $(whoami) -c "screen -d -m -S modelname sm-creep.sh ModelName"
################################

model="$1"
dur="300"

check(){
echo "${model}"
site="http://www.streamate.com/cam/${model}/"
if curl -s "$site" |  grep -i "I'm offline, but let's stay connected!" > /dev/null
then
	echo "${model} streamate offline $(date)"
	let random=$RANDOM%360
	let sleepy=45+$random
	echo "sleeping $sleepy"
	sleep $sleepy
else
	echo "${model} streamate online $(date)"
	while ! curl -s "$site" | grep -i classid > /dev/null && ! curl -s "$site" |  grep -i "I'm offline, but let's stay connected!" > /dev/null
	do
		echo "${model} is online but not in chat $(date)"
		let sleepy=$RANDOM%30
		sleep $sleepy
	done

	xvfb-run -s '-ac' -a firefox -no-remote -private "${site}" & ff=$!
	echo "$ff"

  let random=$RANDOM%30
  let sleepy=$dur+$random
  echo "ngrepping for disconnects for $sleepy"
	sudo timeout "$sleepy" ngrep -n 1 -p -q -i "^POST /ajax/clientdisconnectlog.php.*${model}"
	let ngex=$?
	xvfbpid="$(pgrep -o -P "$ff")"
	echo "$xvfbpid"
	while pgrep -f "firefox -no-remote -private ${site}" > /dev/null
	do
		kill -- $(pgrep -f -o "firefox -no-remote -private ${site}")
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
	echo "Firefox Killed"
	sleep 2
	if [[ "$ngex" -eq 0 ]]
	then
		echo "ngrep was disconnected, add random sleep time."
		let sleepy=$RANDOM%30
		echo "Sleeping $sleepy"
		sleep "$sleepy"
	fi
fi
}


while true
do
check
done
