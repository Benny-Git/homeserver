# Ansible setup of homeserver

Let's move from running commands manually to use Ansible instead.

## Prereqs

### (passwordless) ssh setup

- optionally create new key (`ssh-keygen -t ed25519`)
- create `~/.ssh/config` entry for server
- copy key over with `ssh-copy-id -i <keyid> <user>@<ip>`

## Run

```
ansible-playbook setup.yml -K
```

