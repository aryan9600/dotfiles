return function(_, _)
  local lsp = require "astronvim.utils.lsp"
  local utils = require "astronvim.utils"
  local get_icon = utils.get_icon

  -- diagnostic signs are configured through `vim.diagnostic.config` since Neovim 0.10 (`sign_define` is ignored)
  local severity = vim.diagnostic.severity
  lsp.setup_diagnostics {
    [severity.ERROR] = get_icon "DiagnosticError",
    [severity.WARN] = get_icon "DiagnosticWarn",
    [severity.HINT] = get_icon "DiagnosticHint",
    [severity.INFO] = get_icon "DiagnosticInfo",
  }
  -- nvim-dap still uses legacy signs
  for _, sign in ipairs {
    { name = "DapStopped", text = get_icon "DapStopped", texthl = "DiagnosticWarn" },
    { name = "DapBreakpoint", text = get_icon "DapBreakpoint", texthl = "DiagnosticInfo" },
    { name = "DapBreakpointRejected", text = get_icon "DapBreakpointRejected", texthl = "DiagnosticError" },
    { name = "DapBreakpointCondition", text = get_icon "DapBreakpointCondition", texthl = "DiagnosticInfo" },
    { name = "DapLogPoint", text = get_icon "DapLogPoint", texthl = "DiagnosticInfo" },
  } do
    vim.fn.sign_define(sign.name, sign)
  end

  local orig_handler = vim.lsp.handlers["$/progress"]
  vim.lsp.handlers["$/progress"] = function(_, msg, info)
    local progress, id = astronvim.lsp.progress, ("%s.%s"):format(info.client_id, msg.token)
    progress[id] = progress[id] and utils.extend_tbl(progress[id], msg.value) or msg.value
    if progress[id].kind == "end" then
      vim.defer_fn(function()
        progress[id] = nil
        utils.event "LspProgress"
      end, 100)
    end
    utils.event "LspProgress"
    orig_handler(_, msg, info)
  end

  if vim.g.lsp_handlers_enabled then
    -- `vim.lsp.with` handler overrides are no longer used for these requests, so default the float options instead
    -- (this also covers the built-in `K` and insert mode `<C-s>` mappings)
    for _, method in ipairs { "hover", "signature_help" } do
      local orig = vim.lsp.buf[method]
      vim.lsp.buf[method] = function(config)
        return orig(utils.extend_tbl({ border = "rounded", silent = true }, config))
      end
    end
  end
  local setup_servers = function()
    vim.tbl_map(require("astronvim.utils.lsp").setup, astronvim.user_opts "lsp.servers")
    require("astronvim.utils").event "LspSetup"
  end
  if require("astronvim.utils").is_available "mason-lspconfig.nvim" then
    vim.api.nvim_create_autocmd("User", {
      desc = "set up LSP servers after mason-lspconfig",
      pattern = "AstroMasonLspSetup",
      once = true,
      callback = setup_servers,
    })
  else
    setup_servers()
  end
end
