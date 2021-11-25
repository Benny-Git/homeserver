# Core Setup

## Network and SSH

Lately we used the server with dhcp and managed the "static" IP via the Unifi Controller. This is therefore obsolete:

#### /etc/network/interfaces
```
#iface enp3s0 inet dhcp
iface enp3s0 inet static
    address 192.168.0.7
    netmask 255.255.255.0
    gateway 192.168.0.1
    dns-nameservers 192.168.0.1
```

#### Generate SSH keys for accessing github

```bash
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/github
```

Add to .ssh/config to use:

```
Host github.com
  IdentityFile ~/.ssh/github
```

#### /etc/ssh/sshd_config

```
#PasswordAuthentication yes
PasswordAuthentication no
```

## Remove Snaps

Using [these instructions](https://www.kevin-custer.com/blog/disabling-snaps-in-ubuntu-20-04/):

```bash
snap list                    # shows snaps installed
sudo snap remove <package>   # remove the installed snaps
sudo snap remove lxd
sudo snap remove core18
sudo snap remove snapd
sudo apt purge snapd         # remove snapd itself
```

## Packages to install

```bash
sudo apt install pv dos2unix jq ncdu p7zip smartmontools nfs-common nfs-kernel-server pdftk ffmpeg zfsutils-linux samba python3-pip certbot eyed3
#sudo -H pip3 install --upgrade youtube-dl
sudo -H pip3 install --upgrade youtube-dlc
```

Not available anymore: `libav-tools`, `zfstools-linux`\
Using `ffmpeg` instead of `avconv` for now: `sudo apt install ffmpeg`\
Using `zfsutils-linux` instead of `zfstools-linux` now.

## DynDNS client

Probably not needed anymore, as duckdns is done via Unifi Controller.

```bash
sudo apt install ddclient
```

Requires information from ddclient.conf. It's easiest to replace /etc/ddclient.conf with the one from this repo.\
TODO: Add pasword to KeePass :)

## Correct the timezone

```bash
sudo timedatectl set-timezone "Europe/Berlin"
```

## .bashrc

#### Bash Aliases

```bash
alias t='tmux new-session -A -s remote'
alias mp3='youtube-dlc -x --audio-format mp3 --audio-quality 0'
alias mp3p='youtube-dlc -x --audio-format mp3 --audio-quality 0 -o "%(playlist_index)s-%(title)s.%(ext)s" --yes-playlist'
```

#### Bash History

Some good advise and best practices from this site: https://sanctum.geek.nz/arabesque/better-bash-history/

```bash
shopt -s histappend
HISTFILESIZE=1000000
HISTSIZE=1000000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%F %T '
shopt -s cmdhist
PROMPT_COMMAND='history -a'
```

## ZFS Share

#### Import the pool first
```bash
sudo zpool import tank
```

If it was not exported on the old system, we need to force the import:
```bash
sudo zpool import -f tank
```

```
sudo zfs set sharenfs="rw=@192.168.0.0/24" tank
sudo zfs set sharesmb=on tank
sudo smbpasswd -L -a bertow
sudo smbpasswd -L -e bertow
```

Our printer doesn't like speak newer SMB versions, so accessing the share will only work with this addition to the `etc/samba/smb.conf` under the `workgroup = WORKGROUP` line:

```ini
server min protocol = NT1
```

Then restart smbd (`sudo systemctl restart smbd`)

## Docker
Using [these instructions](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository):
```bash
sudo apt install apt-transport-https ca-certificates gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker $USER
newgrp docker
```

Add Docker Compose [from current releases](https://github.com/docker/compose/releases):
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Automatic cleanup:

Run `crontab -e` and add `0 3 * * * /usr/bin/docker system prune -f`

## Add Certificates

### Manual steps

```bash
# start process
sudo certbot --server https://acme-v02.api.letsencrypt.org/directory -d whoami.bertow.com --manual --preferred-challenges dns-01 certonly

# create entry
curl "https://www.duckdns.org/update?domains=XXXXXXXXX.duckdns.org&token=TTTTTTTT-TTTT-TTTT-TTTT-TTTTTTTTTTTT&txt=challenge-text-token"

#check
dig -t txt ha.bertow.com

# remove
curl "https://www.duckdns.org/update?domains=XXXXXXXXX.duckdns.org&token=TTTTTTTT-TTTT-TTTT-TTTT-TTTTTTTTTTTT&txt=challenge-text-token&clear=true"
```
https://www.edvpfau.de/wildcard-zertifikat-mit-duckdns-erstellen/

### Easier steps with hook scripts (see below)

```bash
sudo certbot --server https://acme-v02.api.letsencrypt.org/directory -d whoami.bertow.com --manual-auth-hook=/etc/letsencrypt/duckdns/set_acme_challenge.sh --manual-cleanup-hook=/etc/letsencrypt/duckdns/cleanup_acme_challenge.sh --manual --preferred-challenges dns-01 certonly
```

## Certificate renewal

Move [hook scripts](../scripts/duckdns) to /etc/letsencrypt/duckdns

```bash
sudo certbot renew --manual-auth-hook=/etc/letsencrypt/duckdns/set_acme_challenge.sh --manual-cleanup-hook=/etc/letsencrypt/duckdns/cleanup_acme_challenge.sh --manual-public-ip-logging-ok --deploy-hook="docker-compose -f /tank/misc/docker/traefik/docker-compose.yaml restart"
```
https://www.edvpfau.de/automatische-erneuerung-der-letsencrypt-wildcard-zertifikate-mit-duckdns/

## Dropbox

Setup to `/tank/misc/Dropbox` as instructed on https://www.linuxbabe.com/ubuntu/install-dropbox-headless-ubuntu-server and https://www.how2shout.com/linux/install-dropbox-gui-or-headless-on-ubuntu-20-04-lts/
```bash
wget https://www.dropbox.com/download?plat=lnx.x86_64 -O dropbox-linux.tar.gz
sudo mkdir /opt/dropbox/
sudo tar xvf dropbox-linux.tar.gz --strip 1 -C /opt/dropbox
sudo apt install libc6 libglapi-mesa libxdamage1 libxfixes3 libxcb-glx0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 libxcb-sync1 libxshmfence1 libxxf86vm1
ln -s /tank/misc/Dropbox ~/Dropbox
/opt/dropbox/dropboxd
```

Sudo Add `/etc/systemd/system/dropbox.service`:
```
[Unit]
Description=Dropbox Daemon
After=network.target

[Service]
Type=simple
User=bertow
ExecStart=/usr/bin/env "/home/bertow/.dropbox-dist/dropboxd"
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
```

Enable autostart:
```bash
sudo systemctl start dropbox
sudo systemctl enable dropbox
systemctl status dropbox
```

Install CLI tool:
```bash
sudo wget -O /usr/local/bin/dropbox "https://www.dropbox.com/download?dl=packages/dropbox.py"
sudo chmod +x /usr/local/bin/dropbox
```
