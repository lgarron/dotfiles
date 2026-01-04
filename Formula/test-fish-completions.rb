# frozen_string_literal: true

class TestFishCompletions < Formula
  desc "🛠️ Test fish completions."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "debug/test-fish-completions"
    bin.install "./.temp/bin/test-fish-completions" => "test-fish-completions"
    generate_completions_from_executable(bin/"test-fish-completions", "--completions")
  end
end
