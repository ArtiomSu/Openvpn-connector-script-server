#!/usr/bin/expect -f
set pass [lindex $argv 0];
set config [lindex $argv 1];
spawn sudo openvpn --config $config --ping 5 --ping-restart 10 --verb 3 --persist-tun
match_max 100000
expect "*?sername:*"
send -- "anthonyjones1a5@gmail.com"
send -- "\r"
expect "*?assword:*"
send -- $pass
send -- "\r"
expect eof
