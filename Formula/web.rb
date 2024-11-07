# frozen_string_literal: true

class Web < Formula
  desc "🌐 Web scripts"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "web/chrometab.bash" => "chrometab"
    bin.install "web/safaritab.bash" => "safaritab"
    bin.install "web/weblocify.bash" => "weblocify"
  end
end
