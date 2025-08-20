# frozen_string_literal: true

class Pushover < Formula
  desc "📯 Sends a notification to Pushover."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "api/pushover"

    bin.install "./.temp/bin/pushover" => "pushover"
  end
end
