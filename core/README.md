# Core Setup

## Packages to install

```bash
sudo apt install pv ddclient dos2unix jq libav-tools ncdu p7zip smartmontools zfstools-linux
```

## .bashrc

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
