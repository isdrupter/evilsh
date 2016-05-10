#!/bin/sh
#make a cmd json
bbj=`busybox jshon -s 2>/dev/null 1>/dev/null`

getEnv(){
ip=$bbj"`(/sbin/ifconfig lo 2>/dev/null | grep Mask | cut -d ':' -f2 | cut -d " " -f1)`"
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
cmdline=$bbj"$@"
output=`./busybox jshon -s "$($@)"`
getstty=$bbj"$(stty)"
term=$bbj"$(echo $TERM)"
cpuname=$bbj"$(cat /proc/cpuinfo | grep name)"
if ([ ! -s /tmp/.status ] && [ -f /tmp/.status ]); then busy="SYSTEM_BUSY" ; else busy="SYSTEM_READY";fi
uxt=`date +%s`
(echo $cmdline >/tmp/hash-cmd)
hashcmd=`md5sum /tmp/hash-cmd | sed -e 's/\  \/tmp\/hash-cmd\>//g'`
uuid=$bbj"'$uxt.$hashcmd'"


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
"status": "'$busy'",
"cmduuid": "'$uuid'",
"cmdline": "'$cmdline'",
"output": "'$output'"
}'
}

main(){
getEnv $@
rm /tmp/hash-cmd
}

main $@ 2>/dev/null
