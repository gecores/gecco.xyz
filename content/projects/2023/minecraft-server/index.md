---
title: "Host a stable Minecraft Server - A guide for tech savy Players"
summary: ''
date: 2023-05-29
draft: true

---

This is a guide for moderately tech savy, Linux-server interested Minecraft enthusiasts, which would like to host a server for 4 to 20 people and most importantly, learn about Linux, Java edge-cases and community management.
At the end you will have a stable server you can throw bukkit plug-ins at, without having to worry that the server will crash.

## Hosting
> TL;DR: You shouldn't choose the cheapest hoster as there can be significant differences. Try different options and fail-fast. (Hetzner worked out great for me)

Picking a hoster is like choosing a matress. You can pay for the most expensive option and *"invest into a third of your life"* and
you have to make sure that the mattress fits your needs, especially if you have specific requirements, but in the end it's still just a mattress.

A gaming server is a very specific requirement. Minecraft servers even more so as they aren't very parallelizable and need a big chunk of RAM. Typical Server CPUs have a high count of cores, but a low single core performance. Therefore the selection of the correct Server may be critical if you have a higher number of players.
Additionally multiplayer games are sensitive to lag, therefore storage and networking should be optimized as well.

Keeping in mind all of the above, we can optimize for the following factors:

- **Increase**
  - Single core performance
  - RAM
  - IOPS for Storage (RAID 10 NVMe SSD Storage should definitely do it)
- **Decrease**
  - Network lag (e.g. decrease distance to Hoster)
  - Cost

At first I chose strato.de as they had one of the cheapest options for a VM. Hosted a server quickly, but I had issues with heavy lag spikes everytime a chunk got loaded. After further analysis I concluded that their storage wasn't fast enough to keep up with the demand. Pre-generating and loading chunks into RAM, could've been a solution, but I decided against that, as everytime a player would go out of the pre-loaded area, the server would freeze up for everybody.

The [VMs at Hetzner{{<icon "link">}}](https://www.hetzner.com/de/cloud) were in a totally different league. I chose a server with the following specs:
```
vServer:        CX31
CPU vCores:     2 (Intel Xeon Gold)
RAM:            8 GB
Storage:        80 GB (RAID 10 NVMe SSDs)
OS:             <insert favorite linux distro>
Location:       Germany
Price:          ~11,50€
```



## Challenges I'd like to write about:
- Hoster (Strato and issues with them -> solution Hetzner)
- Minecraft Performance (Switch from normal minecraft -> spigot -> papermc)
- Automation & Backup (scp regularly from one server to another)
- Plug-In Memory Leak (Analyze Heap Dumps and find issue)

- Minor Challenge: MapList Errors
- Listen to your players: them having fun is your primary objective


## Admin-Log

## How-To
### Change Minecraft Service settings

`sudo nano /etc/systemd/system/minecraft.service`

Make changes

```bash
sudo systemctl daemon-reload
sudo systemctl stop minecraft
sudo systemctl start minecraft
```

### Map List Errors
(Observed Errors with random chunks and some MapList errors)<br>
Update to paper-128.jar<br>
Started once with --forceUpgrade to fix MapList<br>
(Errors don’t appear anymore.)
### Analyse Heap Dump
https://www.spigotmc.org/threads/guide-finding-the-cause-of-a-ram-issue.272102/<br>
install openjdk-17-jdk-headless<br>
install openjdk-17-dbg<br>
Created heap dump from minecraft server with:<br>
jmap -dump:format=b,file=heapdump_minecraft.hprof 16159<br>
https://www.eclipse.org/mat/
### Use mcrcon
/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p QX48ghFhhcDwW9Vf4wQ9VfxC

SCP from server / to server<br>
scp (-r -> for folder) user@IP:/path/to/folder/or/file.ext
## Setup
### From scratch
(using Hetzner’s Firewall -> ssh aka 22 and 25565)<br>
apt install openjdk-17-jre-headless<br>
apt install git<br>
apt install build-essential

mkdir /opt/minecraft/server/<br>
Downloaded latest PaperMC jar file from https://papermc.io/downloads with curl

curl https://papermc.io/api/v2/projects/paper/versions/1.18.2/builds/261/downloads/paper-1.18.2-261.jar --output /opt/minecraft/server/paper-1.18.2-261.jar

Start jar with<br>
`java -jar paper-365.jar`

Accept eula with nano eula.txt

Download plugins (curl didn’t work out of the box) and send via scp:<br>
https://songoda.com/marketplace/product/ultimatetimber-the-realistic-tree-chopper.18
Ultimatetimber-2.0.6.jar

Harbor.jar<br>
https://www.spigotmc.org/resources/harbor-a-sleep-enhancement-plugin.60088/

Add CoreProtect<br>
https://www.spigotmc.org/resources/coreprotect.8631/

### Change spigot.yml, bukkit.yml and server.properties according to:
https://www.spigotmc.org/wiki/reducing-lag/

Setup Minecraft as a service:<br>
https://linuxize.com/post/how-to-install-minecraft-server-on-ubuntu-18-04/

### Tuning the JVM – G1GC Garbage Collector Flags for Minecraft
https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/

Setup Backup:<br>
https://linuxize.com/post/how-to-install-minecraft-server-on-ubuntu-18-04/

Change server.properties:
	Motd to “Lost in this paradise”
	max-players to 69

### Apply Performance Improvements:
https://github.com/YouHaveTrouble/minecraft-optimization

