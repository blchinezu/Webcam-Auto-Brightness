#!/bin/bash

app_name="Auto-Brightness"
version="0.1b"

sudo_passed () { echo "$pass" | sudo -S $@; }
debug () { if [ "$debug" == "on" ]; then echo -e "$@"; fi }
make_writable () { sudo_passed chown $USER "$@"; sudo_passed chgrp $USER "$@"; sudo_passed chmod 777 "$@"; }
get_cfg () { echo "`echo -e "$conf" | grep -v ";" | grep "$1=" | sed -e 's/'$1'=//g'`"; }
show_info () { zenity --info --title="$app_name $version" --text="$@"; }
set_br ()
{
	if [ "$sleep_time_br" != "0" ]; then
		x="$1"
		if [ "$1" -lt "$2" ]; then	op="+";	elif [ "$1" -gt "$2" ]; then op="-";	fi
		while [ "$x" != "$2" ]; do
			x=`expr $x $op 1`
			echo $x > "$brightness_file"
			sleep $sleep_time_br
		done
		debug " > RES: $1 [$op] $2 - smooth"
	else
		echo $2 > "$brightness_file"
		debug " > RES: $1 [$op] $2 - sharp"
	fi
}
gen_cfg () { echo -e "; The path to the file which modifies your screen brightness
; The default value is working with ASUS X55SV
brightness_file=/sys/class/backlight/acpi_video0/brightness

; The webcam device to which streamer will connect to grab the image
; If the default doesn't work for you run this in terminal: ls -l /dev/video*
; If you get more than one device in that list or other than what's written here, try writing them here (not all at once)
webcam_dev=/dev/video0

; The time in seconds between two updates
; DEFAULT: 300  (5 minutes)
sleep_time=300

; The webcam brightness values coresponding to the 15 screen brightness steps
; STEPS:     0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
pbr_values=     1     2    3      4     5     6     7     8     9    10    13    18    22    14    27

; If you want to change the entire pbr_values list with the same amount then change only this following number
; Higher mod means lower pbr_values
; DEFAULT: 22
br_mod=22

; The size to which the webcam image will be resized for faster pixel analysis
img_size=160x120

; DON'T set values greater than 0.1 as you'll get long sharp brightness changes
; Smaller = smoother brightness change
; Set to 0 to deactivate smooth changing
; DEFAULT: 0.05
sleep_time_br=0.05

; Write your password here if you don't want to run the script as root.
; It is used to get write permissions for the brightness_file
usrp=

; Running flag (NOT recommended to change)
flag=/tmp/auto-brightness-" > cfg.ini; }
check_all ()
{
	ok=""; ko=""
	if [ -z "`whereis zenity | grep /`" ];		then ko="$ko\nAPP: zenity [Not installed]";			else ok="$ok\nAPP: zenity [OK]";		fi
	if [ -z "`whereis streamer | grep /`" ];	then ko="$ko\nAPP: streamer [Not installed]";		else ok="$ok\nAPP: streamer [OK]";		fi
	if [ -z "`whereis convert | grep /`" ];		then ko="$ko\nAPP: imagemagick [Not installed]";	else ok="$ok\nAPP: imagemagick [OK]";	fi
	if [ -z "`whereis php | grep /`" ];			then ko="$ko\nAPP: php [Not installed]";			else ok="$ok\nAPP: php [OK]";			fi
	
	if [ ! -z "$usrp" ] && [ "$USER" != "root" ] && [ "$USER" != "ROOT" ]; then make_writable $brightness_file; fi
	if [ -f "$brightness_file" ]; then
		if [ -w "$brightness_file" ]; then ok="$ok\nCFG: brightness_file [OK]"; else ko="$ko\nCFG: brightness_file [Not writable]\nCFG: usrp [Not defined - write your password]"; fi
	else
		ko="$ko\nCFG: brightness_file [Doesn't exist]"
	fi
	if [ -z "`ls $webcam_dev | grep $webcam_dev`" ]; then ko="$ko\nCFG: webcam_dev [Doesn't exist]"; else ok="$ok\nCFG: webcam_dev [OK]"; fi
	if [ "$sleep_time" == "" ];		then ko="$ko\nCFG: sleep_time [Not defined]";		else ok="$ok\nCFG: sleep_time [OK]";	fi
	if [ "$lev" == "" ];			then ko="$ko\nCFG: pbr_values [Not defined]";		else ok="$ok\nCFG: pbr_values [OK]";	fi
	if [ "$br_mod" == "" ];			then ko="$ko\nCFG: br_mod [Not defined]";			else ok="$ok\nCFG: br_mod [OK]";		fi
	if [ "$img_size" == "" ];		then ko="$ko\nCFG: img_size [Not defined]";			else ok="$ok\nCFG: img_size [OK]";		fi
	if [ "$sleep_time_br" == "" ];	then ko="$ko\nCFG: sleep_time_br [Not defined]";	else ok="$ok\nCFG: sleep_time_br [OK]";	fi
	if [ "$flag" == "" ];			then ko="$ko\nCFG: flag [Not defined]";				else ok="$ok\nCFG: flag [OK]";			fi
	if [ "$ko" != "" ]; then
		debug "\n\n --------------------[ KO ]--------------------\n$ko\n\n"
		show_info " \n$ko\n"
		rm -f ${flag}$$
		kill $$ 
		exit
	fi
}
cd "`echo $0 | sed -e 's/RUN.sh//g'`"
if [ ! -f 'cfg.ini' ]; then gen_cfg; fi
conf="`cat cfg.ini`"
brightness_file="`get_cfg brightness_file`"
img_size="`get_cfg img_size`"
webcam_dev="`get_cfg webcam_dev`"
flag="`get_cfg flag`"
usrp="`get_cfg usrp`"
lev="`get_cfg pbr_values`"
br_mod="`get_cfg br_mod`"
debug="`get_cfg debug`"
sleep_time="`get_cfg sleep_time`"
sleep_time_br="`get_cfg sleep_time_br`"
rm -f ${flag}*
touch "${flag}$$"

check_all

while [ -f "$flag$$" ]; do
	current_br=`cat "$brightness_file"`
	streamer -q -c $webcam_dev -o wc.jpeg
	convert -size $img_size wc.jpeg -resize $img_size +profile '*' wc.jpeg
	pbr=`php ret-brightness.php`
	pbr=`expr ${pbr/.*} - $br_mod`
	
	if   [ $pbr -ge `echo $lev | awk '{print $15}'` ]; 	then	br="15"
	elif [ $pbr -ge `echo $lev | awk '{print $14}'` ];	then	br="14"
	elif [ $pbr -ge `echo $lev | awk '{print $13}'` ];	then	br="13"
	elif [ $pbr -ge `echo $lev | awk '{print $12}'` ];	then	br="12"
	elif [ $pbr -ge `echo $lev | awk '{print $11}'` ];	then	br="11"
	elif [ $pbr -ge `echo $lev | awk '{print $10}'` ];	then	br="10"
	elif [ $pbr -ge `echo $lev | awk '{print $9}'`	];	then	br="9"
	elif [ $pbr -ge `echo $lev | awk '{print $8}'`  ];	then	br="8"
	elif [ $pbr -ge `echo $lev | awk '{print $7}'`  ];	then	br="7"
	elif [ $pbr -ge `echo $lev | awk '{print $6}'`  ];	then	br="6"
	elif [ $pbr -ge `echo $lev | awk '{print $5}'`  ];	then	br="5"
	elif [ $pbr -ge `echo $lev | awk '{print $4}'`  ];	then	br="4"
	elif [ $pbr -ge `echo $lev | awk '{print $3}'`  ];	then	br="3"
	elif [ $pbr -ge `echo $lev | awk '{print $2}'`  ];	then	br="2"
	elif [ $pbr -ge `echo $lev | awk '{print $1}'`  ];	then	br="1"
	elif [ $pbr -lt `echo $lev | awk '{print $1}'`  ];	then	br="0"
	else														br="$current_br"
	fi
	if [ "$br" != "$current_br" ]; then
		if [ "$sleep_time" -le "60" ]; then
			case "`expr $br - $current_br`" in
				-2|-1|1|2)							;;
				*)			set_br $current_br $br	;;
			esac
		else
			set_br $current_br $br;
		fi
	fi
#	read x
	rm *.jpeg
	debug " $pbr / $br\n"
	sleep $sleep_time
done

rm ${flag}*

exit
