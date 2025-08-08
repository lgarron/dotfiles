# frozen_string_literal: true

class Web < Formula
  desc "🌐 Web scripts"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "fish"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/weblocify", "scripts/web/weblocify.ts"
    bin.install "./.temp/bin/weblocify" => "weblocify"

    bin.install "scripts/web/chrometab.fish" => "chrometab"
    bin.install "scripts/web/safaritab.fish" => "safaritab"
  end
end
