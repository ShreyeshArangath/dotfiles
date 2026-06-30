-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Colorscheme: "tokyonight", "catppuccin", "tokyonight-night", "tokyonight-storm", "catppuccin-mocha", etc.
vim.g.lazyvim_colorscheme = "catppuccin"

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
