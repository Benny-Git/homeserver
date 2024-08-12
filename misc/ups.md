# UPS

The APC UPS is covering the home server, as well as the switch and router, fibre optic subscriber connection, phone hub, and connected external disk drives. It is connected via a USB cable to the server to allow monitoring and reacting.

In order to monitor the UPS, install apcupsd with

```
sudo apt install apcupsd
```

After that, configure `/etc/apcupsd/apcupsd.conf` to have `UPSTYPE usb` (default) and empty the `DEVICE` entry (default is `/dev/ttyS0` which is incorrect), then restart the daemon with

```
sudo systemctl restart apcupsd
```

We can get the current status with `apcaccess`.
