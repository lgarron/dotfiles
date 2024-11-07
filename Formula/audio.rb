# frozen_string_literal: true

class Audio < Formula
  desc "🔊 Audio scripts."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/audio/mp3ify.bash" => "mp3ify"
    bin.install "scripts/audio/wavify.bash" => "wavify"
    bin.install "scripts/audio/flacify.bash" => "flacify"
  end
end
