#!/bin/bash

SCRIPT="$(realpath $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

vpn_config="$(grep vpn_config $SCRIPTPATH/vpn_runner.sh | head -n 1 | cut -d '=' -f 2 | sed -r 's/\"//g')"
if [ -z $1 ]; then
	echo "uk-london-lon-a1" > $vpn_config
else
	echo "$1" > $vpn_config
fi
echo done
