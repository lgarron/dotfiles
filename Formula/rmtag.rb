# frozen_string_literal: true

class Rmtag < Formula
  desc "🚮 Push and update `git` tags automatically."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  depends_on "fish"
  
  def install
    bin.install "git/rmtag.fish" => "rmtag"

    generate_completions_from_executable(bin/"rmtag", "--completions", shells: [:fish])
  end
end
