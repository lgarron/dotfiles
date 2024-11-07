# frozen_string_literal: true

class Xdig < Formula
  desc "🔍 Wrapper for `dig` that allows using `~/.config/dig/rc` (XDG dir convention compatible) instead of `.digrc`, with reasonable fidelity."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "system/xdig.bash" => "xdig"
  end
end
