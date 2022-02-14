#!/bin/bash

# TODO: "Goo-ify" this script (Add GUI for it) using zenity and terminal windows
# This script will install IPFS software and establish initial settings.
# This must be executed with root privileges or with sudo.

`ping -c 1 1.1.1.1 > /dev/null 2>&1`
if [ $? -ne 0 ] || [ $(id -u) -ne 0 ]; then
  echo "Please connect to the Internet and run as root!"
  exit 1
fi

# Calculate disk space available for IPFS
FREE=`df --output=avail -B 1 / | tail -n 1` # Free space in bytes on root partition
MAX=`expr $FREE / 1320000000`      # Approximately 75% of free space (in GB)
printf -v STORAGE_MAX %dG $MAX     # The default StorageMax parameter value

UNIT=/etc/systemd/system/ipfs.service
PKGS=/home/ipfs/tmp/packages.bash
CMDL=$#                            # How many command line options provided
AUTO=0                             # Default autostart method 0 == systemd, 1 == cron @reboot
WAIT=1                             # Default value for single step / debug mode (no wait)
ACCT=ipfs                          # User account to install IPFS in
ARCH=amd64                         # default system architecture
DISTUP=0                           # Default value for dist-upgrade (don't do it!)
UFW=0                              # Default value to install firewall (no)
GOVER=1.12.17                      # Default version to use (tho now -g requires version)
CONFIG=/home/$ACCT/.ipfs/config    # IPFS configuration file
GOINIT=/usr/local/bin/goInit
IPFSin=/home/$ACCT/bin/ipfs        # ipfs-update installs here, but is moved to $IPFS
IPFS=/usr/local/bin/ipfs           # Move ipfs binary here so in PATH for all users

usage() {
  echo "$0 [-a] [-d] [-g <version> ] [-m <int> ] [-p <amd64 | arm64>] [-w] [-h | --help]"
  echo "-a == autostart method. Use cron @reboot instead of systemd unit"
  echo "-d == distribution upgrade. Specify -d to do a dist-upgrade"
  # Firewall may need logic to start it automatically if chosen
  echo "-f == firewall on Raspberry Pi. Default is no. Use -f to enable on the RPi"
  echo "-g == go version. -g requires a version"
  echo "-m == max storage space. Default is 75% of disk. Option value integer in gigabytes"
  echo "-p == Platform architechure amd64, arm64 or armhl for 32 bit ARM systems"
  echo "-w == Wait after each step / debug mode. Default is no waiting"
  echo "-h == print this usage info and exit. Also for --help"
}

# Make sure we have enhanced getopt -- probably not required for most Linux distros
getopt --test
if [ $? -ne 4 ]; then echo "Ouch! getopt not available on this system - Bye!"; exit 1; fi

# Process command line options
# NOTE: double colons after g option (should be optional param for -g) swallows -m !!!
# getopt from util-linux 2.29.2 on Raspbian Stretch Lite OS, 4/8/2019 release
OPTS=`getopt -o adfg:m:p:wh --long help -n "$0" -- "$@"`
eval set -- "$OPTS"

# extract options and their arguments and set appropriate variables.
while true; do
    case "$1" in
        -a) AUTO=1;    shift ;;
        -d) DISTUP=1;  shift ;;
        -f) UFW=1;     shift ;;
        -g) if [ "$2" != "" ]; then
              GOVER=$2
              echo "Will use golang version $GOVER"
            fi
            shift 2
            ;;
        -m) if ! [ -z "${2//[0-9]}" ]; then          # Positive number?
              echo "-m requires a positive integer (gigabytes)"
              exit 1
            fi
            STORAGE_MAX="$2G";
            shift 2
            ;;
        -p) if [ "$2" != "" ]; then
              ARCH=$2
              echo "Will use $ARCH architecture"
            fi
            shift 2
            ;;
        -h|--help) usage; exit 0 ;;
        -w) WAIT=1; shift ;;
        --) shift;  break ;;
        *) echo "No such option: $1" >&2; exit 1 ;;
    esac
done

