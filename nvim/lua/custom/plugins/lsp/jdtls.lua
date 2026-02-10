vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    local jdtls = require 'jdtls'
    local mason_registry = require 'mason-registry'
    print 'Starting JDTLS...'

    -- Get jdtls installed path from Mason
    local jdtls_pkg = mason_registry.get_package 'jdtls'
    local jdtls_path = jdtls_pkg:get_install_path()

    -- Compute workspace dir unique to project
    local workspace_dir = vim.fn.expand '~/.cache/jdtls/workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

    -- Use lspconfig to find root
    local root_dir = require('lspconfig.util').root_pattern('pom.xml', 'build.gradle', '.git')(vim.fn.getcwd()) or vim.fn.getcwd()

    local config = {
      cmd = {
        jdtls_path .. '/bin/jdtls',
        '-data',
        workspace_dir,
      },
      root_dir = root_dir,
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = 'Java8',
                path = '/Library/Java/JavaVirtualMachines/jdk1.8.0_282-msft.jdk/Contents/Home',
              },
              {
                name = 'Java11',
                path = '/Library/Java/JavaVirtualMachines/jdk11.0.8-msft.jdk/Contents/Home',
              },
              {
                name = 'JavaSE-17',
                path = '/Library/Java/JavaVirtualMachines/jdk17.0.5-msft.jdk/Contents/Home',
              },
            },
          },
        },
      },
    }

    jdtls.start_or_attach(config)
  end,
})
