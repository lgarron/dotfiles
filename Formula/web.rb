# frozen_string_literal: true

class Web < Formula
  desc "🌐 Web scripts"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/web/chrometab.fish" => "chrometab"
    bin.install "scripts/web/safaritab.fish" => "safaritab"
    bin.install "scripts/web/weblocify.ts" => "weblocify"
  end
end
