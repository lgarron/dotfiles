# frozen_string_literal: true

class Version < Formula
  desc "↗️ Get the current or previous project version."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "git/version.fish" => "version"
  end
end
