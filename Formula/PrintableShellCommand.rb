# frozen_string_literal: true

class Printableshellcommand < Formula
  desc "🖨️ Create a `PrintableShellCommand` (for `npm:printable-shell-command`) from a commandline invocation."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "commandline/PrintableShellCommand"
    bin.install "./.temp/bin/PrintableShellCommand" => "PrintableShellCommand"
  end
end
