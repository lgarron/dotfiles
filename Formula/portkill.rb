# frozen_string_literal: true

class Portkill < Formula
  desc "☠️ Kill processes by port number"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "system/portkill.bash" => "portkill"
  end
end
