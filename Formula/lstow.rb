# frozen_string_literal: true

class Lstow < Formula
  desc "📁 lgarron's `stow` clone."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    # TODO: install properly from `npm` instead?
    system "./repo-script/build-ts-scripts.ts", "system/lstow"
    bin.install "./.temp/bin/lstow" => "lstow"
    generate_completions_from_executable(bin/"lstow", "--completions")
  end
end
