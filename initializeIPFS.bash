#~/bin/bash
# This script will initialize IPFS software and establish initial settings.
# The initial "out of the box" settings are:
# 1) 1GB of drive space
# 2) 5 IPFS peer nodes (NY, TX, Maine + 1 more by Derrick)
# 3) a new, unique peerID

GOVER=1.12.17                       # Info only - version in use in this OS
REPO=/home/ipfs/.ipfs
CONFIG=$REPO/config                 # IPFS repository configuration file

if [ ! -d /home/ipfs/.ipfs/ ]; then
  mkdir /home/ipfs/.ipfs/; chown ipfs.ipfs /home/ipfs/.ipfs/
  ipfs init > $REPO/init.log 2>&1   # Initialize IPFS and log output
  if grep -qic 'peer identity:' $REPO/init.log; then
    echo -e "No peer identity found after 'ipfs init'" >> $REPO/init.log
    exit
  else
    sed -i 's/^(.*StorageMax\":).*$/\1   \"1G\",/g' $CONFIG
    exit
    $(./addPeers.py $CONFIG >> $REPO/init.log 2>&1)
    sudo systemctl enable ipfs >> $REPO/init.log 2>&1
    sudo systemctl start ipfs >> $REPO/init.log 2>&1
    sudo ufw allow 4001/tcp >> $REPO/init.log 2>&1
  fi
fi

rm -rf /home/ipfs/.ipfs/*  # Start from a blank slate; use explicit path here!
echo "Initializing your new IPFS node, please be patient..."
runuser -l ipfs -c "ipfs init > $REPO/init.log 2>&1"   # Initialize IPFS and log output
if [ $(./getPeerID.bash) != "1" ]; then
  zenity --error --title="Something went wrong" --text="No peer identity found!" --width=250 --height=100
  exit
fi

echo "Adding default peers..."
$(./addPeers.py $CONFIG > /dev/null 2>&1)

echo "Reserving ${MAX}GB for IPFS storage..."
sed -i "s/^\s*\"StorageMax.*$/    ~StorageMax~: ~${MAX}G~,/g" $CONFIG
sed -i "s/~/\"/g" $CONFIG

# echo "Opening required firewall ports and starting IPFS..."
ufw allow 4001/tcp > /dev/null 2>&1
ufw allow 22/tcp   > /dev/null 2>&1 # ssh

systemctl enable ipfs > /dev/null 2>&1
systemctl start ipfs > /dev/null 2>&1

cat $REPO/init.log
README=$(grep -oP '^\s+ipfs cat /ipfs/\K\S+' $REPO/init.log)
echo "in a terminal window, or enter the URL ipfs://$README in the Chromium web browser."
TITLE='Setup is complete!'
MSG='Your IPFS node is ready now.\nClick OK to close these windows'
zenity --info --title="$TITLE" --text="$MSG" --width=280 --height=80
