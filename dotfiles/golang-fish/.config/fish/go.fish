 # Go

  set -xU "GOPATH" "$HOME/Code/gopath"

  add_to_path_if_exists "$GOPATH/bin"
  add_to_path_if_exists "/usr/local/go/bin"

  if [ (uname) = "Darwin" ]
    function go
      env DYLD_INSERT_LIBRARIES='' command go $argv
    end
  end
