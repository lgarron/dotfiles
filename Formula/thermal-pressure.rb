# frozen_string_literal: true

class ThermalPressure < Formula
  desc "🔥 Get thermal pressure on macOS without `sudo`ing every time.."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :macos
  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "sudo/thermal-pressure"
    bin.install "./.temp/bin/thermal-pressure" => "thermal-pressure"
    generate_completions_from_executable(bin/"thermal-pressure", "--completions")
  end

  def post_install
    ohai "To install a `sudo` helper, run:

    thermal-pressure
"
  end
end
