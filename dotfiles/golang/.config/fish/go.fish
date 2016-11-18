# Go

  set -x "GOPATH" "$HOME/Code/gopath"
  set -x PATH $PATH \
    "$HOME/Code/gopath/bin"

  if not contains (hostname -s) $LGARRON1
    if not contains (hostname -s) $HYPATIA
      set -x PATH $PATH \
        "/usr/local/go/bin"
    end
  end

  if [ (uname) = "Darwin" ]
    function go
      env DYLD_INSERT_LIBRARIES='' command go $argv
    end
  end
