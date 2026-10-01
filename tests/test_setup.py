import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "dotbot/lib/pyyaml/lib"))
import yaml


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home with spaces"
        self.home.mkdir()
        self.bin = Path(self.temp.name) / "bin"
        self.bin.mkdir()
        for command in ("brew", "curl", "git", "sudo", "tmux"):
            stub = self.bin / command
            stub.write_text("#!/bin/sh\nexit 97\n")
            stub.chmod(0o755)
        self.env = dict(os.environ, HOME=str(self.home),
                        PATH=f"{self.bin}:{os.environ['PATH']}")
        for name in ("XDG_CONFIG_HOME", "XDG_CACHE_HOME", "XDG_DATA_HOME",
                     "XDG_STATE_HOME", "TMUX", "ZDOTDIR"):
            self.env.pop(name, None)

    def setup_configs(self, *args):
        return subprocess.run(
            ["bash", str(ROOT / "bootstrap.sh"), "--links-only", *args],
            cwd=self.temp.name, env=self.env, capture_output=True, text=True,
            timeout=30,
        )

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_links_only_restores_portable_configs_without_installers(self):
        self.assert_success(self.setup_configs())
        expected = {
            ".zshrc": "zsh/.zshrc",
            ".p10k.zsh": "zsh/.p10k.zsh",
            ".ideavimrc": "ideavim/.ideavimrc",
            ".config/herdr/config.toml": "herdr/config.toml",
            ".config/herdr/sounds/silent.mp3": "herdr/sounds/silent.mp3",
            ".config/ghostty/config": "ghostty/config",
            ".config/git/ignore": "git/ignore",
            ".claude/CLAUDE.md": "claude/AGENTS.md",
        }
        for destination, source in expected.items():
            with self.subTest(destination=destination):
                link = self.home / destination
                self.assertTrue(link.is_symlink(), str(link))
                self.assertEqual(link.resolve(), ROOT / source)
        self.assertEqual((self.home / ".config/herdr/config.toml").read_bytes(),
                         (ROOT / "herdr/config.toml").read_bytes())
        self.assertFalse((self.home / ".config/herdr/session.json").exists())
        self.assertFalse((self.home / ".copilot").exists())

    def test_copilot_opt_in_restores_its_configs(self):
        self.assert_success(self.setup_configs("--with-copilot"))
        instructions = self.home / ".copilot/copilot-instructions.md"
        self.assertEqual(instructions.resolve(), ROOT / "claude/AGENTS.md")
        skill = self.home / ".copilot/skills/humanizer"
        self.assertEqual(skill.resolve(), ROOT / "copilot/skills/humanizer")
        self.assertEqual((self.home / ".copilot/settings.json").read_bytes(),
                         (ROOT / "copilot/settings.json").read_bytes())

    def test_default_setup_leaves_existing_copilot_files_untouched(self):
        instructions = self.home / ".copilot/copilot-instructions.md"
        skill = self.home / ".copilot/skills/humanizer/SKILL.md"
        instructions.parent.mkdir()
        instructions.write_text("my instructions\n")
        skill.parent.mkdir(parents=True)
        skill.write_text("my skill\n")
        self.assert_success(self.setup_configs())
        self.assertFalse(instructions.is_symlink())
        self.assertEqual(instructions.read_text(), "my instructions\n")
        self.assertEqual(skill.read_text(), "my skill\n")
        self.assertFalse((self.home / ".copilot/settings.json").exists())

    def test_copilot_opt_in_preserves_existing_settings(self):
        settings = self.home / ".copilot/settings.json"
        settings.parent.mkdir()
        settings.write_text('{"model": "my-model"}\n')
        self.assert_success(self.setup_configs("--with-copilot"))
        self.assertEqual(settings.read_text(), '{"model": "my-model"}\n')

    def test_existing_configs_and_old_backups_survive_repeat_setup(self):
        old_backup = self.home / ".dotfiles_backup" / "old"
        old_backup.mkdir(parents=True)
        (old_backup / ".zshrc").write_text("old backup\n")
        originals = {
            ".zshrc": "original shell\n",
            ".config/herdr/config.toml": "original herdr\n",
        }
        if sys.platform == "darwin":
            originals.update({
                ".config/karabiner/karabiner.json": '{"original": true}\n',
                "Library/Application Support/com.mitchellh.ghostty/config": "font-size = 18\n",
            })
        for path, content in originals.items():
            target = self.home / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)
        nvim = self.home / ".config/nvim/lua"
        nvim.mkdir(parents=True)
        (nvim / "original.lua").write_text("return {}\n")
        self.assert_success(self.setup_configs())
        for path, content in originals.items():
            backups = list((self.home / ".dotfiles_backup").glob(f"backup.*/{path}"))
            self.assertEqual(len(backups), 1, path)
            self.assertEqual(backups[0].read_text(), content)
        nvim_backups = list((self.home / ".dotfiles_backup").glob(
            "backup.*/.config/nvim/lua/original.lua"))
        self.assertEqual(len(nvim_backups), 1)
        self.assertEqual(nvim_backups[0].read_text(), "return {}\n")
        self.assert_success(self.setup_configs())
        self.assertEqual((old_backup / ".zshrc").read_text(), "old backup\n")

    def test_local_workplace_overrides_are_not_overwritten(self):
        for path in (".zshrc.local", ".gitconfig.local", ".copilot/settings.json"):
            target = self.home / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text("local-only\n")
        self.assert_success(self.setup_configs())
        for path in (".zshrc.local", ".gitconfig.local", ".copilot/settings.json"):
            self.assertEqual((self.home / path).read_text(), "local-only\n")

    def test_invalid_option_fails_without_touching_home(self):
        result = self.setup_configs("--unknown")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home / ".dotfiles_backup").exists())
        self.assertFalse((self.home / ".zshrc").exists())

    def test_linux_skips_macos_only_config_destinations(self):
        uname = self.bin / "uname"
        uname.write_text("#!/bin/sh\necho Linux\n")
        uname.chmod(0o755)
        native_config = self.home / "Library/Application Support/com.mitchellh.ghostty/config"
        keyboard_config = self.home / ".config/karabiner/karabiner.json"
        for target in (native_config, keyboard_config):
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text("untouched\n")
        self.assert_success(self.setup_configs())
        for target in (native_config, keyboard_config):
            self.assertFalse(target.is_symlink())
            self.assertTrue(target.exists(), str(target))
            self.assertEqual(target.read_text(), "untouched\n")
        self.assertTrue((self.home / ".config/herdr/config.toml").is_symlink())

    def run_install_step(self, description):
        config = yaml.safe_load((ROOT / "install.conf.yaml").read_text())
        command = next(
            step["command"] for group in config for step in group.get("shell", [])
            if step["description"] == description
        )
        return subprocess.run(["bash", "-c", command], cwd=ROOT, env=self.env,
                              capture_output=True, text=True, timeout=10)

    def test_tpm_clone_failure_propagates(self):
        result = self.run_install_step("Installing Tmux Plugin Manager (TPM)")
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_tmux_plugin_failure_propagates(self):
        plugin_dir = self.home / ".tmux/plugins"
        installer = plugin_dir / "tpm/bin/install_plugins"
        installer.parent.mkdir(parents=True)
        installer.write_text("#!/bin/sh\nexit 97\n")
        for plugin in ("tmux", "tmux-yank", "tmux-resurrect", "tmux-continuum"):
            (plugin_dir / plugin).mkdir()
        result = self.run_install_step("Installing Tmux plugins")
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
