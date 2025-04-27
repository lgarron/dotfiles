# frozen_string_literal: true

class Lstow < Formula
  desc "📁 lgarron's `stow` clone."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/system/lstow.ts" => "lstow"
  end
end
