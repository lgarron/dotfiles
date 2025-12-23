# frozen_string_literal: true

class ToggleRetina < Formula
  desc "🖥️ Toggle Retina display scaling."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "betterdisplaycli"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/toggle-retina"

    bin.install "./.temp/bin/toggle-retina" => "toggle-retina"

    generate_completions_from_executable(bin/"toggle-retina", "--completions", shells: [:fish])
  end
end
