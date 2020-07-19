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

Incremental backup:

```bash
sudo zfs list -t snapshot
NAME                         USED  AVAIL  REFER  MOUNTPOINT
seagate1@2016-03-09           64K      -    96K  -
seagate1/misc@2016-03-09    21.4M      -   112G  -
tank@2020-07-19                 0      -   168K  -
tank@2020-07-19                 0      -   168K  -
tank/misc@2016-03-09        8.23G      -   113G  -
tank/misc@2017-05-13         266M      -  85.7G  -
tank/misc@2018-12-31         214M      -  90.0G  -
tank/misc@2020-07-19            0      -   118G  -

sudo zfs send -i tank/misc@2016-03-09 tank/misc@2020-07-19 | pv | sudo zfs receive seagate1/misc
cannot receive incremental stream: destination seagate1/misc has been modified

# So we will need to rollback seagate1 first:
sudo zfs rollback seagate1/misc@2016-03-09
sudo zfs send -i tank/misc@2016-03-09 tank/misc@2020-07-19 | pv | sudo zfs receive seagate1/misc
```

## Links

- [A good tutorial](https://pthree.org/2012/04/17/install-zfs-on-debian-gnulinux/)

## Repairing an issue with "Failed to load ZFS module stack."

Link that this is taken from: https://github.com/zfsonlinux/zfs/issues/1155
Get the version number of the registered modules:

```bash
# dkms status
(eg: 0.6.0.90 for the daily ppa.)
Try to build the modules manually:
# dkms remove  -m zfs -v 0.6.0.90 --all
# dkms remove  -m spl -v 0.6.0.90 --all
# dkms add     -m spl -v 0.6.0.90
# dkms add     -m zfs -v 0.6.0.90
# dkms install -m spl -v 0.6.0.90
# dkms install -m zfs -v 0.6.0.90
```
