-- Follow the macOS system appearance: switch gruvbox between its light and dark
-- variants when the OS theme changes. Polls `AppleInterfaceStyle` and fires the
-- matching callback (also once on setup, so startup picks the current mode).
return {
  "f-person/auto-dark-mode.nvim",
  dependencies = { "gruvbox" }, -- colorscheme must be loaded before we apply it
  lazy = false,
  priority = 1000,
  config = function()
    -- reapply transparent bg on every gruvbox load; the colorscheme resets these
    local group = vim.api.nvim_create_augroup("GruvboxTransparent", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      pattern = "gruvbox",
      callback = function()
        vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
        vim.cmd("hi CursorColumn cterm=NONE ctermbg=NONE ctermfg=NONE")
        vim.cmd("hi CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE")
        vim.cmd("hi CursorLineNr cterm=NONE ctermbg=NONE ctermbg=NONE")
        vim.cmd("hi clear LineNr")
        vim.cmd("hi clear SignColumn")
      end,
    })

    require("auto-dark-mode").setup {
      update_interval = 3000,
      set_dark_mode = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme "gruvbox"
      end,
      set_light_mode = function()
        vim.o.background = "light"
        vim.cmd.colorscheme "gruvbox"
      end,
    }
  end,
}
