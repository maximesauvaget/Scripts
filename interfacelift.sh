#!/bin/bash
set -e

#Change this URL to match your screen's resolution.
BASE_URL=http://interfacelift.com/wallpaper_beta/downloads/date/widescreen/1920x1080/index

MAX=$(wget -q -U "Mozilla/5.0" -O - $BASE_URL.html | grep 'page 1 of' | sed s/[^0-9]//g | sed 's/^.*\(...\)$/\1/')

STORE=${HOME}/il.links.text

function ask_for_replacement(){
	read -e -N 1 -p "Replace existing $STORE ?" _answer
	case $_answer in
		Y|y)
			if ! rm $STORE; then
				echo "Cannot delete $STORE. Exiting."
				exit 1
			fi
			;;
		*)
			exit 1
			;;
	esac
}

function discovery(){
INDEX=1
until [ $INDEX -gt $MAX ]; do
	URL=${BASE_URL}${INDEX}.html
	LINK=$(wget -q -U "Mozilla/5.0" -O - $URL | grep download.png | sed 's/^\s*<a href="\([^"]\+\)"><[^>]\+download.*$/http:\/\/www.interfacelift.com\1/')
	echo $LINK
	echo $LINK >> $STORE
	((INDEX++))
done
}

function random(){
	random_page=$[ ( $RANDOM % $MAX )  + 1 ]
	URL=${BASE_URL}${random_page}.html
	
	ret=$(wget -q -U "Mozilla/5.0" -O - $URL | grep download.png | sed 's/^\s*<a href="\([^"]\+\)"><[^>]\+download.*$/http:\/\/www.interfacelift.com\1/')
	links=()	

	for link in ${ret[@]}; do
		links=("${links[@]}" "$link")
	done
	
	random_link=$[ ( $RANDOM % ${#links[@]} ) ]
	wget -U "Mozilla/5.0" ${links[random_link]}
	exit 0
}

[ ! -f $STORE ] || ask_for_replacement
[ ! x$1 == "xrandom" ] || random

echo "Retrieving links :"
discovery

read -e -N 1 -p "Proceed to download ? [Y/n]" _answer

case $_answer in
y|Y)
	wget -U "Mozilla/5.0" -i $STORE
	;;
*)
	echo "Execute 'wget -U 'Mozilla/5.0' -i $STORE' to manually proceed to download"
	;;
esac

exit 0
