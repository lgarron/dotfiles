#!/usr/bin/env fish

set shortcut (echo $argv[3]| tr "[:upper:]" "[:lower:]" | sed "s/⌘/@/g" | sed "s/⇧/\$/g" | sed "s/⌥/~/g")

# From https://github.com/lgarron/dotfiles/blob/d61bf45f8901c985f55522330412c13d54afccf2/dotfiles/fish/.config/fish/config.fish#L126-L140
function echo-alternate-background
  set set_color_arg "normal"
  for arg in $argv[1..-1]
    set_color "$set_color_arg"
    echo -n $arg

    if [ "$set_color_arg" = "normal" ]
      set set_color_arg "-r"
    else
      set set_color_arg "normal"
    end
  end
  set_color "normal"
  echo ""
end

echo-alternate-background \
    "Setting shortcut for " "$argv[1]" \
    " > " "$argv[2]" \
    " to " "$argv[3]" " (decoded to: " "$shortcut" ")"

function uh_oh_permissions
  echo "Try `mac-add-shortcut` in a terminal app?"
  exit 1
end

if defaults read com.apple.universalaccess "com.apple.custommenu.apps" | grep "\"$argv[1]\"" > /dev/null
else
  if defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "$argv[1]"
  else
    uh_oh_permissions
  end
end
if defaults write "$argv[1]" NSUserKeyEquivalents -dict-add "$argv[2]" -string "$shortcut"
else
  uh_oh_permissions
end
