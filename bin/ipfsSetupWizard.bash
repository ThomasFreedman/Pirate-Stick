#!/bin/bash

# This setup wizard will create a new  IPFS repository.  It provides a folder
# browser to choose or create a repository location and reports the available
# space there. It will ask for the maximum amount of space the repository may
# hold. It will not allow selecting an existing repository and saves any that
# may be active. It manages the active IPFS repository using 1 symbolic link.
#
# This tool can also be used to setup a USB Liberty Library.

LIVE=$HOME/Live-usb-storage         # Remainder of USB storage when booted live
REPO=$HOME/.ipfs
LOG=$REPO/init.log

if [ -f $LOG ] && grep -qic 'peer identity:' $LOG; then
  MSG='IPFS is already initialized!\nSave existing repo and\ncreate a new one?'
  if ! zenity --question --text="$MSG" --width=250 --height=100; then
    notify-send -t 7000 "IPFS Setup Wizard:" "Canceled"
    exit 1;
  fi
  sudo systemctl disable ipfs > /dev/null 2>&1
  sudo systemctl stop ipfs > /dev/null 2>&1
  while systemctl is-active --quiet ipfs; do           # verify stopped
    sleep 1
  done
fi

TITLE="Choose a Folder for the New IPFS Repository"
while [ "$DONE" != "OK" ]; do
	IPFS=$(zenity  --file-selection --title="$TITLE" --directory)
	if [ $? -eq 0 ] && [ ! -f $IPFS/config ]; then
		FREE=$(df -Ph $IPFS | awk 'NR==2 {print $4}') # Get amount of free space
		SPC=${FREE//[!0-9]/}                          # Strip units, only numbers
		if [[ $FREE =~ "G" ]] && [ $SPC -ge 2 ]; then # Need at least 2GB free
			SPC=$((SPC - 1))                            # Save a little extra space
			#
			# Show available space and ask user for storageMax value
			#
			TITLE="Set Maximum Size of IPFS Repository"
			MSG="Available space there: $FREE. Enter the amount\n"
			MSG="${MSG}of space to use for IPFS (between 1 and $SPC):"
			INP=$(zenity --entry --title="$TITLE" --text="$MSG" --width=320)
			if [ $? -eq 0 ]; then
				INP=${INP//[!0-9]/}  # Only numbers please
				if [ "$INP" == "" ] || [ "$INP" -lt 1 ] || [ "$INP" -gt $SPC ]; then
					zenity --error --text="Invalid value, try again" --width=200
				else
					DONE="OK"
				fi
			else
				zenity --error --text="Invalid value, try again" --width=200
			fi
		else
			zenity --error --text="Not enough space!\nOnly $FREE availble there" --width=200
		fi
	else
		notify-send -t 7000 "IPFS Setup Wizard:" "Invalid or no folder selected"
		exit 1;
	fi
done
#
# Replace .ipfs symlink with one to the new storage location
#
if [ -d $REPO ]; then mv $REPO $HOME/.ipfs_$(date --iso-8601=seconds); fi
ln -s $IPFS $REPO
#echo -e "\nIPFS=$IPFS\nstorageMax=${INP}G\n"
$HOME/bin/initIPFS.bash $IPFS $INP
MSG="Success! The IPFS server is up and running.\n"
MSG="${MSG}You may notice higher than normal Internet\n"
MSG="${MSG}traffic initially as connections are made.\n"
zenity --info --text="$MSG" --width=350
