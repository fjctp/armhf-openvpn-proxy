#!/bin/bash

docker run -d --restart unless-stopped \
  --name openvpn-proxy \
  -e OPENVPN_CONFIG="main.conf" \
  -e HOST_LAN="192.168.1.0/24" \
  -e HOST_IP="172.17.0.1" \
  -p 8119:8119 \
  -p 1194:1194/udp \
  -v /etc/openvpn:/etc/openvpn \
  --cap-add NET_ADMIN \
  --dns=8.8.8.8 \
  fjctp/armhf-openvpn-proxy
