# Dotfiles

Personal macOS and Linux configs managed with [Dotbot](https://github.com/anishathalye/dotbot).
No employer credentials, SSH host registrations, or agent session data belong here.

## Set up a new device

For a lean setup using only local files and Python 3:

```bash
./bootstrap.sh --minimal
```

This installs zsh, Git, tmux, Neovim, and Ghostty **configs** without initializing
Dotbot submodules or pulling a full plugin framework. It keeps built-in shell
completion, Vim keybindings, prefix history search (including Herdr/tmux
application-mode arrows), a simple prompt, and basic editor/tmux settings. It
shallow-clones two light upstream zsh plugins into `~/.zsh/` —
`zsh-autosuggestions` (history ghost-text) and `zsh-syntax-highlighting` — and
skips fonts, Karabiner, agent hooks/instructions, browser forwarding, theme
downloads, and session restoration. Pass `--skip-zsh-plugins` through
`install-minimal.py` if you want links only. tmux and Neovim must be installed
separately to use their configs. Git uses the personal identity below; workplace
overrides go in `~/.gitconfig.local` / `~/.zshrc.local`. Existing configs
(including foreign symlinks) are backed up under `~/.dotfiles_backup/minimal.*`;
repeat runs preserve installed links. `~/.zshrc.local` is still loaded and is
never overwritten. Other profiles below retain the full setup; `--minimal`
cannot be combined with `--with-copilot`.

To add the optional prompt and one font through Homebrew:

```bash
brew install tmux neovim powerlevel10k
brew install --cask font-jetbrains-mono-nerd-font
```

The lean shell loads Powerlevel10k when installed, using `minimal/p10k.zsh`.
The Ghostty config selects `JetBrainsMono Nerd Font Mono` to display its icons.

To keep the lean shell and other configs but restore the full Neovim setup:

```bash
./bootstrap.sh --minimal --with-nvim
brew install fzf fd ripgrep gh tree-sitter-cli
nvim
```

This links `nvim/` (LazyVim, Catppuccin, Snacks, fzf-lua, Octo, and Tree-sitter).
The bootstrap step only links configs; launching Neovim downloads its configured
plugins and builds their dependencies. Use `--with-nvim` on subsequent lean
bootstrap runs to keep the full config. Octo requires a separately authenticated
GitHub CLI account for its GitHub features.
Leave Neovim open until plugin, formatter, and parser installation finishes.

To include Herdr settings and its silent notification sound as well:

```bash
./bootstrap.sh --minimal --with-nvim --with-herdr
herdr config check
```

This only installs `config.toml` and `sounds/silent.mp3`; the Herdr binary must
already be installed. For a running server, apply the settings with
`herdr server reload-config`.

Install Git and Python 3.7+ first. On macOS, also install
[Homebrew](https://brew.sh) using a method approved for that device.

```bash
git clone --recurse-submodules https://github.com/ShreyeshArangath/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Full setup installs Homebrew packages on macOS, or essential packages through
apt/dnf/yum on Linux, plus shell and tmux plugins. Use it only where those
dependencies are approved; installation needs internet access and sudo on Linux.

To restore configs without installing packages or plugins:

```bash
./bootstrap.sh --links-only
```

Config-only setup needs Python and the initialized Dotbot submodules. Existing
regular files and config directories are moved into a unique directory under
`~/.dotfiles_backup/`, preserving older backups. Re-running setup refreshes symlinks.
It does not overwrite `~/.zshrc.local`, `~/.gitconfig.local`, or existing Copilot settings.
It does not change your default shell or restart any running terminal sessions.

**Copilot is skipped by default.** Neither mode creates, backs up, links, or changes
Copilot files unless you explicitly opt in:

```bash
./bootstrap.sh --links-only --with-copilot
```

Opt-in copies personal settings only if `~/.copilot/settings.json` is absent.

After setup:

- Restart your shell. If wanted, select zsh with `chsh -s "$(command -v zsh)"`.
- Both bootstrap profiles enable Vim-style command editing: press `Esc` for normal
  mode, use `h`/`l`, `w`/`b`, `dw`, or `ciw`, then `i` to resume typing. Press
  `Esc`, then `v` (or `Ctrl-X`, `Ctrl-E` while typing) to edit the command in
  Neovim when installed, otherwise vi. Save and quit to return to the command
  line; press Enter to run it. Run `exec zsh` to activate changes in an old shell.
- Open Neovim to install its configured plugins.
- Install Herdr through an approved source, then reload its config or restart it.
  Its binary and plugins are not installed by this repo.
- On macOS, grant Karabiner-Elements the permissions it requests.

## What's tracked

| Directory | Configs |
|---|---|
| `zsh/` | Shell config, login paths, Powerlevel10k prompt |
| `git/` | Personal identity, portable GitHub credential helper, global ignore rules |
| `tmux/` | Vim navigation, Dracula theme, resurrect/continuum session settings |
| `nvim/` | LazyVim setup, plugins, keymaps, SSH clipboard settings |
| `ideavim/` | IdeaVim options and IDE keymaps |
| `herdr/` | Theme, navigation, agent restore preferences, silent notification sound |
| `ghostty/` | Shift+Enter and macOS window preferences |
| `karabiner/` | macOS keyboard remapping |
| `claude/` | Shared agent instructions, personal skills, notification hook |
| `copilot/` | Optional personal defaults and humanizer skill (`--with-copilot`) |
| `url-forwarder/` | Browser forwarding from an SSH-connected VM |

Herdr logs, sockets, session snapshots, plugin registries, and saved workspaces
stay local. Herdr's memory/disk status commands and Ghostty's window preferences
are macOS-specific; adjust them if restoring those apps on another OS.
Karabiner and Ghostty's native macOS config path are linked only on macOS.

`claude/AGENTS.md` supplies Claude's global instructions and, when opted in,
Copilot's instructions. Run `p10k configure` to regenerate the prompt config with
the wizard's full comments.

## Keep workplace settings local

Shell settings go in `~/.zshrc.local`, which is sourced after the shared config.
For example, put the workplace's PATH entries or JAVA_HOME there rather than
changing the shared config. The Java helpers `use_java_8`, `use_java_11`,
`use_java_17`, and `use_java_21` use macOS's installed JDK registry.
No Java version is forced during shell startup.

Git includes `~/.gitconfig.local` for identity overrides:

```gitconfig
[user]
    name = Your Name
    email = your-work-email@example.com
```

For different identities by repository location, put an `includeIf` rule in that
local file instead of changing the personal defaults. Credentials, SSH keys,
MCP connections, and employer-specific agent settings must be configured separately
using that workplace's approved tools. Setup does not authenticate accounts.

Local override files in the repo are ignored. Do not copy whole `~/.config`,
`~/.claude`, or `~/.copilot` directories into the repo.

## Updating and capturing changes

```bash
cd ~/dotfiles
git pull --ff-only
./bootstrap.sh --links-only
```

Most configs are symlinked, so edits to their installed paths update this repo.
Before committing, inspect the diff and check for private data:

```bash
git status --short
git diff
```

To add a config, add its file and a link in `install.conf.yaml`, then include its
installed path in the backup list in `bootstrap.sh`. Use a platform condition for
OS-specific destinations.

## Checks

```bash
python3 -m unittest discover -s tests -v
bash -n bootstrap.sh
zsh -n zsh/.zshrc
```

Tests use temporary homes and block installers. They cover config links, preserved
backups and overrides, platform conditions, and Copilot opt-in.

See [url-forwarder/README.md](url-forwarder/README.md) for VM browser forwarding.
