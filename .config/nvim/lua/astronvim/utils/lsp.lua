--- ### AstroNvim LSP Utils
--
-- LSP related utility functions to use within AstroNvim and user configurations.
--
-- This module can be loaded with `local lsp_utils = require("astronvim.utils.lsp")`
--
-- @module astronvim.utils.lsp
-- @see astronvim.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

local M = {}
local tbl_contains = vim.tbl_contains
local tbl_isempty = vim.tbl_isempty
local user_opts = astronvim.user_opts

local utils = require "astronvim.utils"
local conditional_func = utils.conditional_func
local is_available = utils.is_available
local extend_tbl = utils.extend_tbl

local server_config = "lsp.config."
local setup_handlers = user_opts("lsp.setup_handlers", {
  function(server, opts)
    vim.lsp.config(server, opts)
    vim.lsp.enable(server)
  end,
})

--- names of the language servers that have been set up through `M.setup`
M.servers = {}

M.diagnostics = { [0] = {}, {}, {}, {} }

---@param signs table<vim.diagnostic.Severity,string> sign text for each diagnostic severity
M.setup_diagnostics = function(signs)
  local default_diagnostics = astronvim.user_opts("diagnostics", {
    virtual_text = true,
    signs = { text = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = true,
      header = "",
      prefix = "",
    },
  })
  M.diagnostics = {
    -- diagnostics off
    [0] = extend_tbl(
      default_diagnostics,
      { underline = false, virtual_text = false, signs = false, update_in_insert = false }
    ),
    -- status only
    extend_tbl(default_diagnostics, { virtual_text = false, signs = false }),
    -- virtual text off, signs on
    extend_tbl(default_diagnostics, { virtual_text = false }),
    -- all diagnostics on
    default_diagnostics,
  }

  vim.diagnostic.config(M.diagnostics[vim.g.diagnostics_mode])
end

M.formatting = user_opts("lsp.formatting", { format_on_save = { enabled = true }, disabled = {} })
if type(M.formatting.format_on_save) == "boolean" then
  M.formatting.format_on_save = { enabled = M.formatting.format_on_save }
end

M.format_opts = vim.deepcopy(M.formatting)
M.format_opts.disabled = nil
M.format_opts.format_on_save = nil
M.format_opts.filter = function(client)
  local filter = M.formatting.filter
  local disabled = M.formatting.disabled or {}
  -- check if client is fully disabled or filtered by function
  return not (vim.tbl_contains(disabled, client.name) or (type(filter) == "function" and not filter(client)))
end

--- Helper function to set up a given server with the Neovim LSP client
---@param server string The name of the server to be setup
M.setup = function(server)
  -- servers without a config shipped by nvim-lspconfig (lsp/<server>.lua) can be fully defined by the user
  -- config file, `vim.lsp.config` merges both so no special handling is needed
  local opts = M.config(server)
  local setup_handler = setup_handlers[server] or setup_handlers[1]
  if not vim.tbl_contains(astronvim.lsp.skip_setup, server) and setup_handler then
    setup_handler(server, opts)
    M.servers[server] = true
  end
end

--- Helper function to check if any active LSP clients given a filter provide a specific capability
---@param capability string The server capability to check for (example: "documentFormattingProvider")
---@param filter vim.lsp.get_clients.Filter|nil (table|nil) A table with
---              key-value pairs used to filter the returned clients.
---              The available keys are:
---               - id (number): Only return clients with the given id
---               - bufnr (number): Only return clients attached to this buffer
---               - name (string): Only return clients with the given name
---@return boolean # Whether or not any of the clients provide the capability
function M.has_capability(capability, filter)
  for _, client in ipairs(vim.lsp.get_clients(filter)) do
    if client:supports_method(capability, filter and filter.bufnr) then return true end
  end
  return false
end

