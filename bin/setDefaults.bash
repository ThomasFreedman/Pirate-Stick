# Get the current number from the default hotspot SSID or
# generate one if no hotspot SSID has been set.  Set both
# num and ssid.  ssid will always be valid but num may be
# empty if default has been replaced by user supplied val
num=$(sed -n "s/SSID=PirateStick\([0-9]\+\|_\{4\}\)/\1/p" $etc)
if [ "$num" == "____" ]; then
  num=$((1 + $RANDOM % 9999))   # Generate a hotspot SSID
  ssid="PirateStick$num"
  sudo sed -i "s/^SSID=\(.*\)$/SSID=$ssid/" $etc
  sudo sed -i "s/^PASSPHRASE=\(.*\)$/PASSPHRASE=@RRRsp0t/" $etc
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
# If empty set it to the hotspot SSID value, and to index.mu.
nam=$(sed -n "s/node_name *= *\(.*\)/\1/p" $nom > /dev/null 2>&1)
if [ -f $nom ] && [ "$nam" == "" ]; then
  sed -i "s/\(node_name *=\)\(.*\)/\1 $ssid/" $nom > /dev/null 2>&1
  echo ${nhp/ ID / $ssid } > $idx
fi
if grep -q 'Anonymous Peer' $peer ; then
  $HOME/bin/nomadUtils.py $ssid
fi

# Force MX Linux installer icon on desktop to change
logo=/usr/local/share/images/pirateBoxLogo300x400WhiteOnTransparent.png
sed -i "s|^\(Icon=\).*|\1$logo|" $inst > /dev/null 2>&1
Icon=
