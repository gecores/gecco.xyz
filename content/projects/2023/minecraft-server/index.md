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

### Start with the server
Let's get into the weeds of it. First things first, setup the firewall using `ufw`. Alternatively you can setup the firewall using services by the hoster (Hetzner has a cool tool for this):

```bash
sudo apt update
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
sudo apt install make
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

After the Minecraft server created the worlds successfully we can setup a Linux service to start and stop the server. To be able to gracefully stop the Minecraft server (aka. not kill the process, but let it shutdown properly), we need mcrcon.

### Install mcrcon
mcrcon (Minecraft Remote Console) allows us to run commands in Minecraft as if we're a Minecraft Administrator. Let's install it:

```bash
mkdir -p /opt/minecraft/tools/
cd /opt/minecraft/tools/
git clone https://github.com/Tiiffi/mcrcon.git
cd mcrcon
make
```

Test if this installation was successful by running `mcrcon -h`. You should see info regarding the usage of `mcrcon`.

Now change the server properties to be able to access the Minecraft server via mcrcon

```bash
nano /opt/minecraft/server/server.properties
```
Change the follwing lines (of course use something else for "strong-password"):

```bash
rcon.port=25575
rcon.password=strong-password
enable-rcon=true
```

### Create a Minecraft Server service
Let's use everything we have created so far and add a Linux service:

```bash
sudo nano /etc/systemd/system/minecraft.service
```

We'll use [Aikars Flags{{<icon "link">}}](https://docs.papermc.io/paper/aikars-flags) to optimize the Java process. Use the following configuration as a template:

```bash
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=root
Nice=1
KillMode=none
SuccessExitStatus=0 1
ProtectHome=true
ProtectSystem=full
PrivateDevices=true
NoNewPrivileges=true
WorkingDirectory=/opt/minecraft/server
ExecStart=/usr/bin/java -Xms2048M -Xmx2048M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar /opt/minecraft/server/paper-1.20.1-33.jar nogui
ExecStop=mcrcon -H 127.0.0.1 -P 25575 -p strong-password stop

[Install]
WantedBy=multi-user.target
```

{{<icon "triangle-exclamation">}} Before using this configuration. Change the following aspects:
- At the start of `ExecStart=...` adapt `-Xms2048M -Xmx2048M` to your available RAM, **minus** 1024M (your system needs some RAM, too).
- At the end of `ExecStart=...` there needs to be the correct filename. Replace `paper-1.20.1-33.jar` by the version you have.
- In `ExecStop=...` replace the not so strong `strong-password` by your strong password.

Everytime you change a service, remember to reload the new configuration and (re-)start the Minecraft server:

```bash
sudo systemctl daemon-reload
sudo systemctl stop minecraft
sudo systemctl start minecraft
```

## Automate a backup
> TL;DR: Use a script to backup the minecraft server.

```bash
mkdir -p /opt/minecraft/backups/
mkdir -p /opt/minecraft/tools/backup/
nano /opt/minecraft/tools/backup/backup.sh
```

```bash
#!/bin/bash

function rcon {
  mcrcon -H 127.0.0.1 -P 25575 -p QX48ghFhhcDwW9Vf4wQ9VfxC "$1"
}

rcon "save-off"
rcon "save-all"
FILE=/opt/minecraft/backups/server-$(date +%F_%R).tar.gz
tar -cvpzf $FILE /opt/minecraft/server
rcon "save-on"

## Delete older backups
find /opt/minecraft/backups/ -type f -mtime +7 -name '*.gz' -delete
```

```bash
chmod +x /opt/minecraft/tools/backup/backup.sh
```

```bash
crontab -e
```

```bash
0 4 * * * /opt/minecraft/tools/backup/backup.sh
```

## Have fun playing!
Your server is up and running. Now it's time to play.

### Awesome plugins to use on your Server
- [UltimateTimber{{<icon "link">}}](https://craftaro.com/marketplace/product/ultimatetimber.18) a beautiful plugin to cut down trees whole easier.
- [Harbor{{<icon "link">}}](https://www.spigotmc.org/resources/harbor-a-sleep-enhancement-plugin.60088/) allows to skip the night if enough players go to bed.
- [CoreProtect{{<icon "link">}}](https://www.spigotmc.org/resources/coreprotect.8631/) logs every block change and traces who is responsible for griefing. Enables Administrators to revert damages.
- [GSit{{<icon "link">}}](https://www.spigotmc.org/resources/gsit-modern-sit-seat-and-chair-lay-and-crawl-plugin-1-13-1-20-2.62325/) is a fun plugin to sit on chairs or lay on the floor.

## (Optional) Advanced improvements
- Identify issues: [Timing](https://timings.aikar.co/)
- Optimize parameters: https://www.spigotmc.org/wiki/reducing-lag/


### Plugin RAM Leak - Analyse Heap Dump
https://www.spigotmc.org/threads/guide-finding-the-cause-of-a-ram-issue.272102/<br>
install openjdk-17-jdk-headless<br>
install openjdk-17-dbg<br>
Created heap dump from minecraft server with:<br>
jmap -dump:format=b,file=heapdump_minecraft.hprof 16159<br>
https://www.eclipse.org/mat/


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


## Cheatsheet

### Stop / Start the Minecraft Server
```bash
sudo systemctl stop minecraft
sudo systemctl start minecraft
```

### Update / Upgrade Paper MC
[TODO]

### Check logs
[TODO]

### Edit the Minecraft service
```bash
sudo nano /etc/systemd/system/minecraft.service
```

And apply the changes:

```bash
sudo systemctl daemon-reload
sudo systemctl stop minecraft
sudo systemctl start minecraft
```

### Use mcrcon manually
```bash
mcrcon -H 127.0.0.1 -P 25575 -p <strong-password> -t
```

Use [Minecraft commands{{<icon "link">}}](https://minecraft.fandom.com/wiki/Commands#List_and_summary_of_commands), but without the slash `/`.

### Copy from / to the server
```bash
scp [-r] user@IP:/path/to/folder/or/file.ext /path/to/folder
```

Examples:
```bash
# Upload a plugin to the server
scp /home/<user>/Downloads/plugin.jar root@<server-ip>:/opt/minecraft/server/plugins/
# Download a backup from the server
scp root@<server-ip>:/opt/minecraft/backups/2023-07-16_minecraft_server_backup.tar.gz /home/<user>/Downloads/
```

### Fix 'Map List Errors' after update
Start the Minecraft server manually with `--forceUpgrade`:
```bash
java -jar paper-1.20.1-33.jar --forceUpgrade
```
`Ctrl - C` to quit the server after it's done loading the map. Then start
