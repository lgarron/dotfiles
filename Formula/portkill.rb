# frozen_string_literal: true

class Portkill < Formula
  desc "☠️ Kill processes by port number"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/system/portkill.bash" => "portkill"
  end
end
