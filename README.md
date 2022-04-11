![image](https://github.com/ThomasFreedman/Pirate-Stick/blob/prior-to-20220407/pirateStickBootScreen.png?raw=true)
![image](https://github.com/ThomasFreedman/Pirate-Stick/blob/prior-to-20220407/pirateStickDesktop.jpg?raw=true)

# Pirate-Stick
A Bootable USB version of Pirate Box based on the popular MX-Linux distribution

The delivery of the Pirate Stick will be via download from IPFS, so that anyone can create their own Pirate Stick on whatever USB media they prefer. The images are for x86 (Intel or AMD 64 bit processors, *NOT* ARM, not for Raspberry Pi). The IPFS CID for pStickRC2-20220404_2359 is: QmQ1aKKEQt54XkUnLFqTgmyMJ8wGVgETtd7MotiRu9Ub52 - prefix your favorite IPFS public gateway or use your own IPFS node to download the ISO and flash it to USB. The sha256 download verification for that CID is: c42734d1be012c7625f8cf85af66ddbc6e0bc62f85434e059fbc551a383ed8e3

This repo is not here to provide every single element or a step by step tutorial to create those ISOs, but will serve as a repository for the majority of the elements that I will use to create them.

---------------------------------
***Rational***

Due to the supply chain disruptions taking place it is becoming increasingly difficult and costly to obtain Raspberry Pi computers. For this reason I'm shifting my focus to a new product I am calling the Pirate Stick. It will utilize the same custom software I created for The Pirate Box but is built for use on more readily available hardware. 

---------------------------------
***Description***

Pirate Stick is a refinement of the Pirate Box created by Thomas Freedman in 2021. The original purpose of both products is gathering, tracking and storing media content, primarily but not limited to video and audio content. They both utilize the Interplanetary File System (IPFS) as their main storage repository. IPFS is a highly decentralized and global network of computers providing censorship resistance and performance that improves as it scales. Think of IPFS as "personal cloud storage" you are in full control of and the Pirate Box or Pirate Stick as your tool to control it. You decide how public or private the data you store there should be.

Whereas the Pirate Box is a small sized (2 decks of playing cards), portable, energy efficient but powerful "Raspberry Pi" computer, the Pirate Stick is a high performance, USB3 SSD drive that can transform almost any computer into the functional equivalent of a Pirate Box. It is a self contained, "live"  operating system "on a stick" that can be used with most computers and does not need to install anything on them (but it can if you want to). It will leave no trace on the machines it is used with and it won't touch the machine's hard drive - it doesn't even need a hard drive!

Pirate Stick is built on MX Linux AHS-21 (Advanced Hardware Support), voted by Distro Watch as the top Linux distribution for 2022. A derrivative of Debian Linux 11, it will work on the newest as well as older computer hardware. The minimum recommended configuration is a network capable computer (wired or wireless), 1GB of RAM, a dual core processor and the ability to boot from a USB device. Performance will of course depend on the host machine, and more RAM and USB3 rather than USB2 will make a significant difference.

It's important to note however that Pirate Stick is not limiited to media content gathering and storage. It also includes software for mesh networking using several protocols such as Reticulum, XMPP and yggdrasl. It can serve web pages and bridge communications between network interfaces or act as a WiFi relay or repeater using its' mobile hotspot, useful for public gatherings and events. The ability to utilize a variety of physical transports such as LoRa and packet switched radio in addition to TCP/IP (Internet) and WiFi links is envisioned to make the Pirate Box or Pirate Stick a versatile communications platform.
