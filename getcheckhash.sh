#!/bin/bash 
###############################################################################################
# GetCheckHash
###############################################################################################
# Shell script to download and verify a file across multiple hosts. Downloads file via tftp or
# wget, than compares it against a passed sha1sum. If the hashes do not match, than the script 
# will sleep for a random time (as not to overwhelm the download server if many hosts are 
# trying to download something at the same time) and than try again, up to 5 times, stopping
# when the file passes the hash.
################################################################################################

get(){ 
bin=$1 ;hash=$2;host=$3;path=$4
cd $path
wget -O $path/$bin http://$host/$bin 
if echo "$hash *$bin" | sha1sum -c - >/dev/null ; then 
 echo "Checksum passed." >&2
 return 0 
 else 
 echo "Checksum failed, trying again..." >&2
 return 1
fi 
} 

genTime(){ 
awk -v min=5 -v max=60 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'
} 


# cli variables & defaults
bin=$1 
hash=$2 
host=${3:-"http://super.evil.ness"}
path=${4:-"/var/bin"}

# First, do we already have the file?
if echo "$hash *$path/$bin" | sha1sum -c - >/dev/null ; then 
  exit 1
else
 for i in 1 2 3 4 5;do
  sleep `genTime` 
  rm $path/$bin 2>/dev/null
  get $bin $hash $host $path
if [[ "$?" == "0" ]];then
  echo "Successfully received binary" >&2
  break
fi 
 done 
fi
