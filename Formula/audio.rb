# frozen_string_literal: true

class Audio < Formula
  desc "🔊 Audio scripts."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "audio/mp3ify.bash" => "mp3ify"
    bin.install "audio/wavify.bash" => "wavify"
    bin.install "audio/flacify.bash" => "flacify"
  end
end
