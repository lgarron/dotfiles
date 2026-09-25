# frozen_string_literal: true

class EjectKnownCards < Formula
  desc "⏏️ Eject known camera cards."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/eject-known-cards"
    bin.install "./.temp/bin/eject-known-cards" => "eject-known-cards"
    generate_completions_from_executable(bin/"eject-known-cards", "--completions")
  end
end
