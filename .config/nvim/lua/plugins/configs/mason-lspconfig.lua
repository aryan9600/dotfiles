return function(_, opts)
  local lsp = require "astronvim.utils.lsp"
  local mason_lspconfig = require "mason-lspconfig"
  -- mason-lspconfig v2 dropped `handlers`: AstroNvim configures and enables every installed server itself (so it
  -- gets the AstroNvim on_attach/capabilities and lua/user/lsp/config/<server>.lua) instead of `automatic_enable`
  opts.automatic_enable = false
  mason_lspconfig.setup(opts)

  -- this plugin is loaded as a dependency of nvim-lspconfig, so wait until nvim-lspconfig is on the runtimepath
  -- (its lsp/<server>.lua files provide the base server configs) before setting the servers up
  vim.schedule(function()
    vim.tbl_map(lsp.setup, mason_lspconfig.get_installed_servers())

    -- like the old handlers, also set up servers installed later through mason
    require("mason-registry"):on(
      "package:install:success",
      vim.schedule_wrap(function(pkg)
        local server = require("mason-lspconfig.mappings").get_mason_map().package_to_lspconfig[pkg.name]
        if server and not lsp.servers[server] then lsp.setup(server) end
      end)
    )
    require("astronvim.utils").event "MasonLspSetup"
  end)
end
