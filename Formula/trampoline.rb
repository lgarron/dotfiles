# frozen_string_literal: true

class Trampoline < Formula
  desc "🎪 Trampoline to load env vars."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "fish"

  def install
    bin.install "scripts/system/trampoline.fish" => "trampoline"
  end
end
