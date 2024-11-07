# frozen_string_literal: true

class MaestralDbx < Formula
  desc "🏋️ dbx-link (get link to file) and dbx-web (visit file on web)"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/maestral/dbx-link.fish" => "dbx-link"
    bin.install "scripts/maestral/dbx-web.fish" => "dbx-web"
  end
end
