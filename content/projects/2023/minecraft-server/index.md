---
title: "Host a stable Minecraft Server (Java Edition) - A guide for tech savy Players"
summary: ''
date: 2023-05-29
draft: true

---

This is a guide for moderately tech savy, Linux-server interested Minecraft (Java edition) enthusiasts, which would like to host a server for 4 to 20 people and most importantly, learn about Linux, Java edge-cases and community management.
At the end you will have a stable server you can throw bukkit plug-ins at, without having to worry that the server will crash.

## Pick your Hoster
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

This server allowed for an enjoyable experience. Playing Minecraft as well as maintaining it.

## Setup Minecraft for optimal performance
> TL;DR: Use [PaperMC{{<icon "link">}}](https://papermc.io/) and [Aikars Flags{{<icon "link">}}](https://docs.papermc.io/paper/aikars-flags) (or: [the original blog entry{{<icon "link">}}](https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/)) to tune the performance of Minecraft. Setup the Minecraft server as a service to improve ease of use.

There are multiple forks of the Minecraft Server. [Paper{{<icon "link">}}](https://papermc.io/), [Spigot{{<icon "link">}}](https://www.spigotmc.org/), [CraftBukkit{{<icon "link">}}](https://getbukkit.org/) and [Sponge{{<icon "link">}}](https://spongepowered.org/) to name the most popular ones. Paper is the most performant, Sponge supports forge mods, Spigot may be a bit more stable and CraftBukkit is OG. As I'm not interested in forge mods, but very much in performance, Paper is an obvious choice.

Keep in mind that some of the performance gains in Paper are achieved by disabling features that are used by automated farms (e.g. zero tick grow farms). This may impact some players ... which we can ignore for now.

We'll use ssh to access the server. [Here's a good blog entry on how to setup a connection{{<icon "link">}}.](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)

Let's get into the weeds of it. First things first, setup the firewall using `ufw`. Alternatively you can setup the firewall using services by the hoster (Hetzner has a cool tool for this):

```bash
sudo apt install ufw
sudo ufw allow ssh
sudo ufw allow 25565
sudo ufw enable
```

We need Java for Paper, Git and build-essential for mcrcon (more on that later). The current version of [Paper supports Java 17{{<icon "link">}}](https://docs.papermc.io/paper/getting-started):

```bash
sudo apt install openjdk-17-jre-headless
sudo apt install git
sudo apt install build-essential
```

{{<icon "triangle-exclamation">}} Disclaimer, before installing paper: I'm using `paper-1.20.1-33`. Change it to your preferred version. [Get the newest version{{<icon "link">}}](https://papermc.io/downloads/paper) or use the [build explorer{{<icon "link">}}](https://papermc.io/downloads/all) to find a specific minecraft version.

```bash
mkdir -p /opt/minecraft/server/
cd /opt/minecraft/server/
curl -O https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/33/downloads/paper-1.20.1-33.jar
```

Now let's initialize the server. You'll need a text editor for the next step. I prefer nano for its simplicity ([Short nano Tutorial{{<icon "link">}}](https://linuxize.com/post/how-to-use-nano-text-editor/)), but there are lots of alternative options.

```bash
# Start the jar to initialize the server
java -jar paper-1.20.1-33.jar
# Edit eula.txt and set false to true, to accept eula
nano eula.txt
# Run again to create the worlds (Ctrl + C to quit the server)
java -jar paper-1.20.1-33.jar
```



- How to setup as a service
- How to setup mcrcon to have the service stop the server gracefully
- mkdir -p /opt/minecraft/tools/mcrcon/

### Change Minecraft Service settings

`sudo nano /etc/systemd/system/minecraft.service`

Make changes

```bash
sudo systemctl daemon-reload
sudo systemctl stop minecraft
sudo systemctl start minecraft
```

### Use mcrcon

```bash
/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p <password>
```

## Improve Performance
- Identify issues: [Timing](https://timings.aikar.co/)
- Optimize parameters: https://www.spigotmc.org/wiki/reducing-lag/


## Automate a backup
> TL;DR: Use a script to backup the server and optimally push it to another server.

mkdir -p /opt/minecraft/tools/backup/

- Script template (backup and scp to another server)
- How to use cron

## Issues and how to solve them:
- Maybe just a link list?

### Map List Errors
(Observed Errors with random chunks and some MapList errors)<br>
Update to paper-128.jar<br>
Started once with --forceUpgrade to fix MapList<br>
(Errors don’t appear anymore.)

### Plugin RAM Leak - Analyse Heap Dump
https://www.spigotmc.org/threads/guide-finding-the-cause-of-a-ram-issue.272102/<br>
install openjdk-17-jdk-headless<br>
install openjdk-17-dbg<br>
Created heap dump from minecraft server with:<br>
jmap -dump:format=b,file=heapdump_minecraft.hprof 16159<br>
https://www.eclipse.org/mat/

##
- Listen to your players: them having fun is your primary objective

## Further info



## SCP from server / to server
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

Setup Backup:<br>
https://linuxize.com/post/how-to-install-minecraft-server-on-ubuntu-18-04/

Change server.properties:
	Motd to “Lost in this paradise”
	max-players to 69

### Apply Performance Improvements:
https://github.com/YouHaveTrouble/minecraft-optimization

