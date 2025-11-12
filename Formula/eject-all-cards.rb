# frozen_string_literal: true

class EjectAllCards < Formula
  desc "⏏️ Eject all camera cards."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "make", "setup-npm-packages"
    system "./repo-script/build-ts-scripts.ts", "system/eject-all-cards"

    bin.install "./.temp/bin/eject-all-cards" => "eject-all-cards"
  end
end
