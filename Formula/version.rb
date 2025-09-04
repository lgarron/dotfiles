# frozen_string_literal: true

class Version < Formula
  desc "↗️ Get the current or previous project version."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "toml2json"

  def install
    bin.install "scripts/git/version.fish" => "version"
  end
end
