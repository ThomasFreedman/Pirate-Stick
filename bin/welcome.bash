#!/bin/bash
if [ -f ~/.config/.welcome.off ]; then exit; fi

TITLE='Welcome!'
if ! zenity --filename="$HOME/bin/welcome.txt" --text-info \
       --title="$TITLE" --width=520 --height=400; then
  if zenity --question --text="Stop showing this at startup?" \
            --width=150 --height=100; then
    touch $HOME/.config/.welcome.off
    notify-send -t 7000 "Pirate Stick Welcome:" "Has been disabled."
    exit
  fi
fi



