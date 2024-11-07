#!/usr/bin/env -S fish --no-config

echo -n "["
set_color --bold
hostname | tr -d "\n"
set_color normal

echo -n "] "
if /usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" (ioreg -n Root -d1 -a | psub) 2>&1 | grep "^true\$" > /dev/null
  set_color green
  echo "locked 🔒"
  set_color normal
else
  set_color red
  echo "unlocked 🚫"
  set_color normal
  exit 1
end
