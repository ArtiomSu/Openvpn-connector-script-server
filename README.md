# Openvpn connector script server
This is a more improved version of my older vpn script here [Openvpn connector script](https://github.com/ArtiomSu/Openvpn-connector-script)

I made this mostly for my nas server so its a little bit different in the sense that other programs can interact with this script to change vpn randomly or to a specific country or even to a specific server.


This script is a handy way of making sure your vpn tunnel is always up, it will try to reconnect once it detects it as down ( ip detection also improved over the last script ). By default I have it setup to work with ipvanish hence you will see `download_configs.sh` which downloads configs for IPVanish but it will work for everything else.

### Dependancies
```
expect
openvpn
curl
ping
dig 	(comes in dnsutils package)
```

### Installation
1. `git clone https://github.com/ArtiomSu/Openvpn-connector-script-server.git`


2. `cd Openvpn-connector-script-server`


3. To run the script you will need to change to your own email in `vpn-helper.sh` currently it is set to my own so change it to whatever you use.


4. Download the configs by running `download_configs.sh` this will create a configs directory download the IPVanish configs and then update a few options to prevent dns leak check [DNS leak test to check for yourself](https://www.dnsleaktest.com/)


5. Then you will need to supply your vpn password to `vpn_runner.sh` like so `./vpn_runner.sh password123PASS`


By default it will randomly select vpn servers I will go through this in next section.

### Interacting with other scripts
You will notice at the top of `vpn_runner.sh` there are 4 files this script reads and writes to:
```
vpn_change_trigger="/tmp/vpn_change.vpnsh"
vpn_ready_notify="/tmp/vpn_ready.vpnsh"
vpn_config="/tmp/vpn_config.vpnsh"
vpn_freeze_trigger="/tmp/vpn_freeze.vpnsh"
```

I set these as temporary files but you can put these inside your home directory if you want


##### `vpn_ready_notify` 
Tells you if the vpn is up. 0=up, 1=down. This file should not be modified by your scripts as it will confuse other scripts using it. The file is updated everytime the script checks if the network is up and if the ip is correct.

##### `vpn_freeze_trigger`
Allows you to pause the vpn and use your real IP. Simply `echo 0 > /tmp/vpn_freeze.vpnsh` to pause the vpn and `echo 1` to start it up again.


##### `vpn_config` 
Lets the script know which vpn servers you want to use this uses regex if you want to get advanced as seen here in the script `ls $SCRIPTPATH/configs | grep -i ".*${pattern}.*[.ovpn]$" |sort -R |tail -n 1`. 


By default this file is blank this will use a random config in your configs folder. If this file is deleted it will also use a random config.


If you want to only connect to UK servers you can `echo "uk" > /tmp/vpn_config.vpnsh` or you can use my script `set_default_config.sh` to change it like so `./set_default_config.sh uk`. If you simply run `./set_default_config.sh` then it will use my specific default servers in UK London which is the same as running `echo "uk-london-lon-a1" > /tmp/vpn_config.vpnsh`.


If you want to connect to only one server you can simply do `./set_default_config.sh uk-london-lon-a14` this will only connect to once server since that will be the only match for the regex pattern.


Changing server occurs on the reconnection of the vpn so by writing to this file you wont change ip straight away. To change straight away read the next part.

##### `vpn_change_trigger`
This allows the users to reset the vpn. Simply `echo 0 > /tmp/vpn_change.vpnsh` to trigger a reset. If you look at this value by `watch -n1 cat /tmp/vpn_change.vpnsh` you will see that the script will change it back to 1 and proceed to change connection.


This can be used in conjunction with the last value if you wanted to hop between US and UK servers like in this example script bellow.
```
#!/usr/bin/env bash
#setup variables for files
vpn_change_trigger="/tmp/vpn_change.vpnsh"
vpn_ready_notify="/tmp/vpn_ready.vpnsh"
vpn_config="/tmp/vpn_config.vpnsh"

wait_for_vpn(){		# function taken from one of my real scripts I use
    while [ "$(cat $vpn_ready_notify)" -ne 0  ]; do
        echo -ne "Waiting for Vpn to come online\r"
        sleep 0.5
        echo -ne "Waiting for vPn to come online\r"
        sleep 0.5
        echo -ne "Waiting for vpN to come online\r"
        sleep 0.5
        echo -ne "                              \r"
    done
}

#change to somewhere in New York
echo "US-New-York" > $vpn_config
echo "0" > $vpn_change_trigger
wait_for_vpn	# this will sleep until the vpn becomes active

#now you can access American private stuff or something
curl https://www.nytimes.com 	

# ok lets get something from england
echo "UK" > $vpn_config
echo "0" > $vpn_change_trigger
wait_for_vpn
curl https://www.bbc.com/news/england/london
```
Now obviously that example script is useless since you can go on those websites regardless, but you get the idea.

If you want you can take a look at how all the values behave by watching all of them `watch -n 1 "echo change;cat /tmp/vpn_change.vpnsh;echo ready;cat /tmp/vpn_ready.vpnsh;echo config; cat /tmp/vpn_config.vpnsh"`

Personnaly I use it mostly to check if the vpn is up since randomly changing ip addresses suits my needs, however I decided to include the feature of changing to a specific country/city/server so that it is a more of a full experience and didnt take too long to do so anyway.


