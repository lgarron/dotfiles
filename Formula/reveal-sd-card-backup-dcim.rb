# frozen_string_literal: true

class RevealSdCardBackupDcim < Formula
  desc "↔️ Reveal SD Card Backup (DCIM)"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/storage/reveal-sd-card-backup-dcim.ts" => "reveal-sd-card-backup-dcim"
  end
end
