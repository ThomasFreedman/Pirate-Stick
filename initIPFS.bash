#~/bin/bash
#
# This script will initialize IPFS and establish initial settings for it.
#
# The initial "out of the box" settings are:
# 1) 1GB of drive space
# 2) Add 4 IPFS peer nodes (NY, TX, 2 for Derric in Maine)
# 3) Create a new, unique peerID
#
# A log of the initialization process can be found in /home/ipfs/.ipfs/init.log
# This script is executed on every ipfs account login.

GOVER=1.12.17                       # Info only - version in use in this OS
REPO=/home/ipfs/.ipfs
CONFIG=$REPO/config                 # IPFS repository configuration file

if [ ! -d /home/ipfs/.ipfs/ ]; then
  mkdir /home/ipfs/.ipfs/; chown ipfs.ipfs /home/ipfs/.ipfs/
  ipfs init > $REPO/init.log 2>&1   # Initialize IPFS and log output
  if ! grep -qic 'peer identity:' $REPO/init.log; then
    echo -e "No peer identity found after 'ipfs init'" >> $REPO/init.log
    exit
  else
    sed -i 's/^\(.*StorageMax\":\).*$/\1   \"1G\",/g' $CONFIG
    $(addPeers.py $CONFIG >> $REPO/init.log 2>&1)
    sudo systemctl enable ipfs >> $REPO/init.log 2>&1
    sudo systemctl start ipfs >> $REPO/init.log 2>&1
    sudo ufw allow 4001/tcp >> $REPO/init.log 2>&1
  fi
fi
