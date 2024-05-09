# Unifi

## Add static DNS entry

Get SSH from UI console -> Settings -> System -> Advanced

> ssh into USG, and edit the static config file:
> `sudo vi /etc/dnsmasq.d/dnsmasq.static.conf`
> 
> add the host and ipaddress:
> `address=/myhost.mydomain.com/192.168.2.1`
> 
> save, then activate that with:
> `sudo /etc/init.d/dnsmasq force-reload`

[Source](https://flores.eken.nl/static-dns-record-in-unifi-usg/)
