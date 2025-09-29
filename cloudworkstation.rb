class Cloudworkstation < Formula
  desc "Academic research computing platform - Launch cloud research environments"
  homepage "https://github.com/scttfrdmn/cloudworkstation"
  license "MIT"
  head "https://github.com/scttfrdmn/cloudworkstation.git", branch: "main"

  version "0.4.6"

  # Use prebuilt binaries for faster installation
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.4.6/cloudworkstation-v0.4.6-darwin-arm64.tar.gz"
      sha256 "5d8a11d9031cbdbd65e937034c3d50151fe49976cd2b8a631c2e68b74b93f0e8"
    else
      url "https://github.com/scttfrdmn/cloudworkstation/releases/download/v0.4.6/cloudworkstation-v0.4.6-darwin-amd64.tar.gz"
      sha256 "8171765b3ce9dc0c4305dcf88b277d95db092cd3f8c1928449fab9753a22279d"
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
      
      🎨 Version 0.4.6 EFS Multi-Modal Integration:
        • Complete EFS volume management across CLI, TUI, and GUI interfaces
        • Multi-instance file sharing for collaborative research environments
        • Professional Cloudscape-based GUI with real-time mount status
        • Interactive TUI with tabbed navigation and keyboard-driven operations

        Example EFS usage:
          cws volumes list                    # List EFS volumes
          cws volumes mount shared-data my-instance  # Mount volume to instance
          cws tui                            # Access storage tab (Press 4)

      Note: Version 0.4.6 completes Phase 4 enterprise research platform features.
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