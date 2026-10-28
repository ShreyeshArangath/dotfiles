class Shreydot < Formula
  desc "Install Shrey's dotfiles by profile"
  homepage "https://github.com/ShreyeshArangath/dotfiles"
  head "https://github.com/ShreyeshArangath/dotfiles.git", branch: "main"

  depends_on "python@3"

  def install
    system "git", "submodule", "update", "--init", "--recursive"
    libexec.install Dir["*"]

    # Bake the opt path. Symlinks must not point at Cellar, or the next
    # brew upgrade deletes the files they name.
    (bin/"shreydot").write <<~SH
      #!/bin/bash
      export SHREYDOT_ROOT="#{opt_prefix}/libexec"
      exec "#{HOMEBREW_PREFIX}/opt/python@3/bin/python3" "#{opt_prefix}/libexec/bin/shreydot" "$@"
    SH
    chmod 0755, bin/"shreydot"
  end

  def caveats
    <<~EOS
      The repo is not named homebrew-dotfiles, so tap it with the git URL:

        brew tap ShreyeshArangath/dotfiles https://github.com/ShreyeshArangath/dotfiles
        brew install --HEAD shreydot
        shreydot install -h

      There is no release tarball yet, so this formula is --HEAD only.
      brew upgrade --fetch shreydot moves the opt keg; existing symlinks follow.
    EOS
  end

  test do
    assert_match "noob", shell_output("#{bin}/shreydot install -h")
  end
end
