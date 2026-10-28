import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SHREYDOT = ROOT / "bin" / "shreydot"


class ShreydotTests(unittest.TestCase):
    def run_cli(self, home, *args, root=None):
        env = dict(os.environ, HOME=str(home))
        if root is not None:
            env["SHREYDOT_ROOT"] = str(root)
        return subprocess.run(
            [str(SHREYDOT), *args],
            env=env, capture_output=True, text=True, timeout=30,
        )

    def test_install_help_lists_profiles(self):
        result = subprocess.run(
            [str(SHREYDOT), "install", "-h"],
            capture_output=True, text=True, timeout=30,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        for name in ("noob", "nvim", "agents", "vi", "tmux", "herdr", "full"):
            self.assertIn(name, result.stdout)

    def test_unknown_profile_writes_nothing(self):
        with tempfile.TemporaryDirectory(prefix="shreydot-") as temp:
            home = Path(temp)
            marker = home / ".zshrc"
            marker.write_text("leave me\n")
            result = self.run_cli(home, "install", "noob", "widgets")
            self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
            self.assertEqual(marker.read_text(), "leave me\n")
            self.assertFalse((home / ".dotfiles_backup").exists())

    def test_noob_and_nvim_merge_and_leave_agents_alone(self):
        with tempfile.TemporaryDirectory(prefix="shreydot-") as temp:
            home = Path(temp)
            result = self.run_cli(home, "install", "noob", "nvim", "--links-only")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual((home / ".zshrc").resolve(), ROOT / "minimal/zshrc")
            self.assertEqual((home / ".config/nvim").resolve(), ROOT / "nvim")
            self.assertEqual((home / ".tmux.conf").resolve(), ROOT / "minimal/tmux.conf")
            self.assertFalse((home / ".claude").exists())
            self.assertFalse((home / ".zsh/zsh-autosuggestions").exists())

    def test_vi_tmux_herdr_and_agents_are_separate(self):
        with tempfile.TemporaryDirectory(prefix="shreydot-") as temp:
            home = Path(temp)
            result = self.run_cli(
                home, "install", "vi", "tmux", "herdr", "agents", "--links-only",
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual((home / ".ideavimrc").resolve(), ROOT / "ideavim/.ideavimrc")
            self.assertEqual((home / ".tmux.conf").resolve(), ROOT / "tmux/.tmux.conf")
            self.assertEqual(
                (home / ".config/herdr/config.toml").resolve(),
                ROOT / "herdr/config.toml",
            )
            self.assertEqual(
                (home / ".claude/CLAUDE.md").resolve(),
                ROOT / "claude/AGENTS.md",
            )
            self.assertEqual(
                (home / ".agents/skills/five-knuckle-shuffle").resolve(),
                ROOT / "agents/skills/five-knuckle-shuffle",
            )
            self.assertFalse((home / ".zshrc").exists())
            self.assertFalse((home / ".copilot").exists())
            self.assertFalse((home / ".tmux/plugins/tpm").exists())

    def test_copilot_is_opt_in_and_refused_with_noob(self):
        with tempfile.TemporaryDirectory(prefix="shreydot-") as temp:
            home = Path(temp)
            refused = self.run_cli(home, "install", "noob", "--with-copilot", "--links-only")
            self.assertEqual(refused.returncode, 2, refused.stdout + refused.stderr)
            self.assertFalse(any(home.iterdir()))
            result = self.run_cli(home, "install", "agents", "--with-copilot", "--links-only")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(
                (home / ".copilot/copilot-instructions.md").resolve(),
                ROOT / "claude/AGENTS.md",
            )
            self.assertEqual(
                (home / ".copilot/settings.json").read_bytes(),
                (ROOT / "copilot/settings.json").read_bytes(),
            )

    def test_repeat_install_keeps_one_backup(self):
        with tempfile.TemporaryDirectory(prefix="shreydot-") as temp:
            home = Path(temp)
            (home / ".ideavimrc").write_text("original\n")
            for _ in range(2):
                result = self.run_cli(home, "install", "vi", "--links-only")
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            backups = list((home / ".dotfiles_backup").glob("shreydot.*"))
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / ".ideavimrc").read_text(), "original\n")

    def test_root_override_is_what_symlinks_store(self):
        with tempfile.TemporaryDirectory(prefix="shreydot-") as temp:
            home = Path(temp) / "home"
            home.mkdir()
            via_opt = Path(temp) / "opt-shreydot"
            via_opt.symlink_to(ROOT)
            result = self.run_cli(home, "install", "vi", "--links-only", root=via_opt)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(
                os.readlink(home / ".ideavimrc"),
                str(via_opt / "ideavim/.ideavimrc"),
            )

    def test_full_refuses_to_mix(self):
        with tempfile.TemporaryDirectory(prefix="shreydot-") as temp:
            home = Path(temp)
            result = self.run_cli(home, "install", "full", "noob")
            self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
            self.assertFalse(any(home.iterdir()))


if __name__ == "__main__":
    unittest.main()
