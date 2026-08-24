class Tasklight < Formula
  desc "Terminal task runner with desktop notifications"
  homepage "https://github.com/revazi/tasklight"
  url "https://github.com/revazi/tasklight/releases/download/v0.2.1/tasklight-v0.2.1-source.tar.gz"
  sha256 "d046fdb55a4e458671e3048480bb5a962e4102c8ccde5454fdec148e9637d053"
  license "MIT"
  head "https://github.com/revazi/tasklight.git", branch: "main"

  depends_on "go" => :build

  on_macos do
    depends_on xcode: ["13.0", :build]
  end

  def install
    ldflags = "-s -w -X github.com/revazi/tasklight/internal/cli.Version=#{version}"
    system "go", "build", "-trimpath", "-ldflags", ldflags, "-o", "tasklight", "./cmd/tasklight"

    unless OS.mac?
      bin.install "tasklight"
      return
    end

    target = Hardware::CPU.arm? ? "darwin-arm64" : "darwin-amd64"
    helper_dir = buildpath/"homebrew-helper"
    helper_version = version.to_s.match?(/\A\d+\.\d+\.\d+\z/) ? version.to_s : "0.0.0"
    ENV["TASKLIGHT_VERSION"] = helper_version
    ENV["TASKLIGHT_SKIP_REGISTER"] = "1"
    system "./scripts/build-macos-helper.sh", helper_dir, target
    libexec.install "tasklight", helper_dir/"Tasklight.app"
    (bin/"tasklight").write_env_script libexec/"tasklight", TASKLIGHT_MACOS_HELPER: libexec/"Tasklight.app"
  end

  test do
    assert_match "tasklight #{version}", shell_output("#{bin}/tasklight --version")
    assert_match "Usage:", shell_output("#{bin}/tasklight --help")
  end
end
