FROM armv7/armhf-ubuntu:16.10
MAINTAINER snchan20@yahoo.com

# setup environment
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# install OpenVPN
RUN apt-get -qq update && \
    apt-get install -qy openvpn dante-server iptables iputils-ping traceroute vim && \
    apt-get autoremove && apt-get clean && \
    rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*

VOLUME ["/etc/openvpn"]

EXPOSE 8119
EXPOSE 1194/udp

# Copy scripts/config
COPY ./danted.conf /etc
COPY ./vpn-entrypoint.sh /
RUN chmod +x /vpn-entrypoint.sh

ENTRYPOINT ["/vpn-entrypoint.sh"]
