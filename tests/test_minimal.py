import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class MinimalSetupTests(unittest.TestCase):
    def test_full_nvim_opt_in_replaces_only_the_editor_profile(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-minimal-") as temp:
            env = dict(os.environ, HOME=temp)
            for args in ([], ["--with-nvim"], ["--with-nvim"]):
                result = subprocess.run(
                    ["bash", str(ROOT / "bootstrap.sh"), "--minimal", "--skip-zsh-plugins", *args],
                    env=env, capture_output=True, text=True, timeout=30,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            home = Path(temp)
            self.assertEqual((home / ".config/nvim").resolve(), ROOT / "nvim")
            self.assertEqual((home / ".zshrc").resolve(), ROOT / "minimal/zshrc")
            self.assertEqual((home / ".tmux.conf").resolve(), ROOT / "minimal/tmux.conf")
            backups = list((home / ".dotfiles_backup").glob("minimal.*/.config/nvim"))
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].resolve(), ROOT / "minimal/nvim")
            self.assertFalse((home / ".claude").exists())

    def test_install_backs_up_files_and_foreign_links_and_is_repeatable(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-minimal-") as temp:
            home = Path(temp) / "home with spaces"
            home.mkdir()
            (home / ".zshrc").write_text("original shell\n")
            original = home / "original-git"
            original.write_text("original git\n")
            (home / ".gitconfig").symlink_to(original)
            nvim = home / ".config/nvim"
            nvim.mkdir(parents=True)
            (nvim / "init.lua").write_text("original editor\n")
            local = home / ".zshrc.local"
            local.write_text("local shell\n")
            # Any accidental installer invocation fails the test.
            bins = home / "bin"
            bins.mkdir()
            for command in ("git", "brew", "curl", "sudo"):
                stub = bins / command
                stub.write_text("#!/bin/sh\nexit 97\n")
                stub.chmod(0o755)
            env = dict(os.environ, HOME=str(home), PATH=f"{bins}:{os.environ['PATH']}")
            for _ in range(2):
                result = subprocess.run(
                    ["bash", str(ROOT / "bootstrap.sh"), "--minimal", "--skip-zsh-plugins"],
                    cwd=temp, env=env, capture_output=True, text=True, timeout=30,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            backups = list((home / ".dotfiles_backup").glob("minimal.*"))
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / ".zshrc").read_text(), "original shell\n")
            self.assertTrue((backups[0] / ".gitconfig").is_symlink())
            self.assertEqual(original.read_text(), "original git\n")
            self.assertEqual((backups[0] / ".config/nvim/init.lua").read_text(), "original editor\n")
            self.assertEqual((home / ".zshrc").resolve(), ROOT / "minimal/zshrc")
            self.assertEqual((home / ".gitconfig").resolve(), ROOT / "minimal/gitconfig")
            self.assertEqual(local.read_text(), "local shell\n")
            for skipped in (".claude", ".copilot", ".local/bin/xdg-open", ".config/karabiner"):
                self.assertFalse((home / skipped).exists())

    def test_copilot_conflict_fails_before_writing(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-minimal-") as temp:
            result = subprocess.run(
                ["bash", str(ROOT / "bootstrap.sh"), "--minimal", "--with-copilot"],
                env=dict(os.environ, HOME=temp), capture_output=True, text=True, timeout=30,
            )
            self.assertEqual(result.returncode, 2)
            self.assertEqual(list(Path(temp).iterdir()), [])


if __name__ == "__main__":
    unittest.main()
