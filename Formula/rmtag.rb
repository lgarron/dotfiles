# frozen_string_literal: true

class Rmtag < Formula
  desc "🚮 Remove `git` tags thoroughly (local, remote, GitHub releases)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "git/rmtag"

    bin.install "./.temp/bin/rmtag" => "rmtag"
  
    generate_completions_from_executable(bin/"rmtag", "--completions", shells: [:fish])
  end
end
