# Go

  set -x "GOPATH" "$HOME/Code/gopath"
  set -x PATH $PATH "$HOME/Code/gopath/bin"

  if [ (uname) = "Darwin" ]
    function go
      env DYLD_INSERT_LIBRARIES='' command go $argv
    end
  end
