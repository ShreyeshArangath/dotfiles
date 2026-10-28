#!/usr/bin/env python3
"""Install local configs only, preserving replaced files and symlinks."""
from pathlib import Path
import argparse
import os
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parent
LINKS = {
    ".zshrc": "minimal/zshrc",
    ".p10k.zsh": "minimal/p10k.zsh",
    ".gitconfig": "minimal/gitconfig",
    ".config/git/ignore": "git/ignore",
    ".tmux.conf": "minimal/tmux.conf",
    ".config/nvim": "minimal/nvim",
    ".config/ghostty/config": "ghostty/config",
}
if sys.platform == "darwin":
    LINKS["Library/Application Support/com.mitchellh.ghostty/config"] = "ghostty/config"

# Two tiny upstream plugins only — no Oh My Zsh / frameworks.
LIGHT_ZSH_PLUGINS = (
    ("zsh-autosuggestions", "https://github.com/zsh-users/zsh-autosuggestions.git"),
    ("zsh-syntax-highlighting", "https://github.com/zsh-users/zsh-syntax-highlighting.git"),
)


def ensure_light_zsh_plugins(home: Path) -> None:
    """Shallow-clone light history/syntax plugins into ~/.zsh when missing."""
    plugin_root = home / ".zsh"
    plugin_root.mkdir(parents=True, exist_ok=True)
    for name, url in LIGHT_ZSH_PLUGINS:
        dest = plugin_root / name
        if (dest / ".git").is_dir() or (dest / "{}.zsh".format(name)).is_file():
            print("Light zsh plugin present: {}".format(name), flush=True)
            continue
        print("Installing light zsh plugin: {}".format(name), flush=True)
        try:
            subprocess.run(
                ["git", "clone", "--depth=1", url, str(dest)],
                check=True,
            )
        except (OSError, subprocess.CalledProcessError) as exc:
            print(
                "Warning: could not install {}: {} "
                "(shell still works; retry later or clone manually into {})".format(
                    name, exc, dest
                ),
                flush=True,
            )
            if dest.exists() and not any(dest.iterdir()):
                dest.rmdir()


def install_links(home, links, root=None, backup_prefix="minimal."):
    """Back up anything in the way, then symlink. Pass root un-resolved so a
    Homebrew opt path survives cellar upgrades."""
    if root is None:
        root = ROOT
    for source in links.values():
        if not (root / source).exists():
            raise FileNotFoundError(root / source)
    backup = None
    for destination, source in links.items():
        target, original = home / destination, root / source
        if target.is_symlink() and target.resolve() == original.resolve():
            continue
        if os.path.lexists(target):
            if backup is None:
                backup_root = home / ".dotfiles_backup"
                backup_root.mkdir(parents=True, exist_ok=True)
                backup = Path(tempfile.mkdtemp(prefix=backup_prefix, dir=backup_root))
                print("Existing configs backed up to: {}".format(backup), flush=True)
            saved = backup / destination
            saved.parent.mkdir(parents=True, exist_ok=True)
            target.rename(saved)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.symlink_to(original, target_is_directory=original.is_dir())
        print("Linked {}".format(target))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--with-nvim", action="store_true", help="Link the full Neovim config")
    parser.add_argument("--with-herdr", action="store_true", help="Link Herdr settings and sound")
    parser.add_argument(
        "--skip-zsh-plugins",
        action="store_true",
        help="Do not clone the light autosuggestions/syntax-highlighting plugins",
    )
    args = parser.parse_args()
    links = dict(LINKS)
    if args.with_nvim:
        links[".config/nvim"] = "nvim"
    if args.with_herdr:
        links[".config/herdr/config.toml"] = "herdr/config.toml"
        links[".config/herdr/sounds/silent.mp3"] = "herdr/sounds/silent.mp3"
    home = Path.home()
    install_links(home, links)
    if args.skip_zsh_plugins:
        print("Skipped light zsh plugins (--skip-zsh-plugins).", flush=True)
    else:
        ensure_light_zsh_plugins(home)
    print(
        "Lean dotfiles installed (history search + optional light autosuggest/syntax). "
        "Restart your shell.",
        flush=True,
    )
    if args.with_nvim:
        print("Full Neovim config linked. Neovim installs its configured plugins on launch.")
    if args.with_herdr:
        print("Herdr config linked. Reload its config or restart Herdr to apply it.")


if __name__ == "__main__":
    main()
