#!/bin/bash
www=/var/www/html
hst=/etc/hosts
etc=/etc/create_ap.conf
nom=$HOME/.nomadnetwork/config
idx=$HOME/.nomadnetwork/storage/pages/index.mu
peer=$HOME/.nomadnetwork/storage/peersettings
inst=$HOME/Desktop/minstall.desktop
shar=/usr/share/applications/minstall.desktop
psdy=/etc/prosody/prosody.cfg.lua

nhp='Hello! This is the index.mu for ID on nomad network'

cd $HOME/bin

# This script sets various defaults such as the SSID for the
# WiFi hotspot and Nomadnet node name for Reticulum network,
# and keeps various files under the webserver updated.

# Get the current number from the default hotspot SSID or
# generate one if no hotspot SSID has been set.  Set both
# num and ssid.  ssid will always be valid but num may be
# empty if default has been replaced by user supplied val
num=$(sed -n "s/SSID=PirateStick\([0-9]\+\|_\{4\}\)/\1/p" $etc)
if [ "$num" == "____" ]; then   # Run only 1 time
  num=$((1 + $RANDOM % 9999))   # Generate a hotspot SSID
  ssid="PirateStick$num"
  sudo sed -i "s/^SSID=\(.*\)$/SSID=$ssid/" $etc
  sudo sed -i "s/^PASSPHRASE=\(.*\)$/PASSPHRASE=@RRRsp0t/" $etc
  sudo hostnamectl set-hostname ${ssid}
  sudo bash -c "echo -e \"127.0.0.1\t${ssid}\" >> $hst"
  sudo sed -i "s|^\(admins = { \)|\1\"admin@localhost\", \"admin@$ssid\" |" $psdy
elif [ "$num" == "" ]; then
  ssid=$(sed -n "s/^SSID=\(.*\)$/\1/p" $etc) # Provided by user
else
  ssid="PirateStick$num"          # Default already set
fi

#
# Make sure all of the ssid values are consistent
#
sed -i "s/\( is:\)\(.*\)<\/p>/\1 $ssid<\/p>/" ${www}/pbox-ssid.html
h="href='pbox-ssid.html'"
t="title='hotspot SSID: "$ssid"'"
o="for <a $h .*\/a>"
sed -i "s/<\!--ssid-->\|$o/for <a $h $t>Pirate Stick $num<\/a>/" ${www}/index.html

# Set the default nomandnet client's node and peer names if they're not set.
# If empty set it to the hotspot SSID value, and in index.mu.
nam=$(sed -n "s/node_name *= *\(.*\)/\1/p" $nom > /dev/null 2>&1)
if [ -f $nom ] && [ "$nam" == "" ]; then
  sed -i "s/\(node_name *=\)\(.*\)/\1 $ssid/" $nom > /dev/null 2>&1
  echo ${nhp/ ID / $ssid } > $idx
fi
if grep -q 'Anonymous Peer' $peer ; then
  $HOME/bin/nomadUtils.py set-name $ssid
fi

./initIPFS.bash  # Create the default IPFS server
