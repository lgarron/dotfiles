 # Go

  set -xg "GOPATH" "$HOME/Code/gopath"

  append_to_path_if_exists "$GOPATH/bin"
  append_to_path_if_exists "/usr/local/go/bin"
