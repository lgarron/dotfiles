# frozen_string_literal: true

class OpenscadLspTopiary < Formula
  desc "jj clone script."
  homepage "https://github.com/lgarron/dotfiles"
  url "https://github.com/Leathong/openscad-LSP/releases/download/v1.2.7/topiary-mac.zip"
  sha256 "4d1e9b0dc06516dc642a1e8d5b72e2080aec1a3ebee0bfd49b9674bb98f0a4a1"

  def install
    bin.install "topiary" => "openscad-lsp-topiary"
  end
end
