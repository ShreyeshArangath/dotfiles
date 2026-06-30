return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = true,
      ensure_installed = {
        "bash",
        "go",
        "java",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },
}
