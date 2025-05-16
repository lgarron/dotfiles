# frozen_string_literal: true

class OpenscadLspTopiary < Formula
  desc "jj clone script."
  homepage "https://github.com/lgarron/dotfiles"
  url "https://github.com/Leathong/openscad-LSP/releases/download/v1.3.0/openscad-lsp-mac.zip"
  sha256 "d058a5f93e2b7176289e0b3225028a6e26074f8c6179378e1da41a76bc5e8403"

  def install
    bin.install "topiary" => "openscad-lsp-topiary"
  end
end
