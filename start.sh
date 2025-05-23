#!/bin/sh
if [ "${CONFIG}x" == "x" ]; then
	CONFIG=/data/config.ini
fi

if [ ! -e $CONFIG ]; then
	cp /config.ini /data/gns3_server.conf
fi

brctl addbr gns3net0
ip link set dev gns3net0 up
if [ "${BRIDGE_ADDRESS}x" == "x" ]; then
  BRIDGE_ADDRESS=172.21.1.1/24
fi
ip ad add ${BRIDGE_ADDRESS} dev gns3net0
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

dnsmasq -i gns3net0 -z -h --dhcp-range=172.21.1.10,172.21.1.250,4h
gns3server -A --config $CONFIG