#!/bin/bash
################################
# Msub bash client

## Set variables here
stopic=jsh
host='localhost'
user='admin'
ident='admin'
password='lol'
topic="data/$stopic"
mpipe="/tmp/msub.p"
pidf="/tmp/msub.pid"

trap "echo 'Exiting...';rm -f $mpipe;kill `cat $pidf` &>/dev/null;exit" EXIT
mkfifo $mpipe 2>/dev/null
(subclient -h $host -u $user -i $ident -P $password -t $topic -q 0 > $mpipe) & echo "$!" > "$pidf"

while read line <$mpipe; do
  echo "$line" | base64 -d 
done
