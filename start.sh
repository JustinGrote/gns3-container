#!/bin/sh
: "${BRIDGE_NAME:=gns3net0}"
: "${BRIDGE_ADDRESS:=172.21.1.1/24}"
: "${BRIDGE_DHCP_START:=172.21.1.10}"
: "${BRIDGE_DHCP_END:=172.21.1.250}"
: "${DHCP_LEASE_AGE:=4h}"
: "${CONFIG:=/data/gns3_server.conf}"

if [ ! -f $CONFIG ]; then
	cp /config.ini $CONFIG
fi

echo "Configuring bridge: name=$BRIDGE_NAME, address=$BRIDGE_ADDRESS, dhcp_range=$BRIDGE_DHCP_START-$BRIDGE_DHCP_END"

# Adds a local bridge network with DHCP and NAT that enables devices to reach the outside world
brctl addbr $BRIDGE_NAME
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to add bridge. Your container probably hasn't been given the capability NET_ADD. Try --cap-add NET_ADMIN"
    exit 1
fi

ip link set dev $BRIDGE_NAME up
ip address add ${BRIDGE_ADDRESS} dev $BRIDGE_NAME
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

dnsmasq -i $BRIDGE_NAME -z -h --dhcp-sequential-ip --dhcp-range=$BRIDGE_DHCP_START,$BRIDGE_DHCP_END,$DHCP_LEASE_AGE 

echo "Starting GNS3 with config path: $CONFIG"
gns3server -A --config $CONFIG
