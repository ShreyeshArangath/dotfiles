-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "sf", function() Snacks.picker.files() end, { desc = "Search Files" })
vim.keymap.set("n", "ff", function() Snacks.picker.grep() end, { desc = "Fuzzy Find (grep)" })
