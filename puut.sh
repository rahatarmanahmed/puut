#!/bin/bash
#
# Written by Rahat Ahmed @ http://rahatah.me/d
# Based off shoot @ http://sirupsen.com/a-simple-imgur-bash-screenshot-utility/
#
# Description: A simple script that will take a screenshot
# upload it to Imgur, copy the image url to your clipboard
# and create a desktop notification.
#
# Parameters: Accepts the same parameters as scrot
#
# Dependencies: curl scrot notify-osd xclip
#
# Installation: Put this script in a folder in your PATH
# and make it executable. Rename to puut if convenient
# It's recommended to set up keyboard shortcuts to invoke
# this script.

# Configurable variables
DEFAULTDIR=$HOME/Pictures/Screenshots/
DEFAULTNAME="Screenshot `date "+%m-%d-%Y %H.%M.%S"`.png"
NOTIFICATION_TIME=3000 # milliseconds

# See if a name was passed as an argument and adjust accordingly
NAME=${!#}
if [[ ${NAME} == \-* || $# == 0 ]]
then # If no name given use default dir/name
	PARAMS=$@
	NAME=$DEFAULTNAME
	PATHNAME=$DEFAULTDIR$NAME
	# Creates the directory if it doesn't already exist.
	mkdir -p $DEFAULTDIR
else #If name given, take it and remove it from the parameters.
	length=$(($#-1))
	PARAMS=${@:1:$length}
	PATHNAME=$NAME
fi

# from http://sirupsen.com/a-simple-imgur-bash-screenshot-utility/
function uploadImage {
  curl -s -F "image=@$1" -F "key=486690f872c678126a2c09a9e196ce1b" https://imgur.com/api/upload.xml | grep -E -o "<original_image>(.)*</original_image>" | grep -E -o "http://i.imgur.com/[^<]*"
}

# Let the other programs do the magic.
sleep .5 && scrot $PARAMS "$PATHNAME"
URL=`uploadImage "$PATHNAME" `
if [[ -n $URL ]]
then
	echo $URL | xclip -f -selection clipboard > /dev/null
	notify-send --expire-time=$NOTIFICATION_TIME --category=transfer.complete "Puut Success!" "$URL"
else
	echo "Failed to upload".
	notify-send --expire-time=$NOTIFICATION_TIME --category=transfer.error "Failed to upload $NAME."
fi
