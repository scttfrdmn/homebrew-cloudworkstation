class Cloudworkstation < Formula
  desc "Enterprise research management platform - Launch cloud research environments in seconds"
  homepage "https://github.com/scttfrdmn/cloudworkstation"
  license "MIT"
  head "https://github.com/scttfrdmn/cloudworkstation.git", branch: "main"
  
  # Development/Beta release - includes latest enterprise features
  revision 1

  # Use HEAD version for latest features (development builds)
  url "https://github.com/scttfrdmn/cloudworkstation.git", 
      using: :git, revision: "main"
  version "0.4.2-dev"

  depends_on "go" => :build

  def install
    # Ensure dependencies are up to date
    system "go", "mod", "tidy"
    
    # Build all binaries from source for latest features
    system "make", "build"
    
    # Install binaries
    bin.install "bin/cws"
    bin.install "bin/cwsd"
    
    # Install GUI on macOS (supports native build)
    if OS.mac?
      bin.install "bin/cws-gui"
    end
    
    # Install documentation
    doc.install "README.md"
    doc.install "CLAUDE.md" if File.exist?("CLAUDE.md")
    doc.install "CHANGELOG.md" if File.exist?("CHANGELOG.md")
    
    # Install templates
    share.install "templates" if Dir.exist?("templates")

    # Install completion scripts
    bash_completion.install "completions/cws.bash" => "cws" if File.exist?("completions/cws.bash")
    zsh_completion.install "completions/cws.zsh" => "_cws" if File.exist?("completions/cws.zsh")
    fish_completion.install "completions/cws.fish" if File.exist?("completions/cws.fish")

    # Install man pages if available
    man1.install "man/cws.1" if File.exist?("man/cws.1")
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
        
      🔧 Service Management:
        brew services start cloudworkstation   # Auto-start daemon
        brew services stop cloudworkstation    # Stop daemon service
      
      Note: This version includes all latest enterprise features and uses modern CLI.
    EOS
  end

  test do
    # Test that binaries exist and are executable
    assert_predicate bin/"cws", :exist?
    assert_predicate bin/"cwsd", :exist?
    
    # Test version command
    assert_match "CloudWorkstation v", shell_output("#{bin}/cws --version")
    assert_match "CloudWorkstation Daemon v", shell_output("#{bin}/cwsd --version")
    
    # Test templates command (should work without AWS credentials)
    system "#{bin}/cws", "templates"
  end

  service do
    run [opt_bin/"cwsd"]
    keep_alive true
    log_path var/"log/cloudworkstation/cwsd.log"
    error_log_path var/"log/cloudworkstation/cwsd.log"
    working_dir HOMEBREW_PREFIX
  end
end