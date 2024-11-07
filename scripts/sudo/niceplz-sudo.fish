#!/usr/bin/env -S fish --no-config

if fish_is_root_user
  niceplz
  exit 0
end

# TODO: This is an arbitrary choice of install location outside `$PATH`. There's probably a more canonical choice.
set HELPER_FOLDER "/Library/Application Support/niceplz"
set HELPER_FILENAME "niceplz-sudo-helper"
set HELPER_PATH "$HELPER_FOLDER/$HELPER_FILENAME"

set HELPER_PATH_WITH_ESCAPED_SPACES (echo $HELPER_PATH | sed "s# #\\\\ #g")

function install_helper
  echo "Installing helper…" 1>&2
  echo "This will require one-off `sudo` access." 1>&2
  sudo mkdir -p $HELPER_FOLDER
  sudo cp (status --current-filename) $HELPER_PATH
  chown root $HELPER_PATH
  sudo chmod u+s $HELPER_PATH
  function grant_sudo
    # TODO: `> /dev/null` doesn't seem to work. Is there a good (safe) way to append to a file using a `sudo` command, without printing the line to stdout?
    echo "" | sudo tee -a /etc/sudoers > /dev/null
    echo "$USER    ALL= NOPASSWD: $HELPER_PATH_WITH_ESCAPED_SPACES" | sudo tee -a /etc/sudoers > /dev/null
  end
  # TODO: Is this vulnerable to user name injection?
  sudo cat /etc/sudoers | grep $HELPER_FILENAME | grep "^$USER" ; or grant_sudo
end

function run_helper
  sudo $HELPER_PATH
end

function has_sudo
  sudo -l | grep $HELPER_FILENAME > /dev/null
end

if test -e $HELPER_PATH
  set HELPER_HASH (openssl dgst -sha256 $HELPER_PATH | awk '{print $NF}')
  set OWN_HASH (openssl dgst -sha256 (status --current-filename) | awk '{print $NF}')
  if [ $HELPER_HASH != $OWN_HASH ]
    echo "Helper is out of date and needs to be installed." 1>&2
    install_helper
  end
  if ! has_sudo
    echo "Sudo permission is missing and needs to be installed." 1>&2
    install_helper
  end
  run_helper
else
  install_helper
  run_helper
end



