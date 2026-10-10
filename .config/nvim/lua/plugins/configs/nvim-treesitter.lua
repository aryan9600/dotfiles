-- Attaches treesitter features per buffer the way the old nvim-treesitter `configs.setup` modules did:
-- highlight + indent for every filetype with an installed parser, and the textobject/incremental selection keymaps
-- as buffer-local mappings (only in buffers whose language provides the needed queries).
return function(_, opts)
  require("nvim-treesitter").setup()

  -- install missing parsers in the background (replacement for `ensure_installed`)
  local installed = require("nvim-treesitter").get_installed "parsers"
  local missing = vim.tbl_filter(function(lang) return not vim.tbl_contains(installed, lang) end, opts.ensure_installed)
  local attach_all -- defined below
  if #missing > 0 then
    require("nvim-treesitter").install(missing):await(function() vim.schedule(function() attach_all() end) end)
  end

  local textobjects = opts.textobjects
  require("nvim-treesitter-textobjects").setup {
    select = { lookahead = textobjects.select.lookahead },
    move = { set_jumps = textobjects.move.set_jumps },
  }

  local function map(bufnr, modes, lhs, rhs, desc, remap)
    vim.keymap.set(modes, lhs, rhs, { buffer = bufnr, silent = true, desc = desc, remap = remap })
  end

  local function set_textobject_maps(bufnr)
    local select, move, swap =
      require "nvim-treesitter-textobjects.select",
      require "nvim-treesitter-textobjects.move",
      require "nvim-treesitter-textobjects.swap"
    for lhs, spec in pairs(textobjects.select.keymaps) do
      map(bufnr, { "x", "o" }, lhs, function() select.select_textobject(spec.query, "textobjects") end, spec.desc)
    end
    for method, keymaps in pairs(textobjects.move) do
      if type(keymaps) == "table" then
        for lhs, spec in pairs(keymaps) do
          map(bufnr, { "n", "x", "o" }, lhs, function() move[method](spec.query, "textobjects") end, spec.desc)
        end
      end
    end
    for method, keymaps in pairs(textobjects.swap) do
      for lhs, spec in pairs(keymaps) do
        map(bufnr, "n", lhs, function() swap[method](spec.query) end, spec.desc)
      end
    end
  end

  -- incremental selection on top of Neovim 0.12's built-in node selection (visual `an`/`in`)
  local function set_incremental_selection_maps(bufnr)
    local keymaps = opts.incremental_selection.keymaps
    map(bufnr, "n", keymaps.init_selection, "van", "Start selecting nodes with nvim-treesitter", true)
    map(bufnr, "x", keymaps.node_incremental, "an", "Increment selection to named node", true)
    map(bufnr, "x", keymaps.scope_incremental, "an", "Increment selection to surrounding scope", true)
    map(bufnr, "x", keymaps.node_decremental, "in", "Shrink selection to previous named node", true)
  end

  local function attach(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.b[bufnr].ts_attached then return end
    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang or not vim.treesitter.language.add(lang) then return end
    vim.b[bufnr].ts_attached = true

    if not opts.highlight.disable(lang, bufnr) then pcall(vim.treesitter.start, bufnr, lang) end
    if opts.indent and vim.treesitter.query.get(lang, "indents") then
      vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    if vim.treesitter.query.get(lang, "textobjects") then set_textobject_maps(bufnr) end
    set_incremental_selection_maps(bufnr)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("astronvim_treesitter", { clear = true }),
    desc = "Attach treesitter highlight, indent, and textobjects",
    callback = function(args)
      vim.b[args.buf].ts_attached = nil -- filetype changed, re-evaluate
      attach(args.buf)
    end,
  })
  attach_all = function() vim.tbl_map(attach, vim.api.nvim_list_bufs()) end
  attach_all()
end
