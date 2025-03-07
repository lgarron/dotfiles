# frozen_string_literal: true

class Gclone < Formula
  desc "jj clone script."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/git/jclone.ts" => "jclone"
  end
end
