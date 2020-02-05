#!/usr/bin/env bash

download(){
	mkdir -p configs
	cd configs 
	rm *
	wget https://www.ipvanish.com/software/configs/configs.zip
	unzip configs.zip
	rm configs.zip
}

update(){
	cd configs
	for file in *.ovpn ; do
		echo "updating config $file...."
		echo -e "script-security 2\nup /etc/openvpn/update-resolv-conf\ndown /etc/openvpn/update-resolv-conf\n" >> $file
		sed -i "s|ca ca.ipvanish.com.crt|ca $HOME/vpn/configs/ca.ipvanish.com.crt|g" "$file"
	done
}

download
update


