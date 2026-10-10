return {
  "b0o/SchemaStore.nvim",
  {
    -- replaces the archived neodev.nvim: Neovim runtime/plugin types for lua_ls when editing the Neovim config
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },
  {
    -- per-server settings live in lua/user/lsp/config/<server>.lua; `opts.servers`
    -- here is never read because the config function ignores plugin opts
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/neoconf.nvim",
        opts = function()
          local global_settings, file_found
          local _, depth = vim.fn.stdpath("config"):gsub("/", "")
          for _, dir in ipairs(astronvim.supported_configs) do
            dir = dir .. "/lua/user"
            if vim.fn.isdirectory(dir) == 1 then
              local path = dir .. "/neoconf.json"
              if vim.fn.filereadable(path) == 1 then
                file_found = true
                global_settings = path
              elseif not file_found then
                global_settings = path
              end
            end
          end
          return { global_settings = global_settings and string.rep("../", depth):sub(1, -2) .. global_settings }
        end,
      },
      {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        cmd = { "LspInstall", "LspUninstall" },
        opts = {},
        config = require "plugins.configs.mason-lspconfig",
      },
    },
    cmd = function(_, cmds) -- HACK: lazy load lspconfig on `:Neoconf` if neoconf is available
      if require("astronvim.utils").is_available "neoconf.nvim" then table.insert(cmds, "Neoconf") end
    end,
    event = "User AstroFile",
    config = require "plugins.configs.lspconfig",
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      {
        "jay-babu/mason-null-ls.nvim",
        cmd = { "NullLsInstall", "NullLsUninstall" },
        opts = { handlers = {} },
      },
    },
    event = "User AstroFile",
    opts = function() return { on_attach = require("astronvim.utils.lsp").on_attach } end,
  },
  {
    "stevearc/aerial.nvim",
    event = "User AstroFile",
    opts = {
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      disable_max_lines = vim.g.max_file.lines,
      disable_max_size = vim.g.max_file.size,
      layout = { min_width = 28 },
      show_guides = true,
      filter_kind = false,
      guides = {
        mid_item = "├ ",
        last_item = "└ ",
        nested_top = "│ ",
        whitespace = "  ",
      },
      keymaps = {
        ["[y"] = "actions.prev",
        ["]y"] = "actions.next",
        ["[Y"] = "actions.prev_up",
        ["]Y"] = "actions.next_up",
        ["{"] = false,
        ["}"] = false,
        ["[["] = false,
        ["]]"] = false,
      },
    },
  },
  {
    "github/copilot.vim",
    config = function()
      -- Disable default <Tab> mapping
      vim.g.copilot_no_tab_map = true

      -- Set custom mapping for accepting suggestions
      vim.api.nvim_set_keymap("i", "<C-Z>", 'copilot#Accept("<CR>")', {
        expr = true,
        silent = true,
        noremap = true,
      })

      -- Optional: you can set filetypes where Copilot is disabled
      vim.g.copilot_filetypes = {
        ["TelescopePrompt"] = false,
        ["neo-tree"] = false,
        [""] = false, -- disable for empty buffer
      }
    end,
  },
  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   dependencies = {
  --     { "github/copilot.vim" },                       -- or zbirenbaum/copilot.lua
  --     { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  --   },
  --   build = "make tiktoken",                          -- Only on MacOS or Linux
  --   mappings = {
  --     complete = {
  --       insert = '<C-Z>'
  --     }
  --   },
  --   opts = {
  --     model = "claude-3.7-sonnet",
  --     window = {
  --       layout = "horizontal",
  --       height = 0.3
  --     }
  --   },
  --   -- See Commands section for default commands if you want to lazy load on them
  -- },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    opts = {
      diff_opts = {
        layoyt = "horizontal",
      },
    },
    keys = {
      { "<leader>a",  nil,                              desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  },
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      -- opencode.nvim v2 (needed for the OpenCode v2 CLI) removed the `provider` option and `toggle()`, so the
      -- OpenCode TUI now runs in a snacks terminal managed here (same bottom/30% layout as the old snacks provider)
      local opencode_cmd = "opencode"
      ---@type snacks.terminal.Opts
      local terminal_opts = { count = 1, win = { position = "bottom", height = 0.3, enter = false } }

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function() require("snacks.terminal").open(opencode_cmd, terminal_opts) end,
        },
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      -- Recommended/example keymaps.
      vim.keymap.set({ "n", "x" }, "<leader>ma", function() require("opencode").ask("@this: ") end,
        { desc = "Ask opencode" })
      vim.keymap.set({ "n", "x" }, "<leader>ms", function() require("opencode").select() end,
        { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<leader>mm", function() require("snacks.terminal").toggle(opencode_cmd, terminal_opts) end,
        { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
        { expr = true, desc = "Add range to opencode" })
      vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
        { expr = true, desc = "Add line to opencode" })

      vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
        { desc = "opencode half page up" })
      vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
        { desc = "opencode half page down" })

      -- Toggle opencode window orientation between bottom and right.
      vim.api.nvim_create_user_command("OpencodeOrientation", function()
        local function flip(o)
          if (o.position or "right") == "bottom" then
            o.position, o.height, o.width = "right", nil, 0.4
          else
            o.position, o.height, o.width = "bottom", 0.3, nil
          end
        end

        -- opts used when the terminal is created fresh
        flip(terminal_opts.win)

        -- the running terminal instance, so it relayouts without restarting the TUI
        local terminal = require("snacks.terminal").get(opencode_cmd, vim.tbl_extend("force", terminal_opts, { create = false }))
        if terminal and terminal:buf_valid() then
          flip(terminal.opts)
          if terminal:valid() then
            terminal:hide() -- keeps the opencode process running
            terminal:show()
          end
        end
      end, { desc = "Toggle opencode window orientation" })

      -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    end,
  }
}
