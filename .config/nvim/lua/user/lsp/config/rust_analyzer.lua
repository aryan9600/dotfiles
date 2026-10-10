-- rust-analyzer server config: always analyze projects with all cargo features
-- enabled. AstroNvim loads this file via `user_opts("lsp.config.rust_analyzer")`
-- and `vim.lsp.config` deep-merges it over nvim-lspconfig's lsp/rust_analyzer.lua.
return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        -- `cargo.allFeatures` was removed upstream in favor of `features = "all"`
        -- (the old key is still accepted via a compatibility patch, but deprecated)
        features = "all",
      },
      -- nvim-lspconfig now turns on rust-analyzer's "N references" code lenses; keep rust-analyzer's default (off)
      lens = {
        -- no "N implementations" lens above every struct/enum/trait
        implementations = { enable = false },
        references = {
          adt = { enable = false },
          enumVariant = { enable = false },
          method = { enable = false },
          trait = { enable = false },
        },
      },
    },
  },
}
