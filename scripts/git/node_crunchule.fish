#!/usr/bin/env -S fish --no-config

function show_help
  set SCRIPT_NAME (basename (status -f))
  echo "Usage: $SCRIPT_NAME [--help/-h] [--dry-run/-d] [--yes/y] [--extract/-x] [<path>]"
  exit 1
end

argparse --name=(basename (status -f)) "h/help" "d/dry-run" "y/yes" "x/extract" -- $argv; or show_help

if set -q _flag_help
  show_help
end

if set -q argv[1]
  cd $argv[1]
end

# Workaround 🤷‍♀️
if set -q _flag_yes
  set YES_FLAG $_flag_yes
end
set CRUNCH_WORD_CAPITALIZED "Crunch"
if set -q _flag_extract
  set EXTRACT $_flag_extract
  set CRUNCH_WORD_CAPITALIZED "Uncrunch"
end
if set -q _flag_dry_run
  set DRY_RUN $_flag_dry_run
end

set CONVERTED ""

function do_zip
  if set -q EXTRACT
    7z x node_modules.7z node_modules; and trash node_modules.7z
  else
    7z a node_modules.7z node_modules; and trash node_modules
  end
  set CONVERTED $CONVERTED (pwd)/
end

function inner_loop
  echo (pwd)/

  if not set -q DRY_RUN
    if set -q YES_FLAG
      echo $CRUNCH_WORD_CAPITALIZED"ing!"
      do_zip
    else
      read -l -P $CRUNCH_WORD_CAPITALIZED" node_modules? [y/N] " CONFIRMATION
      switch $CONFIRMATION
        case Y y
          echo $CRUNCH_WORD_CAPITALIZED"ing!"
          do_zip
        case "" N n
          echo "Skipping"
      end
    end
  end
end

# for packageJSON in (find . -type d -name node_modules -prune -o -name "package.json" -print)
for packageJSON in (mdfind -onlyin . -name package.json)
  if not string match -q "*/node_modules/*" $packageJSON
    set REPO_DIR (dirname $packageJSON)
    cd $REPO_DIR
    if set -q EXTRACT
      echo "----------------"
      if test -f node_modules.7z
        inner_loop
      end
    else
      if test -d node_modules
        echo "----------------"
        echo -n "Number of files: "
        find node_modules -type f | wc -l | tr -d " "
        echo -n "Number of bytes: "
        du -sh node_modules
        inner_loop
      end
    end
    cd -
  end
end

if set -q CONVERTED[2]
  echo "----------------"
  echo $CRUNCH_WORD_CAPITALIZED"ed repos were:"
  for dir in $CONVERTED
    echo $dir
  end
else
  echo "No repos "(string lower $CRUNCH_WORD_CAPITALIZED)"ed."
end
