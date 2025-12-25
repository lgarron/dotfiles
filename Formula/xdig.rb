# frozen_string_literal: true

class Xdig < Formula
  desc "🔍 Wrapper for `dig` that allows using `~/.config/dig/xdigrc.json` (or under `$XDG_CONFIG_HOME:=~`) instead of `.digrc`, with reasonable fidelity."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/xdig"
    bin.install "./.temp/bin/xdig" => "xdig"
    # No completions
  end
end
