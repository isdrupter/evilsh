#!/bin/sh 


get(){ 
bin=$1 
hash=$2
host=$3
path=$4

wget -O $path/$bin http://$host/$bin 
cd $path
filehash=`md5sum $bin | sed -e "s/\<$bin\>//g"`
test_=`echo $filehash`

if [[ "${test_}" == "$hash" ]];then 
 return 0 
 else 
 echo "Failure, trying again..." 
 return 1
fi 
} 

genTime(){ 
 cat /dev/urandom|od -N2 -An -i|awk -v f=2 -v r=10 '{printf "%i\n", f + r * $1 / 65536}' 
} 

bin=$1 
hash=$2 
host=${3:-""}
path=${4:-"/var/bin"}


if [[ ! -f "$path/$bin" ]] ; then 
 for i in 1 2 3 4 5;do
  sleep `genTime` 
  rm $path/$bin 2>/dev/null
  get $bin $hash $host $path
if [[ "$?" == "0" ]];then
 echo "Successfully received binary"; break 
fi 
 done 
fi 
