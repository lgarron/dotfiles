# frozen_string_literal: true

class NaughtyListAuto < Formula
  desc "🙅 Sweep dotfile pollution in your home dir."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    # TODO: install properly from `npm` instead?
  
    system "./repo-script/build-ts-scripts.ts", "system/naughty-list-auto"

    bin.install "./.temp/bin/naughty-list-auto" => "naughty-list-auto"
  end
end
