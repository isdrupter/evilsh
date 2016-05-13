#!/bin/sh
#make a cmd json
tempf=/tmp/jshcmd
echo $@ > $tempf

bbj="$(jshon -s 2>/dev/null 1>/dev/null)"
ip=$bbj"$(/sbin/ifconfig lo | grep Mask | cut -d ':' -f2 | cut -d " " -f1)"
unixtime=$bbj"$(date +%s)"
date=$bbj"$(date)"
uptime=$bbj"$(uptime | sed s/\,//)"
kernelcmdline=$bbj"$(cat /proc/cmdline)"
id=$bbj"$(id)"
kcrypto=$bbj"$(cat /proc/crypto | grep name | cut -d':' -f2 | uniq | tr -s '\n' ' '|sed s/\,//)"
version=$bbj"$(cat /proc/version)"
memstat=$bbj"$(cat /proc/meminfo | head -n 3 | tr -s '\n' ' ')"
cwd=$bbj"$(pwd)"
shell=$bbj"$(echo $SHELL)"
getstty=$bbj"$(stty)"
term=$bbj"$(echo $TERM)"
cpuname=$bbj"$(cat /proc/cpuinfo | grep name)"
cmdline=$bbj"$(echo $(cat $tempf))"
#output=$bbj"$($cmdline)"
output=$bbj"$(ash $tempf)"
status=$bbj"$(if ([ -s /tmp/.status ] && [ -f /tmp/.status ]); then echo "SYSTEM_BUSY" ; else echo "SYSTEM_READY";fi)"
hashcmd=$bbj"$(md5sum $tempf | sed -e 's/\  \/tmp\/jshcmd\>//g')"
uuid=$bbj"'$unixtime.$hashcmd'"


echo '{
"ip" : "'$ip'",
"unixtime": "'$unixtime'",
"date": "'$date'",
"uptime" : "'$uptime'",
"cpuname": "'$cpuname'",
"memstat" : "'$memstat'",
"id" : "'$id'",
"version" : "'$version'",
"kernel_cmdline": "'$kernelcmdline'",
"kernel_crypto": "'$kcrypto'",
"shell": "'$shell'",
"term": "'$term'",
"stty": "'$getstty'",
"cwd": "'$cwd'",
"uuid": "'$uuid'",
"cmdline": "'$cmdline'",
"output": "'$output'"
}' 
>$tempf
