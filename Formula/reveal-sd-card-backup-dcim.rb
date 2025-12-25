# frozen_string_literal: true

class RevealSdCardBackupDcim < Formula
  desc "↔️ Reveal SD Card Backup (DCIM)"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "lgarron/lgarron/reveal-macos"

  def install
    system "./repo-script/build-ts-scripts.ts", "storage/reveal-sd-card-backup-dcim"
    bin.install "./.temp/bin/reveal-sd-card-backup-dcim" => "reveal-sd-card-backup-dcim"
    generate_completions_from_executable(bin/"reveal-sd-card-backup-dcim", "--completions")
  end
end
