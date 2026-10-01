# url-forwarder

Forward browser-opening calls from a headless Linux VM back to the local Mac's
default browser, so OAuth/device-auth flows in CLI tools (gh, gcloud, MCP
servers, etc.) work without copy-pasting URLs.

## How it works

```
┌─────────────────────────────┐         ┌────────────────────────────┐
│  Mac (local)                │   SSH   │  Linux VM                  │
│                             │ ◄─────► │                            │
│  url-listener   :9999 ◄──── │ ─R 9999 │ ──── localhost:9999 ◄── xdg-open
│  (opens URLs)               │         │                       (PATH shim)
│                             │         │                            │
│  browser  ──► localhost:8080│ ─L 8080 │ ──► localhost:8080         │
│  (OAuth callback)           │         │  (CLI's callback server)   │
└─────────────────────────────┘         └────────────────────────────┘
```

- **`-R 9999`** (reverse): VM → Mac. VM tells Mac "open this URL."
- **`-L 8080/8000/3000`** (forward): Mac → VM. Browser's OAuth callback reaches the CLI.

## Setup

After dotbot runs on both machines, `~/.local/bin` contains all four scripts.

### On the Mac

1. **Register a VM** (writes to `~/.ssh/url-forwarder.conf` and adds an `Include` line to an existing `~/.ssh/config.custom`, or otherwise to `~/.ssh/config`):

   ```sh
   url-forwarder-register myvm coder@vm.example.com
   ```

   List or remove:
   ```sh
   url-forwarder-register --list
   url-forwarder-register --remove myvm
   ```

2. **Start the listener** in a terminal/tmux pane (leave it running):
   ```sh
   url-listener
   ```

### On the VM

Nothing manual. After `dotbot` runs:
- `~/.local/bin/open-on-host` and `~/.local/bin/xdg-open` exist.
- `~/.zshrc` exports `BROWSER=open-on-host` automatically when `$SSH_CONNECTION` is set.

## Daily flow

```sh
# Mac
url-listener &        # or in a tmux pane
ssh myvm              # forwards apply automatically

# VM (inside the SSH session)
gh auth login --web   # browser pops on Mac, callback returns through the tunnel
```

## Config

| Env var              | Default              | Used by                |
|----------------------|----------------------|------------------------|
| `URL_LISTENER_PORT`  | `9999`               | listener, sender, register |
| `CALLBACK_PORTS`     | `"8080 8000 3000"`   | register (LocalForwards) |

To add another callback port for a one-off CLI, edit
`~/.ssh/url-forwarder.conf` directly and add another `LocalForward` line.

## Security notes

- The listener binds to `127.0.0.1` only — never reachable from the LAN.
- Only `http://` and `https://` URLs are passed to `open`; everything else
  is rejected (no `file://`, `javascript:`, custom handlers, etc.).
- `open --` is used (no shell interpolation) so URL content can't break out.
- A compromised VM can still feed phishing URLs through the tunnel — same
  threat model as anything else running on a VM you trust.

## Troubleshooting

- **"could not reach url-listener"** on the VM → listener isn't running on
  the Mac, or the SSH reverse tunnel didn't establish. Check with
  `ss -tlnp | grep 9999` on the VM (should show sshd listening).
- **Browser opens, but the CLI hangs** → callback port isn't in
  `CALLBACK_PORTS`. Add a `LocalForward` for the port the CLI is using.
- **`xdg-open` not being intercepted** → the tool is calling
  `/usr/bin/xdg-open` by absolute path. Rare; tell upstream to respect
  `$PATH` or `$BROWSER`.