# Show options parsed for this installation
echo -e "\nACCT=$ACCT, ARCH=$ARCH, AUTO=$AUTO, DISTUP=$DISTUP, UFW=$UFW, GOVER=$GOVER, STORAGE_MAX=$STORAGE_MAX, WAIT=$WAIT"
if [ $CMDL -lt 1 ]; then
  echo ">>>No options provided, use defaults for all?"
else if [ $CMDL -lt 1 ] || [ $WAIT == 1 ]; then
  read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi
fi

echo -e "\nUpdating the Operating System..."
apt-get -y update
apt-get -y upgrade
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

# If there is no .ipfs directory in the $ACCT root...
if [ ! -d /home/$ACCT/.ipfs ]; then
  echo -e "\nPreparing the $ACCT user account..."
  #if [ ! -d /home/$ACCT ]; then useradd -m -s /bin/bash ipfs; fi
  #if [ ! -d /home/$ACCT/.ipfs ]; then mkdir /home/$ACCT/.ipfs; fi
  mkdir /home/$ACCT/bin > /dev/null 2>&1  # ipfs-update will install binary here
  mkdir /home/$ACCT/go > /dev/null 2>&1
  mkdir /home/$ACCT/go/bin > /dev/null 2>&1
  echo "source $GOINIT" >> /home/$ACCT/.bashrc  # Sets PATH and GOPATH
  chown -R ${ACCT}.${ACCT} /home/$ACCT
#  usermod -aG video $ACCT  # Required for vcgencmd (to read Rpi's temperature)
  usermod -G www-data,netdev,yggdrasil,prosody,adm,dialout,cdrom,audio,video,plugdev,games,users,input,lpadmin $ACCT > /dev/null 2>&1
  echo "Creation of user account named $ACCT is complete."
else
  echo -e "\nThe $ACCT account already exists!"
fi
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

# Install requested go language version if not already installed
if [ ! -e "/usr/local/bin/go$GOVER.linux-$ARCH.tar.gz" ]; then
  echo -e "\nInstalling go version $GOVER..."
  pushd /usr/local/bin > /dev/null 2>&1
  echo "Installing binary golang version $GOVER from googleapis. Please be patient..."
  wget https://go.dev/dl/go$GOVER.linux-$ARCH.tar.gz
  tar -C /usr/local -xzf go$GOVER.linux-$ARCH.tar.gz
  popd > /dev/null 2>&1
fi

# Create a bit of code to set env vars for all to source in their .profile
echo 'export GOPATH=/home/$USER/go' > $GOINIT
echo 'export PATH=$PATH:/home/$USER/bin:/usr/local/go/bin:$GOPATH/bin' >> $GOINIT
source $GOINIT # We need those vars now to proceed
if [ ! -d /root/go ]; then mkdir /root/go; fi

# Don't add to ACCT .bashrc if it's already there
if ! grep -Fq goInit /home/$ACCT/.bashrc; then
  echo "source $GOINIT" >> /home/$ACCT/.bashrc
fi

VER=`go version`  # Verify Installation
if [[ ! "$VER" =~ $GOVER ]]; then
  echo "Bummer - failed to install go version $GOVER, Bye!"
  exit -1
else
  echo -e "\n$VER is installed"
fi
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

echo -e "\nInstalling supporting packages. Please be patient..."
$PKGS
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

# TODO: Investigate ufw auto startup at boot bug, implement a solution
#       No problem on 64 bit OS.
if [[ $UFW == 1 ]]; then
  echo -e "\nInstalling ufw firewall and configuring allowed ports..."
  apt-get -y install ufw;
  echo "Opening required firewall ports..."
  ufw allow 22/tcp
  ufw allow 123/tcp
  ufw allow 443/tcp
  ufw allow 4242/tcp
  ufw allow 4242/udp
  ufw allow 42042/tcp
  ufw allow 4001/tcp
  ufw allow 5900/tcp
  ufw allow 8080/tcp
  ufw enable
  echo -e "\nDouble check that ufw starts on boot. Ufw has known issues with that.\n"
  if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi
fi

