#!/bin/bash

SCRIPT="$(realpath $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

vpn_config="$(grep vpn_config $SCRIPTPATH/vpn_runner.sh | head -n 1 | cut -d '=' -f 2 | sed -r 's/\"//g')"

wait_for_vpn(){
	while [ ! -f /tmp/vpn_change.vpnsh ]; do
		echo "Waiting For VPN to write files"
		sleep 1
	done		
	while [ ! -f /tmp/vpn_config.vpnsh ]; do
		echo "Waiting For VPN to write files"
		sleep 1
	done
}

if [ -z $1 ]; then
	wait_for_vpn
	read -p "Press enter to set VPN to use London" tmp
	echo "uk-london-lon-a1" > $vpn_config
	read -p "Press enter to restart vpn"
	echo 0 > /tmp/vpn_change.vpnsh
else
	echo "$1" > $vpn_config
	echo 0 > /tmp/vpn_change.vpnsh
fi
echo done
