# frozen_string_literal: true

class Gclone < Formula
  desc "Git clone script."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/git/gclone.ts" => "gclone"
  end
end
