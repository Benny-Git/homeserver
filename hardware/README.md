# Home Server Hardware

## Specs

- HPE ProLiant MicroServer Gen11 (P68821-421)
- 4x GBit LAN
- 2x USB3.2 Gen2
- 4x USB3.2 Gen1
- VGA + DisplayPort
- 1 PCIe 5 x16
- 1 PCIe 4 x8
- IPMI with ILO Module P65741-B21 incl. M.2 Slot
  - Key M
  - 2280 or 22110
- [Intel Xeon E-2434](https://ark.intel.com/content/www/us/en/ark/products/236192/intel-xeon-e-2434-processor-12m-cache-3-40-ghz.html)
- 1x 16GB DDR5 ECC 4400 (4 UDIMM Slots in total, max 32GB each)
- 180W external Powersupply
- [Kingston Fury Renegade 1.0TB PCIe 4.0 NVMe M.2 (5 years warranty)](https://www.kingston.com/en/ssd/gaming/kingston-fury-renegade-nvme-m2-ssd?partnum=sfyrs%2F1000g)
  - Controller: Phison E18
  - NAND: 3D TLC
  - Limited 5-year warranty with free technical support
  - MTBF: 2,000,000 hours
  - [Datasheet](https://www.kingston.com/datasheets/sfyr_en.pdf) ([Local](sfyr_en.pdf))

## Documentation

- https://www.hpe.com/info/microservergen11-docs
- [HPE ProLiant MicroServer Gen11 User Guide](https://support.hpe.com/hpesc/public/docDisplay?docId=sd00003930en_us&docLocale=en_US) ([Local](HPE_sd00003930en_us_HPE%20ProLiant%20MicroServer%20Gen11%20User%20Guide.pdf))
- [HPE ProLiant MicroServer Gen11 Maintenance and Service Guide](https://support.hpe.com/hpesc/public/docDisplay?docId=sd00003924en_us&docLocale=en_US) ([Local](HPE_sd00003924en_us_HPE%20ProLiant%20MicroServer%20Gen11%20Maintenance%20and%20Service%20Guide.pdf))
- [Extended Ambient Temperature Guidelines for HPE Gen11 Servers](https://support.hpe.com/hpesc/public/docDisplay?docId=sd00002260en_us&docLocale=en_US)
- [HPE Smart Choice Purchase Program – Supplemental QuickSpecs](https://support.hpe.com/hpesc/public/docDisplay?docId=a50009219enw&docLocale=en_US) ([Local](HPE_a50009219enw_HPE%20Smart%20Choice%20Purchase%20Program%20–%20Supplemental%20QuickSpecs.pdf))
- [QuickSpecs HPE ProLiant MicroServer Gen11](https://support.hpe.com/hpesc/public/docDisplay?docId=a50007028enw&docLocale=en_US) ([Local](HPE_a50007028enw_HPE%20ProLiant%20MicroServer%20Gen11.pdf))
- [HPE ProLiant Cabling Matrix](https://support.hpe.com/hpesc/public/docDisplay?docId=sd00001997en_us&docLocale=en_US)
- [iLO Guides](https://www.hpe.com/support/ilo6)

## Tickets and stuff

- https://community.hpe.com/t5/proliant-servers-ml-dl-sl/m-2-not-working-with-ilo6-module-in-hpe-proliant-microserver/m-p/7226004
- https://www.reddit.com/r/techsupport/comments/1fkge0b/m2_nvme_not_working_with_ilo6_module_in_hpe/
- Bifurcation support: 5384954918
- M.2 support: 5384702130
- M.2 speed: 5385094192

## NVMe optimization

### Sector size

The NVMe runs with a sector size of 512B by default, which is also what it reports:

```
root@hulk:~# parted /dev/nvme0n1 unit s print
Model: KINGSTON SFYRS1000G (nvme)
Disk /dev/nvme0n1: 1953525168s
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start        End          Size        File system     Name  Flags
 1      2048s        1050623s     1048576s    fat32                 boot, esp
 2      1050624s     977612799s   976562176s  ext4
 3      977612800s   1040113663s  62500864s   linux-swap(v1)        swap
 4      1040113664s  1953523711s  913410048s
```

The _actual_ physical sector size should be 4K however, but by default the 512B-emulation mode is active. To check this:

```
root@hulk:~# nvme id-ns -H /dev/nvme0n1
NVME Identify Namespace 1:
...
LBA Format  0 : Metadata Size: 0   bytes - Data Size: 512 bytes - Relative Performance: 0x2 Good (in use)
LBA Format  1 : Metadata Size: 0   bytes - Data Size: 4096 bytes - Relative Performance: 0x1 Better
```

To reformat this, the following command can be used (*but it will erase the drive!*):

```
nvme format --lbaf=1 /dev/nvmeXnY
```

Potentially useful:
```
lsblk -td
```

Sources for the above:
- https://bbs.archlinux.org/viewtopic.php?id=298493
- https://bbs.archlinux.org/viewtopic.php?id=289806

### NVMe Speed

Checking to see how the NVMe is connected, we see that it only has PCIe 3x1 speeds, instead of the 4x4 it would support:

```
root@hulk:~# lspci
...
03:00.0 Non-Volatile memory controller: Kingston Technology Company, Inc. KC3000/FURY Renegade NVMe SSD E18 (rev 01)

root@hulk:~# lspci -vv -s 03:00.0
...
LnkCap: Port #0, Speed 16GT/s, Width x4, ASPM L1, Exit Latency L1 <64us
...
LnkSta: Speed 8GT/s (downgraded), Width x1 (downgraded)
...
```

I guess this is just the limit of the iLO M.2 implementation.