# TODO: find a way to download latest ipfs-update version
# Install ipfs-update and use it to install latest IPFS server
if [ ! -e "/usr/local/bin/ipfs-update" ]; then
  echo -e "\nInstalling ipfs-update utility..."
  wget -O ipfsUpdate.tgz https://dist.ipfs.io/ipfs-update/v1.7.1/ipfs-update_v1.7.1_linux-${ARCH}.tar.gz
  tar -xzf ipfsUpdate.tgz
  cp ipfs-update/ipfs-update /usr/local/bin/.  # Copy binary into place
  if [ "$(which ipfs-update)" != "/usr/local/bin/ipfs-update" ]; then
    echo "Ouch - failed to install ipfs-update, Bye!"
    exit -1
  else
    rm -rf ipfs-update  # Remove the folder
  fi
else
  echo -e "\n$(ipfs-update --version) is already installed!"
fi
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

if [ ! -e $IPFSin ]; then
  echo -e "\nInstalling version 0.8.0 of ipfs..."
  runuser -l $ACCT -c 'ipfs-update install 0.8.0'
#    runuser -l $ACCT -c 'ipfs-update --verbose install --no-check latest'
  if [ ! -e $IPFSin ]; then
    echo "ipfs-update failed to install ipfs, Bye!"
    exit -1
  else
    mv $IPFSin $IPFS                            # Move into PATH for all users
    runuser -l $ACCT -c "ln -s $IPFS $IPFSin"   # Do this mainly for this script
    echo "Installation of go-$(ipfs version) complete"
  fi
else
  echo -e "\ngo-$(ipfs version) is already installed!"
fi
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

# Initialize IPFS and log output to init.log file in .ipfs folder
if [ ! -e /home/$ACCT/.ipfs/config ]; then
  echo -e "\nInitialling the IPFS server for account $ACCT..."
  runuser -l $ACCT -c 'ipfs init --profile server > ~/.ipfs/init.log 2>&1'
  apt -y autoremove
  echo "Setting maximum IPFS storage to $STORAGE_MAX in config file..."
  sed -i "s/^\s*\"StorageMax.*$/    ~StorageMax~: ~$STORAGE_MAX~,/g" $CONFIG
  sed -i "s/~/\"/g" $CONFIG
else
  echo -e "\nThe ipfs server is already setup under account $ACCT!"
fi
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

if [ $AUTO -eq 0 ]; then
  if [ ! -e $UNIT ]; then
    echo -e "\nCreating SystemD unit to start IPFS on reboot..."
    (
    cat <<SYSD_UNIT
[Unit]
Description=IPFS daemon
After=network.target
[Service]
User=$ACCT
Environment="IPFS_PATH=/home/$ACCT/.ipfs"
ExecStart=$IPFS daemon --enable-namesys-pubsub
Restart=on-failure
StartLimitIntervalSec=60
[Install]
WantedBy=multi-user.target
SYSD_UNIT
) > $UNIT
    echo "Starting IPFS server..."
    systemctl enable ipfs
    systemctl start ipfs
  else
    echo -e "\nSystemD will automatically start IPFS on boot"
  fi
else   # Use this alternate way to start service on system start
  echo -e "\nCreating a cron @reboot entry and script to start IPFS on boot..."
  echo "#!/bin/bash" > /home/$ACCT/autostart.bash
  echo "source $GOINIT" >> /home/$ACCT/autostart.bash
  echo "export IPFS_PATH=/home/$ACCT/.ipfs" >> /home/$ACCT/autostart.bash
  echo "/home/$ACCT/go/bin/ipfs daemon --enable-namesys-pubsub" >> /home/$ACCT/autostart.bash
  echo "@reboot $ACCT /bin/bash /home/$ACCT/autostart.bash" > /etc/cron.d/autoStart
  chmod 755 /etc/cron.d/autoStart
  echo -e "\nThe IPFS server will start automatically by cron using @reboot"
fi
if [ $WAIT == 1 ]; then read -n 1 -p "Press ^C to exit, any other key to proceed..." key; fi

cat /home/$ACCT/.ipfs/init.log
echo -e "\nIPFS is now installed on this system.\n"
echo "Now set a password for the $ACCT account. Press ^C and abort this now"
echo "unless you are certain you have setup your system with appropriate"
echo "locale, keyboard etc. Otherwise you may not be able to login."
passwd $ACCT
