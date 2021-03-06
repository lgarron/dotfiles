 # Go

  set -xU "GOPATH" "$HOME/Code/gopath"

  set -x PATH $PATH \
    "$GOPATH/bin"

  if test -d "/usr/local/go/bin"
    set -x PATH $PATH \
      "/usr/local/go/bin"
  end

  if [ (uname) = "Darwin" ]
    function go
      env DYLD_INSERT_LIBRARIES='' command go $argv
    end
  end
