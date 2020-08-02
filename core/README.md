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
sudo apt install pv dos2unix jq ncdu p7zip smartmontools nfs-common nfs-kernel-server pdftk ffmpeg zfsutils-linux samba-common-bin samba python3-pip
sudo -H pip3 install --upgrade youtube-dl
```

Not available anymore: `libav-tools`, `zfstools-linux`\
Using `ffmpeg` instead of `avconv` for now: `sudo apt install ffmpeg`\
Using `zfsutils-linux` instead of `zfstools-linux` now.

## DynDNS client

```bash
sudo apt install ddclient
```

Requires information from ddclient.conf. It's easiest to replace /etc/ddclient.conf with the one from this repo.\
TODO: Add pasword to KeePass :)

## .bashrc

#### Bash Aliases

```bash
alias t='tmux new-session -A -s remote'
alias mp3='youtube-dl -x --audio-format mp3 --audio-quality 0'
alias mp3p='youtube-dl -x --audio-format mp3 --audio-quality 0 -o "%(playlist_index)s-%(title)s.%(ext)s" --yes-playlist'
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
