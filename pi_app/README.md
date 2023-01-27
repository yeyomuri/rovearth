# Raspberry Pi  Python Code

Código python que permite controlar el rover. Está conectado a la app mobile mediante bluetooth.

Para este proyecto es necesario activar Bluetooth y enparejarlo con el dispositivo movil.

Bluetooth configuration on raspberr pi.

0.) Mobile app bluetooth pairing

	$ sudo bluetoothctl
	# power on
	# agent on
	# scan on
	# pair [MAC of the Flutter host]
	# quit


$ sudo nano /etc/systemd/system/dbus-org.bluez.service

2.) Add -C and next line

	ExecStart=/usr/libexec/bluetooth/bluetoothd -C
	ExecStartPost=/usr/bin/sdptool add SP

$ sudo systemctl daemon-reload

$ sudo systemctl restart bluetooth.service

$ sudo pip3 install bluedot

