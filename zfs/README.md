# ZFS

## Commonly used commands

#### Status and Scrub

```sh
sudo zpool status
sudo zpool scrub tank
```

#### Snapshots, Backups, etc

```sh
sudo zfs list -t snapshot
sudo zfs get all tank
sudo zfs list

sudo zfs snapshot tank@2014-04-29
sudo zfs snapshot tank/fotos@2014-04-29
```

#### External backup

Backup disks: `seagate1`, `trekstor1`

```sh
sudo zpool import trekstor1
sudo zfs send tank/fotos@2014-05-02 | sudo zfs receive trekstor1/fotos
sudo zfs send tank/fotos@2016-03-09 | pv | sudo zfs receive seagate1/fotos
sudo zpool export trekstor1
```

## Links

- [A good tutorial](https://pthree.org/2012/04/17/install-zfs-on-debian-gnulinux/)
