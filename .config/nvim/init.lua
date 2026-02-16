if vim.loader and vim.fn.has "nvim-0.9.1" == 1 then vim.loader.enable() end

for _, source in ipairs {
  "astronvim.bootstrap",
  "astronvim.options",
  "astronvim.lazy",
  "astronvim.autocmds",
  "astronvim.mappings",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
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

-- theme and transparent bg stuff
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi CursorColumn cterm=NONE ctermbg=NONE ctermfg=NONE")
vim.cmd("hi CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE")
vim.cmd("hi CursorLineNr cterm=NONE ctermbg=NONE ctermbg=NONE")
vim.cmd("hi clear LineNr")
vim.cmd("hi clear SignColumn")

vim.opt.title = true
vim.opt.titlestring = "nvim - %{fnamemodify(getcwd(), ':t')}"

-- delete not copy to register (inaccurate; fails for multiple lines)
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true })

vim.api.nvim_create_user_command("LspStartWithEnv", function(opts)
  vim.g.astronvim_lsp_env = {}
  for _, arg in ipairs(vim.split(opts.args, " ")) do
    local key, value = unpack(vim.split(arg, "=", { plain = true, trimempty = true }))
    if key and value then vim.g.astronvim_lsp_env[key] = value end
  end
  vim.cmd "LspStart"
end, { nargs = "*" })
