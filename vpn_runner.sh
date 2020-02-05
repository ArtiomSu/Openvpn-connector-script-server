#!/bin/bash


aggressive_checker=5 # seconds to chech if vpn is up
wait_for_vpn_to_become_active=20 # seconds	#used to be 30 so might revert

# get path to call helper properly
SCRIPTPATH="/home/human/scrips/vpn/s/Openvpn-connector-script-server"

vpn_change_trigger="/tmp/vpn_change.vpnsh"
vpn_ready_notify="/tmp/vpn_ready.vpnsh"
config=""

testpass() {
	if [ -z "$PASSWORD" ];
	then
		echo "Error getting password" 
		exit 1

	fi	
}

launchvpn() {
	testpass
	#config="$(ls /root/vpn/configs/*UK*.ovpn |sort -R |tail -n 1)" # for uk only
	config="$(ls $SCRIPTPATH/configs/*.ovpn |sort -R |tail -n 1)"
	echo "using config ${config##*/}"
	$SCRIPTPATH/vpn-helper.sh $PASSWORD $config
}

testnetwork() {
	upcount=0
	ping wikipedia.com -c 1 > /dev/null 2>&1 && upcount=$(( $upcount + 1 ))

	sleep 0.6

	ping ipvanish.com -c 1 > /dev/null 2>&1 && upcount=$(( $upcount + 1 ))

	sleep 0.4

	ping stackoverflow.com -c 1 > /dev/null 2>&1 && upcount=$(( $upcount + 1 ))

	if [ "$upcount" -ge "1" ]
	then
		return 0
	else
		return 1
	fi

}

testIP() {
	ip=$(curl -s ifconfig.me)
	echo "My ip is $ip"

	getIp="$(grep verify-x509-name $config | cut -d " " -f 2)"
	echo "vpn host is is $getIp"
	getIp="$(dig +short $getIp)"
	echo "vpn host ip is $getIp"
	getIp="${getIp%.*}"
	echo "ip should start with $getIp"

	checkisp="$(echo $ip | grep $getIp)"
	if [ ! -z "$checkisp" ]; then
	# it is from ipvanish 	
	echo "ip is from ipvanish"
	return 0
	else
	echo "ip IS INCORRECT"
	return 1
	fi	
}

test_change(){
	if [ "$(cat $vpn_change_trigger)" == "0" ]; then
		echo 1 > $vpn_change_trigger
		echo 1 > $vpn_ready_notify	
		return 1
	else
		return 0 
	fi
}

testUP(){
	#check to see if we need to reset vpn
	test_change
	if [ $? -ne 0 ]
	then
		echo "Change vpn request received"
		return 1
	fi
	testnetwork
	if [ $? -ne 0 ]
	then
		return 1
	else
		testIP
		if [ $? -ne 0 ]
		then
			return 1
		else
			return 0	
		fi	
	fi
}

loop(){
	while [ 1 ]
	do
		testUP
		if [ $? -ne 0 ]
			then
				echo 1 > $vpn_ready_notify	
				echo -e "killing and restarting vpn\n"
				killall openvpn
				sleep 1
				launchvpn
				sleep $wait_for_vpn_to_become_active
			else
				echo 0 > $vpn_ready_notify	
				echo "everything is ok @ $(date)"	
		fi
		echo "___________________________________"
		echo "using config $config"
		sleep $aggressive_checker
	done
}

checkstart(){
	if [ "$EUID" -ne 0 ]
		  then echo "Please run as root"
		  exit 2
	else
	echo 1 > $vpn_ready_notify	
	chmod 666 $vpn_ready_notify	
	#chown human:users $vpn_ready_notify	
	echo 1 > $vpn_change_trigger
	chmod 666 $vpn_change_trigger
	#chown human:users $vpn_change_trigger
	return 0	  
	fi
}

exit_cleanly(){
	unset PASSWORD
	echo "Exiting VPN.... OpenVPN will be killed"
	echo 1 > $vpn_ready_notify	
	echo 1 > $vpn_change_trigger
	killall openvpn
	echo "Goodbye"
	exit 0
}

main(){
	PASSWORD=$@
	killall openvpn
	launchvpn
	checkstart && loop
}

trap "exit_cleanly" 2

main $@ # can use $1 if your pass doesnt have spaces
	


