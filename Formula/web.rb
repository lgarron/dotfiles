# frozen_string_literal: true

class Web < Formula
  desc "🌐 Web scripts"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "fish"

  def install
    system "./repo-script/build-ts-scripts.ts", "web/weblocify"
    bin.install "./.temp/bin/weblocify" => "weblocify"
    generate_completions_from_executable(bin/"weblocify", "--completions")

    bin.install "scripts/web/chrometab.fish" => "chrometab"
    bin.install "scripts/web/safaritab.fish" => "safaritab"
  end
end
