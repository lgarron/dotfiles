# frozen_string_literal: true

class SdCardBackup < Formula
  desc "💻 A simple tool to backup up SD cards."
  homepage "https://github.com/lgarron/sd-card-backup"
  head "https://github.com/lgarron/sd-card-backup.git", :branch => "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "./cmd/sd-card-backup"
  end
end
