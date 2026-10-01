# Dotfiles

Personal macOS and Linux configs managed with [Dotbot](https://github.com/anishathalye/dotbot).
No employer credentials, SSH host registrations, or agent session data belong here.

## Set up a new device

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
