-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Prefer the Command Line Tools' default SDK over a newer, incompatible SDK
-- selected by xcrun. Keep explicit SDK choices and non-macOS setups unchanged.
local default_sdk = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
if vim.fn.has("mac") == 1 and not vim.env.SDKROOT and vim.fn.isdirectory(default_sdk) == 1 then
  vim.env.SDKROOT = default_sdk
end

-- Colorscheme is configured through LazyVim in plugins/colorscheme.lua.

-- Make yank reach the *local* clipboard when running over SSH, using OSC 52.
-- Neovim encodes yanked text into a terminal escape sequence that travels back
-- through the SSH connection to your terminal emulator, which sets the clipboard.
-- (paste falls back to the unnamed register, since OSC 52 read is rarely supported)
if vim.env.SSH_TTY then
  local function paste()
    return vim.split(vim.fn.getreg(""), "\n")
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end
