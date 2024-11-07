# frozen_string_literal: true

class Xdig < Formula
  desc "🔍 Wrapper for `dig` that allows using `~/.config/dig/rc` (XDG dir convention compatible) instead of `.digrc`, with reasonable fidelity."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/system/xdig.bash" => "xdig"
  end
end
