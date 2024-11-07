# frozen_string_literal: true

class Rmbranch < Formula
  desc "🚮 Push and update `git` branches automatically."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "fish"
  
  def install
    bin.install "scripts/git/rmbranch.fish" => "rmbranch"

    generate_completions_from_executable(bin/"rmbranch", "--completions", shells: [:fish])
  end
end
