#!/bin/bash
################################
## Streamate Creep Script     ##
## Monitors Model Profile     ##
## Opens Firefox when Online  ##
################################
## Depends:                   ##
##                            ##
## youtube-dl                 ##
################################
##su - $(whoami) -c "screen -d -m -S modelname chat-creep.bash ModelName"
################################

model="$1"
dur="300"

check(){
echo "${model}"
site="https://chaturbate.com/${model}/"
if curl -s "$site" |  grep -i "Room is currently offline" > /dev/null
then
        echo "${model} chaturbate offline $(date)"
        let random=$RANDOM%360
        let sleepy=45+$random
        echo "sleeping $sleepy"
        sleep $sleepy
else
        echo "${model} chaturbate online $(date)"
        youtube-dl --prefer-ffmpeg "$site"
fi
}

cd ~
while true
do
check
done
