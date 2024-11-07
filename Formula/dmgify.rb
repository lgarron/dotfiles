# frozen_string_literal: true

class Dmgify < Formula
  desc "📁 dmgify"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "storage/dmgify.fish" => "dmgify"
  end
end
