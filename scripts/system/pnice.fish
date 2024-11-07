#!/usr/bin/env -S fish --no-config

set NICENESS $argv[2]
if test (count $argv) -lt 2
  echo "Usage: pnice <process substring> <niceness>"
  echo ""
  echo "Set the niceness of processes by matching (a substring of) process names."
else
  echo "📶 Setting niceness $NICENESS for process names containing: $argv[1]";
  for pid in (pgrep -i $argv[1])
    echo -n "🖥  renice $NICENESS $pid"
    renice $NICENESS $pid 2> /dev/null
    if test $status -ne 0
          echo -n " (sudo)"
          sudo renice $NICENESS $pid
        end
    echo ""
  end
end
