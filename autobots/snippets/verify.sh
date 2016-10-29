
# posix compliant - not all embedded echo binaries have the -e option, 
# and not all embedded systems have printf, but I think all unix systems
# have /etc/passwd and cat present, so this should be a relatively 
# foolproof method to determine if a system is real or not.
if ([ `/bin/echo -e "\\x6c\\x6f\\x6c"` == "lol" ] || [ `printf "\\x6c\\x6f\\x6c"` == "lol" ] || /bin/echo `cat /etc/passwd` >/dev/null 2>&1 );then echo g0t0ne ;fi
