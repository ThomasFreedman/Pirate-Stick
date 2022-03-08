The Autohotspot software used on the Pirate Box for managing network options is not compatible with the Network Manager used by MX Linux on the Pirate Stick. It has been replaced with a compatible alternative that provides more functionality, including the ability to operate a hotspot from the same WiFi device that is used to connect to the Internet. Future options will include sharing Internet from WiFi to wired ethernet devices.
---------------------------------------------------------------------------------------------------------

Available Hotspot Options

 1 = Enable or disable starting hotspot on system startup
 2 = Configure and start hotspot with wihotspot tool
 3 = Provide Internet from WiFi to wired ethernet
 4 = Restore NetworkManager control of devices
 5 = Help for each of these options

1: Enable or disable starting hotspot on system startup 
------------------------------------------------------------------------------
This option will ask you if you want to enable or disable starting of the WiFi hotspot previously configured with wihotspot (option 2) when the computer is started. Use option 2 to start or stop the hotspot immediately, no reboot required. 

2: Configure and start hotspot with wihotspot tool
---------------------------------------------------------------------
This option will start the wihotspot tool to configure the hotspot. Continue reading for more information on the wihotspot tool below.

3: Provide Internet from WiFi to wired ethernet
-----------------------------------------------------------------
This will be a future option, provided via a graphical interface It is possible to do this via the command line now, as all of the components are installed, however that is beyond the scope of the current system to explain. For the adventurous, enter the command "create_ap --help" in a terminal window.

4: Restore NetworkManager control of devices
---------------------------------------------------------------
This will disable all autohotspot options and return the computer to default Wifi settings. Hostapd & dnsmasq will not be uninstalled only disabled.

5: Help for each of these options -- This ReadMe file
 

Wihotspot Tool
---------------------
Documentation for this tool will be available soon.

