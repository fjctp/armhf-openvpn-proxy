# armhf-openvpn-proxy
This is used to create a docker image for a proxy server. The server establish a OpenVPN connection given a config file. Then, it shares that connection using SOCKS proxy server (port 8119).

# Build
run `build-latest-images.sh`

# Start
## Environment variables
```
OPENVPN_CONFIG: name of openvpn config (in /etc/openvpn)
HOST_LAN: host lan IP range
HOST_IP: host IP address in docker network
```
## interative
run `start-interactive.sh`
## daemon
run `start-daemon.sh`
