# SolarEdge :sun_with_face:

## Activate Modbus via TCP

> 1. Flick the switch on SolarEdge to P and connect your mobile device to the WiFi hotspot (password on the side of the inverter, or use the QR code + mySolarEdge app)
> 2. Open the browser and visit http://172.16.0.1 27 and click on the “Communication” menu item
> 3. Select “RS485-2”
> 4. Choose Protocol “SunSpec (Non-SE Logger)”, also under that set Device ID to 1 (mine was set to 5). Now some Modbus TCP requests were responding.
> 5. Change the Protocol over to “SolarEdge Master” (now a SolarEdge logger script was getting data too)
> 6. Change back protocol to “None”
> 7. Power cycle the inverter for good measure, and it was all still working

## solaredge_modbus

```sh
docker run -it --rm python bash
pip3 install solaredge_modbus
git clone https://github.com/nmakel/solaredge_modbus.git
./example.py 192.168.1.137 15021
```

## Links

- [Python lib: solaredge_modbus](https://github.com/nmakel/solaredge_modbus)
- [Home Assistant custom component: solaredge-modbus-hass](https://github.com/erikarenhill/solaredge-modbus-hass)
- [SolarEdge InfluxDB monitor](https://github.com/salberin/Solaredge-influxdb)
- [SolarEdge Sunspec Implementation](https://www.solaredge.com/sites/default/files/sunspec-implementation-technical-note.pdf)
