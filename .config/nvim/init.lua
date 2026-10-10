if vim.loader and vim.fn.has "nvim-0.9.1" == 1 then vim.loader.enable() end

for _, source in ipairs {
  "astronvim.bootstrap",
  "astronvim.options",
  "astronvim.lazy",
  "astronvim.autocmds",
  "astronvim.mappings",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.notify("Failed to load " .. source .. "\n\n" .. fault, vim.log.levels.ERROR) end
end

if astronvim.default_colorscheme then
  if not pcall(vim.cmd.colorscheme, astronvim.default_colorscheme) then
    require("astronvim.utils").notify(
      ("Error setting up colorscheme: `%s`"):format(astronvim.default_colorscheme),
      vim.log.levels.ERROR
    )
  end
end

require("astronvim.utils").conditional_func(astronvim.user_opts("polish", nil, false), true)

-- theme and transparent bg is driven by lua/plugins/auto-dark-mode.lua, which
-- follows the macOS system appearance

vim.opt.title = true
vim.opt.titlestring = "nvim - %{fnamemodify(getcwd(), ':t')}"

-- delete not copy to register (inaccurate; fails for multiple lines)
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true })

-- (re)start the current buffer's language servers with extra environment variables, e.g. `:LspStartWithEnv GOFLAGS=-tags=e2e`
vim.api.nvim_create_user_command("LspStartWithEnv", function(opts)
  -- build the table first: `vim.g.x[key] = value` modifies a copy and is silently lost
  local env = {}
  for _, arg in ipairs(vim.split(opts.args, " ")) do
    local key, value = unpack(vim.split(arg, "=", { plain = true, trimempty = true }))
    if key and value then env[key] = value end
  end
  vim.g.astronvim_lsp_env = env
  local lsp = require "astronvim.utils.lsp"
  local servers, clients = {}, {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if lsp.servers[client.name] then
      servers[client.name] = true
      table.insert(clients, client)
      client:stop()
    end
  end
  if vim.tbl_isempty(servers) then -- nothing running yet, use every configured server for this filetype
    for name in pairs(lsp.servers) do
      if vim.tbl_contains(vim.lsp.config[name].filetypes or {}, vim.bo.filetype) then servers[name] = true end
    end
  end
  vim.wait(2000, function()
    return vim.iter(clients):all(function(client) return client:is_stopped() end)
  end)
  -- re-configure with the env wrapped command, `vim.lsp.enable` then starts them again for open buffers
  vim.tbl_map(lsp.setup, vim.tbl_keys(servers))
end, { nargs = "*" })
