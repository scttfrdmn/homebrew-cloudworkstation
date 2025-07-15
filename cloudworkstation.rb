class Cloudworkstation < Formula
  desc "Launch cloud research environments in seconds"
  homepage "https://github.com/scttfrdmn/cloudworkstation"
  license "MIT"
  head "https://github.com/scttfrdmn/cloudworkstation.git", branch: "main"

  # This stanza checks the latest release from GitHub
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.4.1/cloudworkstation-darwin-arm64.tar.gz"
      sha256 "c8b90aafd1ce01e94c14343d37e5a4f83af3d6bde1df10f093ea541cd3fe2883"
    else
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.4.1/cloudworkstation-darwin-amd64.tar.gz"
      sha256 "861c2b9c9cd7c8a0eb23d382faf1af0886721a4ef8aeefc706a2ca0515e8cc05"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.4.1/cloudworkstation-linux-arm64.tar.gz"
      sha256 "53444f8a598b8aeeff90b21055f1cd54e0c2f695d138951ff518c7635582b015"
    else
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.4.1/cloudworkstation-linux-amd64.tar.gz"
      sha256 "388a0be69f43ba375e295f7ee73f591f79d864516ec4ba9f1b64f67993f4e17b"
    end
  end

  version "0.4.1"

  depends_on "go" => :build

  def install
    # Install binary from the archive
    bin.install "cws"
    bin.install "cwsd"

    # Install completion scripts
    bash_completion.install "completions/cws.bash" => "cws"
    zsh_completion.install "completions/cws.zsh" => "_cws"
    fish_completion.install "completions/cws.fish"

    # Install man pages if available
    man1.install "man/cws.1" if File.exist?("man/cws.1")
  end

  def post_install
    # Ensure configuration directory exists
    system "mkdir", "-p", "#{ENV["HOME"]}/.cloudworkstation"
  end

  def caveats
    <<~EOS
      CloudWorkstation #{version} has been installed!
      
      To start the CloudWorkstation daemon:
        cwsd start
        
      To launch your first cloud workstation:
        cws launch python-research my-project
        
      For full documentation:
        cws help
    EOS
  end

  test do
    # Check if binaries can run and report version
    assert_match "CloudWorkstation v#{version}", shell_output("#{bin}/cws --version")
    assert_match "CloudWorkstation Daemon v#{version}", shell_output("#{bin}/cwsd --version")
  end
end