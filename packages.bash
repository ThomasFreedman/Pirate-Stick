#!/bin/bash

# NOTE: The iptables-persistent package will prompt you to save
#       your existing firewall rules for use on startup. Other
#       items may require interactivity such as the mesh network
#       packages yggdrasil, prosody and the nomadnet python pkg.

# Make sure we're still online
$(ping -c 1 1.1.1.1 > /dev/null 2>&1)
if [ $? -ne 0 ] || [ $(id -u) -ne 0 ]; then
  echo "You're not online and / or not running as root!"
  read -n 1 -p "Press ^C to exit" key;
  exit 1
fi

read -n 1 -p "Press ^C to exit, any other key to install packages..." key;

# yggdrasil mesh network prerequisits:
# Import the repository key to the gpg keyring and export it to the apt keyring:
gpg --fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt
gpg --export 569130E8CA20FBC4CB3FDE555898470A764B32C9 | sudo apt-key add -
#
# Add the repository into apt sources:
#
echo 'deb http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' | sudo tee /etc/apt/sources.list.d/yggdrasil.list

# For RPi only:
#apt-get install rpi-imager

apt-get update -y
apt-get install -y yggdrasil prosody net-tools nginx chromium xterm sqlite3 gparted chromium simplescreenrecorder hostapd dnsmasq iptables-persistent netfilter-persistent smartmontools vlc remmina python3-pip python3-tk zenity

# may need to create a link for lxterminal--> xfce4-terminal in /usr/bin

pip3 install --upgrade pip
pip3 install PySimpleGUI==4.38.0
pip3 install rns nomadnet python-nonblock ipfshttpclient beautifulsoup4 html5lib numpy pip-date pyperclip pyudev simplejson tinytag youtube-dl 

