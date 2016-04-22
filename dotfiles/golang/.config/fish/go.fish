# Go

  set -x "GOPATH" "$HOME/Code/gopath"
  set -x PATH $PATH "$HOME/Code/gopath/bin"

  function go
    env DYLD_INSERT_LIBRARIES='' command go $argv
  end