#!/bin/bash
set -e

SOCKS_PROXY_PORT=8119
OPENVPN_PORT=1194

function setup_rules {
    # add route to local lan
    echo "add route $HOST_LAN via $HOST_IP"
    ip route add $HOST_LAN via $HOST_IP

    # block all ports except 8119 (proxy), 4443 (openvpn), 53 (DNS)
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    iptables -A INPUT -i tun0 -j ACCEPT
    iptables -A OUTPUT -o tun0 -j ACCEPT

    # Dante
    iptables -A INPUT -i eth0 -p tcp --dport $SOCKS_PROXY_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -o eth0 -p tcp --sport $SOCKS_PROXY_PORT -m state --state ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    # OpenVPN
    iptables -A INPUT -p udp --dport $OPENVPN_PORT -m state --state ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p udp --sport $OPENVPN_PORT -m state --state NEW,ESTABLISHED -j ACCEPT

    iptables -A INPUT -p udp --sport 53 -j ACCEPT
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
}

# setup routes and iptables
setup_rules

# Start service
echo "Create tun"
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

echo "Using $OPENVPN_CONFIG for OpenVPN"
echo -n "Start OpenVPN"
openvpn --daemon --cd /etc/openvpn --config $OPENVPN_CONFIG
while [ -z "$(tail -n 5 /var/log/openvpn.log | grep -i "Initialization Sequence Completed")" ]; do 
    echo -n "."
    sleep 1
done
echo "done"

echo "Start Dante...done"
if [ $# -gt 0 ]; then
    danted -D -f /etc/danted.conf
    exec "$@"
else
    danted -f /etc/danted.conf
fi