# Change parameters:
# 1. /media/pi/ADataPort01/Downloads/:/data - local folder for storing data
# 2. -v /home/pi/pimedia.ovpn:/etc/openvpn/custom/default.ovpn \
#    -v /home/pi/pimedia.ovpn:/config/openvpn-credentials.txt \ 
#      - this is a hack for using own OpenVPN service 
#        (the client config file must be unencrypted - no passphrase!)
# 3. LOCAL_NETWORK - network address pi to be accesable in local network

docker run --cap-add=NET_ADMIN --privileged -d \
              -v /media/pi/ADataPort01/Downloads/:/data \
              -v /etc/localtime:/etc/localtime:ro \
              -v /home/pi/pimedia.ovpn:/etc/openvpn/custom/default.ovpn \
              -v /home/pi/pimedia.ovpn:/config/openvpn-credentials.txt \
              -e ENABLE_UFW=true \
              -e UFW_ALLOW_GW_NET=true \
              -e UFW_EXTRA_PORTS=51413 \
              -e UFW_DISABLE_IPTABLES_REJECT=true \
              -e CREATE_TUN_DEVICE=true \
              -e OPENVPN_PROVIDER=CUSTOM \
              -e OPENVPN_CONFIG=/etc/openvpn/custom/default \
              -e WEBPROXY_ENABLED=false \
              --log-driver json-file \
              --log-opt max-size=10m \
              --dns 8.8.8.8 \
              -e LOCAL_NETWORK=192.168.178.39 \
              -p 9091:9091 \
              haugene/transmission-openvpn:latest-armhf

# -e LOCAL_NETWORK=192.168.0.10 \
#-e LOCAL_NETWORK=192.168.178.10 \
#-e DROP_DEFAULT_ROUTE=true \

#docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
#docker logs $(bash transmission_run_docker.sh)
#docker exec -i -t 665b4a1e17b6 /bin/bash

#docker run --privileged
#docker run --cap-add=NET_ADMIN --device=/dev/net/tun
#https://github.com/kylemanna/docker-openvpn/issues/39

#curl -s http://whatismyip.akamai.com/

#openvpn status
#openvpn --config /etc/openvpn/custom/default.ovpn 
