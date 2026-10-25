-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function search_repo_files()
  Snacks.picker.files({ cwd = vim.fs.root(0, ".git") or vim.fn.getcwd() })
end

-- Cursor embeds Neovim, but the language server stays in the editor.
-- These chords call Cursor. In a terminal, <leader>gd is still git diff.
if vim.g.vscode then
  local function action(command)
    return function()
      require("vscode").action(command)
    end
  end

  local function map(mode, lhs, command, desc)
    vim.keymap.set(mode, lhs, action(command), { desc = desc, silent = true })
  end

  map("n", "gd", "editor.action.revealDefinition", "Goto Definition")
  map("n", "<leader>gd", "editor.action.revealDefinition", "Goto Definition")
  map("n", "gD", "editor.action.revealDeclaration", "Goto Declaration")
  map("n", "gr", "editor.action.referenceSearch.trigger", "References")
  map("n", "gI", "editor.action.goToImplementation", "Goto Implementation")
  map("n", "gy", "editor.action.goToTypeDefinition", "Goto Type Definition")
  map("n", "K", "editor.action.showHover", "Hover")
  map({ "n", "x" }, "<leader>ca", "editor.action.quickFix", "Code Action")
  map("n", "<leader>cr", "editor.action.rename", "Rename")
  map("n", "<leader>cf", "editor.action.formatDocument", "Format")
  map("x", "<leader>cf", "editor.action.formatSelection", "Format Selection")
  map("n", "]d", "editor.action.marker.next", "Next Diagnostic")
  map("n", "[d", "editor.action.marker.prev", "Prev Diagnostic")
  map("n", "<leader>cd", "editor.action.showHover", "Line Diagnostics")
  map("n", "<leader>e", "workbench.view.explorer", "Explorer")
  map("n", "<leader>ff", "workbench.action.quickOpen", "Find Files")
  map("n", "<leader>sf", "workbench.action.quickOpen", "Search Files (Repo)")
  map("n", "sf", "workbench.action.quickOpen", "Search Files (Repo)")
  map("n", "<leader>sg", "workbench.action.findInFiles", "Grep")
  map("n", "ff", "workbench.action.findInFiles", "Fuzzy Find (grep)")
  return
end

vim.keymap.set("n", "<leader>sf", search_repo_files, { desc = "Search Files (Repo)" })
vim.keymap.set("n", "sf", search_repo_files, { desc = "Search Files (Repo)" })
vim.keymap.set("n", "ff", function() Snacks.picker.grep() end, { desc = "Fuzzy Find (grep)" })
