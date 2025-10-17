class Cloudworkstation < Formula
  desc "Academic research computing platform - Launch cloud research environments"
  homepage "https://github.com/scttfrdmn/cloudworkstation"
  license "MIT"
  head "https://github.com/scttfrdmn/cloudworkstation.git", branch: "main"

  version "0.5.2"

  # Use prebuilt binaries for faster installation
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.5.2/cloudworkstation-v0.5.2-darwin-arm64.tar.gz"
      sha256 "49c8f35172b769506c035dcd5feb33afd29c9f311a65917e3b8dc57866f0947a"
    else
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.5.2/cloudworkstation-v0.5.2-darwin-amd64.tar.gz"
      sha256 "17fc771d39599e2a5c75a3490c4a5571b0f9554499de71a6f2953da996fb02da"
    end
  end

  def install
    # Install prebuilt binaries directly
    bin.install "cws"
    bin.install "cwsd"
    
    # Note: Templates are bundled in the binaries for v0.4.6
  end

  def post_install
    # Ensure configuration directory exists
    system "mkdir", "-p", "#{ENV["HOME"]}/.cloudworkstation"
  end

  def caveats
    s = <<~EOS
      CloudWorkstation #{version} has been installed with full functionality!
      
      📦 Installed Components:
        • CLI (cws) - Command-line interface with all latest features
        • TUI (cws tui) - Terminal user interface
        • Daemon (cwsd) - Background service
    EOS
    
    if OS.mac?
      s += <<~EOS
        • GUI (cws-gui) - Desktop application with system tray
      EOS
    end
    
    s += <<~EOS
      
      🚀 Quick Start:
        cws profiles add personal research --aws-profile aws --region us-west-2
        cws profiles switch personal
        cws launch "Python Machine Learning (Simplified)" my-project
        
      📚 Documentation:
        cws help                    # Full command reference (Cobra CLI)
        cws templates               # List available templates
        cws daemon status           # Check daemon status
        
      🔧 Service Management (Auto-Start on Boot):
        brew services start cloudworkstation   # Auto-start daemon with Homebrew
        brew services stop cloudworkstation    # Stop daemon service
        brew services restart cloudworkstation # Restart daemon service
      
      🎨 Version 0.5.2 SSH Tunnel & RStudio Authentication:
        • SSH tunnel KeyName-based discovery (fixes Permission denied errors)
        • RStudio Server automatic authentication (default: rstats/rstudio)
        • AWS Systems Manager (SSM) agent on all Ubuntu instances
        • GUI Terminal component with xterm.js integration
        • Enhanced web service access with embedded browser

        Example web service access:
          cws web list my-instance           # List available web services
          cws web open my-instance rstudio-server  # Open RStudio in browser
          cws templates info r-research      # See RStudio template details

      Note: Version 0.5.2 improves web-based research tool accessibility.
    EOS
  end

  # Homebrew automatically handles service management during install/uninstall

  test do
    # Test that binaries exist and are executable
    assert_predicate bin/"cws", :exist?
    assert_predicate bin/"cwsd", :exist?
    
    # Test version command
    assert_match "CloudWorkstation CLI v", shell_output("#{bin}/cws --version")
    assert_match "CloudWorkstation Daemon v", shell_output("#{bin}/cwsd --version")
  end

  service do
    run [opt_bin/"cwsd"]
    keep_alive true
    log_path var/"log/cloudworkstation/cwsd.log"
    error_log_path var/"log/cloudworkstation/cwsd.log"
    working_dir HOMEBREW_PREFIX
  end
end