#!/bin/bash

# This is a simple front end to manage hotspot options and launch wihotspot.

CMD=create_ap
SYSD_SVC=${CMD}.service

# $1 == service name 
# $2 == enable | disable
change_service()
{
  SVC_STATUS=$(systemctl list-unit-files $1)

  # Unmask the service first if masked (removes symlink to /dev/null)
  if [[ $SVC_STATUS =~ "masked" ]]; then
	  sudo systemctl unmask $1 >/dev/null 2>&1
  fi

  if [ "$2" == "enable" ]; then	
    sudo systemctl enable $1 >/dev/null 2>&1
  else
    sudo systemctl disable $1 >/dev/null 2>&1
  fi
}

go()
{
 if [ "$1" == "1" ]; then
   TITLE='Automatic Hotspot on Start'
   if systemctl --quiet is-enabled $SYSD_SVC; then
     MSG='Status: active on system start, deactivate?'
     if zenity --question --text="$MSG" --width=350; then
       notify-send -t 7000 "Hotspot:" "deactivated on start"
       change_service $SYSD_SVC "disable"
     else
       notify-send -t 7000 "Hotspot:" "activated on start"
       change_service $SYSD_SVC "enable"
     fi
   else
     MSG='Status: not active on system start, activate?'
     if zenity --question --text="$MSG" --width=350; then
       notify-send -t 7000 "Hotspot:" "activated on start"
       change_service $SYSD_SVC "enable"
     else
       notify-send -t 7000 "Hotspot:" "deactivated on start"
       change_service $SYSD_SVC "disable"
     fi
   fi
 elif [ "$1" == "2" ]; then
   sudo /usr/bin/wihotspot
   sudo rm -rf /tmp/wihotspot_qr.png
 elif [ "$1" == "3" ]; then
    MSG="Provide Internet from WiFi to ethernet -- Coming soon!"
    zenity --info --text="$MSG" --width=300 --height=80
 elif [ "$1" == "4" ]; then
    sudo $CMD --fix-unmanaged > /dev/null 2>&1
    MSG="Restored NetworkManager management of devices"
    zenity --info --text="$MSG" --width=200 --height=80
 else
    FILE="$(dirname "${BASH_SOURCE[0]}")/ReadMe.txt"
    TITLE='Pirate Stick Hotspot Help'
    zenity --filename="$FILE" --text-info --title="$TITLE" \
           --width=600 --height=400
 fi
}

menu()
{
title="Pirate Stick Hotspot"
error="Invalid option, click 'OK' to choose again"
prompt="Pick an option then click OK or Cancel to exit:"

# Selection menu
options=("1 - Enable or disable starting hotspot on system startup"
         "2 - Configure, start or stop hotspot with wihotspot tool"
         "3 - Provide Internet from WiFi to wired ethernet"
         "4 - Restore NetworkManager control of devices"
         "5 - Help for each of these options")


while opt=$(zenity --list --title="$title" --width 460 --height 350 \
            --text="$prompt" --column="Available Options:" "${options[@]}"); 
do
    selected=""
    case "$opt" in
    "${options[0]}" ) selected="1";;
    "${options[1]}" ) selected="2";;
    "${options[2]}" ) selected="3";;
    "${options[3]}" ) selected="4";;
    "${options[4]}" ) selected="5";;
    *) continue
    esac
    go $selected
done
}

menu # <--- primary program loop
