# frozen_string_literal: true

class Rmtag < Formula
  desc "🚮 Push and update `git` tags automatically."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "fish"
  
  def install
    bin.install "scripts/git/rmtag.fish" => "rmtag"

    generate_completions_from_executable(bin/"rmtag", "--completions", shells: [:fish])
  end
end
