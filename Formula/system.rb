# frozen_string_literal: true

class System < Formula
  desc "💻 System/shell tools"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/system/map.bash" => "map"
    bin.install "scripts/system/unixtime.bash" => "unixtime"
  end
end