local function add_buffer_autocmd(augroup, bufnr, autocmds)
  if not vim.islist(autocmds) then autocmds = { autocmds } end
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
  if not cmds_found or vim.tbl_isempty(cmds) then
    vim.api.nvim_create_augroup(augroup, { clear = false })
    for _, autocmd in ipairs(autocmds) do
      local events = autocmd.events
      autocmd.events = nil
      autocmd.group = augroup
      autocmd.buffer = bufnr
      vim.api.nvim_create_autocmd(events, autocmd)
    end
  end
end

local function del_buffer_autocmd(augroup, bufnr)
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
  if cmds_found then vim.tbl_map(function(cmd) vim.api.nvim_del_autocmd(cmd.id) end, cmds) end
end

-- open the diagnostic float after jumping, like the removed `vim.diagnostic.goto_next/prev` did by default
local function open_jump_float(_, bufnr) vim.diagnostic.open_float { bufnr = bufnr, scope = "cursor", focus = false } end

--- The `on_attach` function used by AstroNvim
---@param client table The LSP client details when attaching
---@param bufnr number The buffer that the LSP client is attaching to
M.on_attach = function(client, bufnr)
  local lsp_mappings = require("astronvim.utils").empty_map_table()

  lsp_mappings.n["<leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }
  lsp_mappings.n["[d"] = { function() vim.diagnostic.jump { count = -1, on_jump = open_jump_float } end, desc = "Previous diagnostic" }
  lsp_mappings.n["]d"] = { function() vim.diagnostic.jump { count = 1, on_jump = open_jump_float } end, desc = "Next diagnostic" }
  lsp_mappings.n["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }

  if is_available "telescope.nvim" then
    lsp_mappings.n["<leader>lD"] =
      { function() require("telescope.builtin").diagnostics() end, desc = "Search diagnostics" }
  end

  if is_available "mason-lspconfig.nvim" then
    -- nvim-lspconfig no longer defines :LspInfo on Neovim 0.12, it was an alias for this
    lsp_mappings.n["<leader>li"] = { "<cmd>checkhealth vim.lsp<cr>", desc = "LSP information" }
  end

  if is_available "null-ls.nvim" then
    lsp_mappings.n["<leader>lI"] = { "<cmd>NullLsInfo<cr>", desc = "Null-ls information" }
  end

  if client:supports_method("textDocument/codeAction", bufnr) then
    lsp_mappings.n["<leader>la"] = {
      function() vim.lsp.buf.code_action() end,
      desc = "LSP code action",
    }
    lsp_mappings.v["<leader>la"] = lsp_mappings.n["<leader>la"]
  end

  if client:supports_method("textDocument/codeLens", bufnr) then
    -- Neovim 0.12 keeps enabled code lenses refreshed itself (replaces the old InsertLeave/BufEnter refresh autocmd)
    vim.lsp.codelens.enable(vim.g.codelens_enabled, { bufnr = bufnr })
    lsp_mappings.n["<leader>ll"] = {
      function()
        vim.lsp.codelens.enable(false, { bufnr = 0 })
        vim.lsp.codelens.enable(true, { bufnr = 0 })
      end,
      desc = "LSP CodeLens refresh",
    }
    lsp_mappings.n["<leader>lL"] = {
      function() vim.lsp.codelens.run() end,
      desc = "LSP CodeLens run",
    }
  end

  if client:supports_method("textDocument/declaration", bufnr) then
    lsp_mappings.n["gD"] = {
      function() vim.lsp.buf.declaration() end,
      desc = "Declaration of current symbol",
    }
  end

  if client:supports_method("textDocument/definition", bufnr) then
    lsp_mappings.n["gd"] = {
      function() vim.lsp.buf.definition() end,
      desc = "Show the definition of current symbol",
    }
  end

  if client:supports_method("textDocument/formatting", bufnr) and not tbl_contains(M.formatting.disabled, client.name) then
    lsp_mappings.n["<leader>lf"] = {
      function() vim.lsp.buf.format(M.format_opts) end,
      desc = "Format buffer",
    }
    lsp_mappings.v["<leader>lf"] = lsp_mappings.n["<leader>lf"]

    vim.api.nvim_buf_create_user_command(
      bufnr,
      "Format",
      function() vim.lsp.buf.format(M.format_opts) end,
      { desc = "Format file with LSP" }
    )
    local autoformat = M.formatting.format_on_save
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
    if
      autoformat.enabled
      and (tbl_isempty(autoformat.allow_filetypes or {}) or tbl_contains(autoformat.allow_filetypes, filetype))
      and (tbl_isempty(autoformat.ignore_filetypes or {}) or not tbl_contains(autoformat.ignore_filetypes, filetype))
    then
      add_buffer_autocmd("lsp_auto_format", bufnr, {
        events = "BufWritePre",
        desc = "autoformat on save",
        callback = function()
          if not M.has_capability("textDocument/formatting", { bufnr = bufnr }) then
            del_buffer_autocmd("lsp_auto_format", bufnr)
            return
          end
          local autoformat_enabled = vim.b.autoformat_enabled
          if autoformat_enabled == nil then autoformat_enabled = vim.g.autoformat_enabled end
          if autoformat_enabled and ((not autoformat.filter) or autoformat.filter(bufnr)) then
            vim.lsp.buf.format(extend_tbl(M.format_opts, { bufnr = bufnr }))
          end
        end,
      })
      lsp_mappings.n["<leader>uf"] = {
        function() require("astronvim.utils.ui").toggle_buffer_autoformat() end,
        desc = "Toggle autoformatting (buffer)",
      }
      lsp_mappings.n["<leader>uF"] = {
        function() require("astronvim.utils.ui").toggle_autoformat() end,
        desc = "Toggle autoformatting (global)",
      }
    end
  end

  if client:supports_method("textDocument/documentHighlight", bufnr) then
    add_buffer_autocmd("lsp_document_highlight", bufnr, {
      {
        events = { "CursorHold", "CursorHoldI" },
        desc = "highlight references when cursor holds",
        callback = function()
          if not M.has_capability("textDocument/documentHighlight", { bufnr = bufnr }) then
            del_buffer_autocmd("lsp_document_highlight", bufnr)
            return
          end
          vim.lsp.buf.document_highlight()
        end,
      },
      {
        events = { "CursorMoved", "CursorMovedI", "BufLeave" },
        desc = "clear references when cursor moves",
        callback = function() vim.lsp.buf.clear_references() end,
      },
    })
  end


  if client:supports_method("textDocument/implementation", bufnr) then
    lsp_mappings.n["gI"] = {
      function() vim.lsp.buf.implementation() end,
      desc = "Implementation of current symbol",
    }
  end

  if client:supports_method("textDocument/inlayHint", bufnr) then
    if vim.b[bufnr].inlay_hints_enabled == nil then vim.b[bufnr].inlay_hints_enabled = vim.g.inlay_hints_enabled end
    if vim.b[bufnr].inlay_hints_enabled then vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end
    lsp_mappings.n["<leader>uH"] = {
      function() require("astronvim.utils.ui").toggle_buffer_inlay_hints(bufnr) end,
      desc = "Toggle LSP inlay hints (buffer)",
    }
  end

  if client:supports_method("textDocument/references", bufnr) then
    lsp_mappings.n["gr"] = {
      function() vim.lsp.buf.references() end,
      desc = "References of current symbol",
    }
    lsp_mappings.n["<leader>lR"] = {
      function() vim.lsp.buf.references() end,
      desc = "Search references",
    }
  end

  if client:supports_method("textDocument/rename", bufnr) then
    lsp_mappings.n["<leader>lr"] = {
      function() vim.lsp.buf.rename() end,
      desc = "Rename current symbol",
    }
  end

  if client:supports_method("textDocument/signatureHelp", bufnr) then
    lsp_mappings.n["<leader>lh"] = {
      function() vim.lsp.buf.signature_help() end,
      desc = "Signature help",
    }
  end

  if client:supports_method("textDocument/typeDefinition", bufnr) then
    lsp_mappings.n["gy"] = {
      function() vim.lsp.buf.type_definition() end,
      desc = "Definition of current type",
    }
  end

  if client:supports_method("workspace/symbol", bufnr) then
    lsp_mappings.n["<leader>lg"] = { function() vim.lsp.buf.workspace_symbol() end, desc = "Search workspace symbols" }
  end

  if client:supports_method("textDocument/semanticTokens/full", bufnr) and vim.lsp.semantic_tokens then
    if vim.g.semantic_tokens_enabled then
      vim.b[bufnr].semantic_tokens_enabled = true
      lsp_mappings.n["<leader>uY"] = {
        function() require("astronvim.utils.ui").toggle_buffer_semantic_tokens(bufnr) end,
        desc = "Toggle LSP semantic highlight (buffer)",
      }
    else
      client.server_capabilities.semanticTokensProvider = nil
    end
  end

  if is_available "telescope.nvim" then -- setup telescope mappings if available
    if lsp_mappings.n.gd then lsp_mappings.n.gd[1] = function() require("telescope.builtin").lsp_definitions() end end
    if lsp_mappings.n.gI then
      lsp_mappings.n.gI[1] = function() require("telescope.builtin").lsp_implementations() end
    end
    if lsp_mappings.n.gr then lsp_mappings.n.gr[1] = function() require("telescope.builtin").lsp_references() end end
    if lsp_mappings.n["<leader>lR"] then
      lsp_mappings.n["<leader>lR"][1] = function() require("telescope.builtin").lsp_references() end
    end
    if lsp_mappings.n.gy then
      lsp_mappings.n.gy[1] = function() require("telescope.builtin").lsp_type_definitions() end
    end
    if lsp_mappings.n["<leader>lG"] then
      lsp_mappings.n["<leader>lG"][1] = function()
        vim.ui.input({ prompt = "Symbol Query: (leave empty for word under cursor)" }, function(query)
          if query then
            -- word under cursor if given query is empty
            if query == "" then query = vim.fn.expand "<cword>" end
            require("telescope.builtin").lsp_workspace_symbols {
              query = query,
              prompt_title = ("Find word (%s)"):format(query),
            }
          end
        end)
      end
    end
  end

  if not vim.tbl_isempty(lsp_mappings.v) then
    lsp_mappings.v["<leader>l"] = { desc = utils.get_icon("ActiveLSP", 1, true) .. "LSP" }
  end
  utils.set_mappings(user_opts("lsp.mappings", lsp_mappings), { buffer = bufnr })

  for id, _ in pairs(astronvim.lsp.progress) do -- clear lingering progress messages
    if not next(vim.lsp.get_clients { id = tonumber(id:match "^%d+") }) then astronvim.lsp.progress[id] = nil end
  end

  local on_attach_override = user_opts("lsp.on_attach", nil, false)
  conditional_func(on_attach_override, true, client, bufnr)
end

--- The default AstroNvim LSP capabilities
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.completion.completionItem.preselectSupport = true
M.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
M.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
M.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
M.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
M.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
M.capabilities.textDocument.completion.completionItem.resolveSupport =
  { properties = { "documentation", "detail", "additionalTextEdits" } }
M.capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
M.capabilities = user_opts("lsp.capabilities", M.capabilities)
M.flags = user_opts "lsp.flags"

-- The config each server had before AstroNvim touched it (nvim-lspconfig's lsp/<server>.lua merged with any
-- `vim.lsp.config` calls), cached so re-running `M.setup` (e.g. from :LspStartWithEnv) doesn't wrap twice
local base_configs = {}
local function base_config(server_name)
  if base_configs[server_name] == nil then
    local ok, config = pcall(function() return vim.lsp.config[server_name] end)
    base_configs[server_name] = ok and config or false
  end
  return base_configs[server_name] or {}
end

-- call a `vim.lsp.Config` callback field, which can be a function or a list of functions
local function run_callbacks(callbacks, ...)
  if type(callbacks) == "function" then callbacks = { callbacks } end
  for _, callback in ipairs(callbacks or {}) do
    callback(...)
  end
end

local function merge_into(dst, src)
  for key, value in pairs(src) do
    if type(value) == "table" and type(dst[key]) == "table" and not vim.islist(value) then
      merge_into(dst[key], value)
    else
      dst[key] = value
    end
  end
end

-- neoconf only hooks nvim-lspconfig's legacy `setup()` framework, so apply its global/local `lspconfig.<server>`
-- settings (.neoconf.json etc.) here the same way its `on_new_config` hook did
local function apply_neoconf_settings(config)
  if not package.loaded["neoconf"] then return end
  local Config, Settings = require "neoconf.config", require "neoconf.settings"
  local root_dir = config.root_dir or vim.fn.getcwd()
  local options = Config.get { file = root_dir }
  if not options.plugins.lspconfig.enabled then return end
  root_dir = require("neoconf.workspace").find_root { file = root_dir }
  local global, root = Settings.get_global(), Settings.get_local(root_dir)
  for _, settings in ipairs {
    global:get("lspconfig." .. config.name, { expand = true }) or {},
    options.import.coc and global:get "coc" or {},
    options.import.nlsp and global:get("nlsp." .. config.name) or {},
    options.import.vscode and root:get "vscode" or {},
    options.import.coc and root:get "coc" or {},
    options.import.nlsp and root:get("nlsp." .. config.name) or {},
    root:get("lspconfig." .. config.name, { expand = true }) or {},
  } do
    -- merge in place: the client keeps a reference to this exact settings table
    merge_into(config.settings, settings)
  end
end

--- Get the server configuration for a given language server to be passed to `vim.lsp.config()`
---@param server_name string The name of the server
---@return table # The table of LSP options used when setting up the given language server
function M.config(server_name)
  local server = base_config(server_name)
  local lsp_opts = { capabilities = M.capabilities, flags = M.flags }
  if server_name == "jsonls" then -- by default add json schemas
    local schemastore_avail, schemastore = pcall(require, "schemastore")
    if schemastore_avail then
      lsp_opts.settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
    end
  end
  if server_name == "yamlls" then -- by default add yaml schemas
    local schemastore_avail, schemastore = pcall(require, "schemastore")
    if schemastore_avail then lsp_opts.settings = { yaml = { schemas = schemastore.yaml.schemas() } } end
  end
  if server_name == "lua_ls" then -- disable third party checking (lazydev.nvim provides the Neovim library)
    lsp_opts.settings = { Lua = { workspace = { checkThirdParty = false } } }
  end
  local opts = user_opts(server_config .. server_name, lsp_opts)
  -- always have a settings table so neoconf settings can be merged into it in place
  if not opts.settings and not server.settings then opts.settings = {} end

  if vim.g.astronvim_lsp_env then
    local env_string = ""
    for k, v in pairs(vim.g.astronvim_lsp_env) do
      env_string = env_string .. k .. "='" .. v .. "' "
    end

    local original_cmd_table = opts.cmd or server.cmd
    if type(original_cmd_table) == "table" then
      local original_cmd = table.concat(original_cmd_table, " ")
      opts.cmd = { "/bin/sh", "-c", env_string .. original_cmd }
    end
  end

  local old_before_init = server.before_init
  local user_before_init = opts.before_init
  opts.before_init = function(params, config)
    apply_neoconf_settings(config)
    run_callbacks(old_before_init, params, config)
    run_callbacks(user_before_init, params, config)
  end

  local old_on_attach = server.on_attach
  local user_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    run_callbacks(old_on_attach, client, bufnr)
    M.on_attach(client, bufnr)
    run_callbacks(user_on_attach, client, bufnr)
  end
  return opts
end

return M
