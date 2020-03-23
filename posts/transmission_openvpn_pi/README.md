# Run your Transmission download server via OpenVPN

### Check the client key for OpenVPN
- Get the new/existing client key from OpenVPN server with *.ovpn extension WITHOUT PASSPHARASE. Usually it is "-nopass" parameter depending on the server. You will save time and bran cells with this.

- Put the this line inside the client ovpn configuration body if the client app does not support blocking outside dns to avoid errors:
	```
	pull-filter ignore "block-outside-dns"
	```

### Use docker image with the preinstalled software

https://github.com/haugene/docker-transmission-openvpn

https://haugene.github.io/docker-transmission-openvpn/known-issues/

	```bash
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
	```

where you should change the following parameters:
1. /media/pi/ADataPort01/Downloads/:/data - local folder for storing data
2. -v /home/pi/pimedia.ovpn:/etc/openvpn/custom/default.ovpn \
   -v /home/pi/pimedia.ovpn:/config/openvpn-credentials.txt \ 
      - this is a hack for using own OpenVPN service 
        (the client config file must be unencrypted - no passphrase!)
3. LOCAL_NETWORK - network address pi to be accesable in local network


### When the best configuration is found its time to put it as a service to execute after the system boot, use it headless.

	```
	touch /etc/systemd/system/transmission-openvpn.service
	```

For linux user 'pi'. 
Note the parameter '--name transmission-openvpn' when copy paste the config line.
	```
	[Unit]
	Description=transmission-openvpn docker container
	After=docker.service
	Requires=docker.service

	[Service]
	User=pi
	TimeoutStartSec=0
	ExecStartPre=-/usr/bin/docker kill transmission-openvpn
	ExecStartPre=-/usr/bin/docker rm transmission-openvpn
	ExecStartPre=/usr/bin/docker pull haugene/transmission-openvpn
	ExecStart=/usr/bin/docker run \
				--name transmission-openvpn \
				--restart=always \
				--cap-add=NET_ADMIN --privileged -d \
				  -v /media/pi/ADataPort01/Downloads/:/data \
				  -v /etc/localtime:/etc/localtime:ro \
				  -v /home/pi/pimedia.ovpn:/etc/openvpn/custom/default.ovpn \
				  -v /home/pi/pimedia.ovpn:/config/openvpn-credentials.txt \
				  -e ENABLE_UFW=true \
				  -e UFW_ALLOW_GW_NET=true \
				  -e UFW_EXTRA_PORTS=51413 \
				  -e UFW_DISABLE_IPTABLES_REJECT=true \
				  -e CREATE_TUN_DEVICE=true \
				  -e OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60 \
				  -e OPENVPN_PROVIDER=CUSTOM \
				  -e OPENVPN_CONFIG=/etc/openvpn/custom/default \
				  -e WEBPROXY_ENABLED=false \
				  --log-driver json-file \
				  --log-opt max-size=10m \
				  --dns 8.8.8.8 \
				  -e LOCAL_NETWORK=192.168.178.39 \
				  -p 9091:9091 \
				  haugene/transmission-openvpn:latest-armhf

	[Install]
	WantedBy=multi-user.target
	```

Enable the new servie
	```bash
	sudo systemctl enable /etc/systemd/system/transmission-openvpn.service
	sudo systemctl restart transmission-openvpn.service
	```

Starting/Stopping the service on demand
	```bash
	sudo systemctl stop transmission-openvpn.service
	sudo systemctl start transmission-openvpn.service
	```


### Issues

https://github.com/kylemanna/docker-openvpn/issues/39
```
docker run --privileged
docker run --cap-add=NET_ADMIN --device=/dev/net/tun
```




### Some useful docker tricks for testing the settings

stop and remove all the running containers (avoid ip and other issues)
	```bash
	docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
	```

run a new container and output logs
	```bash
	docker logs $(bash transmission_run_docker.sh)
	```

check the current IP using tunnel (check if matches with the expected)
	```bash
	docker exec -i -t 66c831ea64a1 /bin/bash -c "curl -s http://whatismyip.akamai.com/"
	```

running openvpn manually
	```bash
	openvpn --config /etc/openvpn/custom/default.ovpn 
	```
