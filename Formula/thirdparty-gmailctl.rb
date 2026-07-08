# frozen_string_literal: true

class ThirdpartyGmailctl < Formula
  desc "💻 A simple tool to backup up SD cards."
  homepage "https://github.com/mbrt/gmailctl"
  # `b48a982bdaa137b646075ccc424a6684f03410c0` is the commit with the config path fix.
  # (It's also the latest commit in the codebase as of the creation of this formula.)
  url "https://github.com/mbrt/gmailctl/archive/b48a982bdaa137b646075ccc424a6684f03410c0.tar.gz"
  sha256 "8866c9c057231715520346023af9ece52e69d956ce2cbe8e92a4424ddadf76b6"
  head "https://github.com/mbrt/gmailctl.git", :commit => "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w", output: bin/"gmailctl"), "./cmd/gmailctl"
  end
end
