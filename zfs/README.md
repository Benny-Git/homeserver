# ZFS

## Testing new disks

```sh
# run short test
sudo smartctl -t short /dev/sdb

# run long test
sudo smartctl -t long /dev/sdb

# show results
sudo smartctl -l selftest /dev/sdb
```

- [Link with more information](https://www.thomas-krenn.com/de/wiki/SMART_Tests_mit_smartctl)

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

> Maybe `zfs send -L` is faster?

Backup disks: `seagate1`, `trekstor1`

```sh
sudo zpool import trekstor1
sudo zfs send tank/fotos@2014-05-02 | sudo zfs receive trekstor1/fotos
sudo zfs send tank/fotos@2016-03-09 | pv | sudo zfs receive seagate1/fotos
sudo zpool export trekstor1
```

```bash
sudo zfs destroy seagate1/music -r
sudo zfs send tank/music@2020-07-19 | pv | sudo zfs receive seagate1/music
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

## Automatic snapshots

We use `zfs-auto-snapshot` to manage automatic snapshots.\
Install with `sudo apt install zfs-auto-snapshot`.\
This creates several `zfs-auto-snapshot` entries in `/etc/cron.*/` which run on different intervals.

## Disk usage check

Inspired by [this reddit post](https://www.reddit.com/r/zfs/comments/w2ujc5/), it would be good to check disk usage if we run low. Snapshots can take up quite a bit of space.

```bash
zfs list -o space
```

We can also check the diff between snapshots:

```bash
sudo zfs diff tank/misc@2016-03-09 tank/misc@2017-05-13
```


## Creating the pools

```bash
sudo zpool create -f -o ashift=12 tank mirror \\
/dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WMC4N1424229 \\
/dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WMC4N1624690
sudo zpool create -f trekstor1 /dev/disk/by-id/usb-SAMSUNG_HD753LI_0002CB36-0:0
sudo zpool create -f toshiba1 /dev/disk/by-id/usb-TOSHIBA_USB_3.5_-HDD_001c37ce-0:0
sudo zpool create -f seagate1 /dev/disk/by-id/ata-ST3000DM001-1ER166_Z5028Z7C

sudo zpool create -f -o ashift=12 dozer /dev/disk/by-id/ata-WDC_WD8004FRYZ-01VAEB0_VY0H4T4M
# attach seconddisk later:
sudo zpool attach dozer /dev/disk/by-id/ata-WDC_WD8004FRYZ-01VAEB0_VY0H4T4M /dev/disk/by-id/ata-WDC_WD8004FRYZ-01VAEB0_VY0MS5DM
```

#### Enable compression:

```bash
sudo zfs set compression=on tank
sudo zfs set compression=on trekstor1
sudo zfs set compression=on toshiba1
sudo zfs set compression=on seagate1
sudo zfs set compression=on dozer
```

#### Setting xattr=sa:

```bash
sudo zfs set xattr=sa seagate1
```
([source](https://www.reddit.com/r/zfs/comments/44dm4l/setting_xattrsa_after_the_fact/))

#### Disable individual sharing of sub filesystems:

```bash
sudo zfs set sharesmb=off tank/fotos
```

#### Enable public share:

```bash
sudo net usershare add share /tank/misc/share "Public Share" Everyone:f guest_ok=yes
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
