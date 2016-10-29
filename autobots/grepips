#!/bin/bash


case $1 in
-f|--file)
input=$2
grep -oP "([0-9]{1,3}\.){3}[0-9]{1,3}" $input

;;

-S|--subnets)
input=$2
mask=${3:-"24"}
grep -oP "([0-9]{1,3}\.){3}[0-9]{1,3}" $input |cut -d "." -f -3 | sed "s/$/.0\/$mask/"
;;
-s|--sort)
input=$2
grep -oP "([0-9]{1,3}\.){3}[0-9]{1,3}" $input | sort -u
;;
-c|--count)
input=$2
grep -oP "([0-9]{1,3}\.){3}[0-9]{1,3}" $input | sort -u |wc -l
;;
-h|--help)
echo "Grepips Version 3.0 - Grep ips from files"
echo "USAGE: ----------------------------------"
echo " file/stdin grepips -f <file>"
echo " subnets    grepips -S <file>"
echo " sort ips   grepips -s <file>"
echo " count      grepips -c <file>"
echo
;;
*)
input=$2
grep -oP "([0-9]{1,3}\.){3}[0-9]{1,3}" $input
;;
esac

exit
