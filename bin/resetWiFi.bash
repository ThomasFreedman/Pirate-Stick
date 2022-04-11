#!/bin/bash

TITLE='Reset WiFi (wpa_supplicant)'
MSG="This will reset WiFi networking which\nwill drop any connections. Proceed?"
if zenity --question --text="$MSG" --width=350 --height=100; then
  notify-send -t 5000 "WiFi Network:" "Restarting wpa_supplicant"
  sudo systemctl restart wpa_supplicant
else
  notify-send -t 7000 "WiFi Network:" "Cancelled restart"
fi



