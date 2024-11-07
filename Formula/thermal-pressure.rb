# frozen_string_literal: true

class ThermalPressure < Formula
  desc "🔥 Get thermal pressure on macOS without `sudo`ing every time.."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :macos

  def install
    bin.install "scripts/sudo/thermal-pressure.fish" => "thermal-pressure"
  end
end
